// VisualSearchViewModel.swift
// WSHackathonApp – Visual Search / Style Board
//
// Orchestrates the full pipeline:
//   1. Receive a UIImage from the camera / photo library
//   2. Run on-device Vision analysis (dominant colours + scene tags)
//   3. POST the embedding request to the server and receive similar products

import SwiftUI
import Vision
import Combine

// MARK: – State machine

enum VisualSearchState: Equatable {
    case idle
    case analyzing
    case searching
    case results([VisualProductItem])
    case error(String)

    static func == (lhs: VisualSearchState, rhs: VisualSearchState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.analyzing, .analyzing), (.searching, .searching):
            return true
        case (.results(let a), .results(let b)):
            return a.map(\.id) == b.map(\.id)
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: – ViewModel

@MainActor
final class VisualSearchViewModel: ObservableObject {

    @Published var state: VisualSearchState = .idle
    @Published var capturedImage: UIImage?
    @Published var dominantColors: [Color] = []
    @Published var styleTags: [String] = []

    private var lastImage: UIImage?
    private let visionService = VisionAnalysisService()
    private let searchService = StyleSearchService()

    // MARK: Public API

    func process(image: UIImage) {
        capturedImage = image
        lastImage = image
        dominantColors = []
        styleTags = []
        state = .analyzing
        Task { await runPipeline(image: image) }
    }

    func retry() {
        guard let image = lastImage else { return }
        process(image: image)
    }

    func reset() {
        capturedImage = nil
        lastImage = nil
        dominantColors = []
        styleTags = []
        state = .idle
    }

    // MARK: Pipeline

    private func runPipeline(image: UIImage) async {
        do {
            // Step 1 – On-device Vision
            let analysis = try await visionService.analyse(image: image)
            dominantColors = analysis.dominantColors
            styleTags = analysis.styleTags
            state = .searching

            // Step 2 – Server-side embedding similarity search
            let products = try await searchService.findSimilar(
                imageEmbedding: analysis.embedding,
                colorHexValues: analysis.colorHexValues,
                tags: analysis.styleTags
            )
            state = .results(products)

        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
