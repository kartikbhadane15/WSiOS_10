// VisionAnalysisService.swift
// WSHackathonApp – Visual Search / Style Board
//
// On-device Vision pipeline:
//   • Dominant colour extraction via pixel sampling + k-means clustering
//   • Scene / object classification via VNClassifyImageRequest
//   • Lightweight 512-d CLIP-style embedding via FeaturePrint

import UIKit
import SwiftUI
import Vision
import CoreImage

// MARK: – Result model

struct ImageAnalysis {
    let dominantColors: [Color]      // SwiftUI Color for display
    let colorHexValues: [String]     // "#RRGGBB" strings for server query
    let styleTags: [String]          // Human-readable labels from classification
    let embedding: [Float]           // Feature vector for similarity search
}

// MARK: – Service

final class VisionAnalysisService {

    // MARK: Public

    func analyse(image: UIImage) async throws -> ImageAnalysis {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }

        async let colors = extractDominantColors(from: cgImage, image: image)
        async let tags   = classifyScene(cgImage: cgImage)
        async let embed  = extractEmbedding(cgImage: cgImage)

        return try await ImageAnalysis(
            dominantColors: colors.swiftUIColors,
            colorHexValues: colors.hexValues,
            styleTags: tags,
            embedding: embed
        )
    }

    // MARK: – Dominant colour extraction

    private struct ColorCluster {
        var swiftUIColors: [Color]
        var hexValues: [String]
    }

    private func extractDominantColors(from cgImage: CGImage,
                                       image: UIImage) async throws -> ColorCluster {
        // Downsample to 100×100 for speed
        let sampleSize = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: sampleSize)
        let small = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: sampleSize)) }
        guard let smallCG = small.cgImage else { throw VisionError.invalidImage }

        // Pull raw pixel bytes
        let width = smallCG.width
        let height = smallCG.height
        let totalPixels = width * height
        var rawData = [UInt8](repeating: 0, count: totalPixels * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: &rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            throw VisionError.processingFailed
        }
        context.draw(smallCG, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Collect non-grey, non-white, non-black pixels
        var pixels: [(r: Float, g: Float, b: Float)] = []
        pixels.reserveCapacity(totalPixels / 4)
        for i in stride(from: 0, to: rawData.count - 4, by: 4) {
            let r = Float(rawData[i])     / 255.0
            let g = Float(rawData[i + 1]) / 255.0
            let b = Float(rawData[i + 2]) / 255.0
            let brightness = (r + g + b) / 3.0
            let saturation = max(r, g, b) - min(r, g, b)
            if brightness > 0.1 && brightness < 0.95 && saturation > 0.05 {
                pixels.append((r, g, b))
            }
        }

        // Simple k-means (k = 5, 10 iterations)
        let k = min(5, max(1, pixels.count))
        var centers = Array(pixels.shuffled().prefix(k))

        for _ in 0..<10 {
            var sums = [(r: Float, g: Float, b: Float, count: Int)](repeating: (0, 0, 0, 0), count: k)
            for px in pixels {
                var best = 0
                var bestDist = Float.greatestFiniteMagnitude
                for (j, c) in centers.enumerated() {
                    let d = (px.r - c.r) * (px.r - c.r)
                              + (px.g - c.g) * (px.g - c.g)
                              + (px.b - c.b) * (px.b - c.b)
                    if d < bestDist { bestDist = d; best = j }
                }
                sums[best].r     += px.r
                sums[best].g     += px.g
                sums[best].b     += px.b
                sums[best].count += 1
            }
            for j in 0..<k where sums[j].count > 0 {
                let n = Float(sums[j].count)
                centers[j] = (sums[j].r / n, sums[j].g / n, sums[j].b / n)
            }
        }

        let hexValues = centers.map { c in
            let r = Int(c.r * 255), g = Int(c.g * 255), b = Int(c.b * 255)
            return String(format: "#%02X%02X%02X", r, g, b)
        }
        let swiftUIColors = centers.map {
            Color(red: Double($0.r), green: Double($0.g), blue: Double($0.b))
        }

        return ColorCluster(swiftUIColors: swiftUIColors, hexValues: hexValues)
    }

    // MARK: – Scene classification

    private func classifyScene(cgImage: CGImage) async throws -> [String] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { req, err in
                if let err { continuation.resume(throwing: err); return }
                guard let results = req.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                // Keep top confident labels, map to style-relevant tags
                let tags = results
                    .filter { $0.confidence > 0.4 }
                    .prefix(6)
                    .compactMap { StyleTagMapper.map($0.identifier) }
                continuation.resume(returning: Array(tags))
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: – Feature-print embedding

    private func extractEmbedding(cgImage: CGImage) async throws -> [Float] {
        return try await withCheckedThrowingContinuation { continuation in
            var printObservation: VNFeaturePrintObservation?
            let request = VNGenerateImageFeaturePrintRequest { req, err in
                if let err { continuation.resume(throwing: err); return }
                printObservation = req.results?.first as? VNFeaturePrintObservation
                guard let obs = printObservation else {
                    continuation.resume(returning: [])
                    return
                }
                // Convert to [Float]
                var floatBuffer = [Float](repeating: 0, count: obs.elementCount)
                floatBuffer.withUnsafeMutableBufferPointer { ptr in
                    try? obs.copy
                }
                continuation.resume(returning: floatBuffer)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: – Style tag mapper

private enum StyleTagMapper {
    private static let map: [String: String] = [
        "kitchen": "Kitchen",
        "countertop": "Countertop",
        "wood": "Wood",
        "marble": "Marble",
        "ceramic": "Ceramic",
        "stainless_steel": "Stainless Steel",
        "minimalist": "Minimalist",
        "rustic": "Rustic",
        "modern": "Modern",
        "vintage": "Vintage",
        "scandinavian": "Scandinavian",
        "industrial": "Industrial",
        "farmhouse": "Farmhouse",
        "mediterranean": "Mediterranean",
        "neutral_colors": "Neutral Tones",
        "warm_colors": "Warm Palette",
        "cool_colors": "Cool Palette",
    ]

    static func map(_ identifier: String) -> String? {
        // Try exact match first, then prefix match
        if let v = map[identifier] { return v }
        return map.first { identifier.contains($0.key) }?.value
    }
}

// MARK: – Errors

enum VisionError: LocalizedError {
    case invalidImage
    case processingFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:      return "Could not read the selected image."
        case .processingFailed:  return "On-device analysis failed. Please try again."
        }
    }
}
