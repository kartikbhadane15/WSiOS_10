// StyleSearchService.swift
// WSHackathonApp – Visual Search / Style Board
//
// For the hackathon demo, fetches real products from the local mock API
// (same one HomeView uses) and returns them as visual search results.

import Foundation

// MARK: – Service

final class StyleSearchService {

    func findSimilar(imageEmbedding: [Float],
                     colorHexValues: [String],
                     tags: [String]) async throws -> [VisualProductItem] {

        // Fetch real products from the local mock API
        let url = URL(string: AppConstants.API.baseURL + "/skus")!
        let (data, _) = try await URLSession.shared.data(from: url)

        let dtos = try JSONDecoder().decode([ProductItemDTO].self, from: data)

        // Convert to VisualProductItem, assign a fake match score for demo
        let products = dtos.prefix(12).enumerated().map { index, dto -> VisualProductItem in
            let score = max(0.60, 0.97 - (Double(index) * 0.03))
            let imageURL: URL?
            if let path = dto.media?.images?.first?.path {
                imageURL = URL(string: AppConstants.API.imageBasePath + path)
            } else {
                imageURL = nil
            }
            return VisualProductItem(
                id: dto.id,
                name: dto.name,
                price: dto.price?.regularPrice ?? 0.0,
                currency: "USD",
                imageURL: imageURL,
                matchScore: score,
                tags: tags
            )
        }

        return Array(products)
    }
}

// MARK: – Error types

enum SearchError: LocalizedError {
    case serverError
    case noResults

    var errorDescription: String? {
        switch self {
        case .serverError:  return "The product search service is temporarily unavailable."
        case .noResults:    return "No matching products found. Try a different photo."
        }
    }
}
