//
//  SmartWishlistService.swift
//  WSHackathonApp
//

import Foundation

class SmartWishlistService {
    static let shared = SmartWishlistService()
    
    private init() {}
    
    func generateMetadata(for product: ProductItem) -> WishlistItem {
        let originalPrice = product.price ?? 0
        let trending = false
        
        let isOutOfStock = false
        let stockCount = 50
        
        let tags: [SmartTag] = []
        
        // Mock engagement score for future AI sorting
        let engagementScore = Double.random(in: 0.0...1.0)
        
        return WishlistItem(
            id: product.id,
            product: product,
            savedAt: Date(),
            originalPrice: originalPrice,
            currentPrice: product.price ?? 0,
            stockCount: stockCount,
            trendingState: trending,
            smartTags: tags,
            lastViewed: Date(),
            engagementScore: engagementScore,
            notificationId: UUID().uuidString,
            deepLinkRoute: "williams-sonoma://product/\(product.id)"
        )
    }
}
