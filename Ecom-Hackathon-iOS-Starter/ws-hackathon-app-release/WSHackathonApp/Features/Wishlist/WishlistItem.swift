//
//  WishlistItem.swift
//  WSHackathonApp
//

import Foundation

enum SmartTag: String, Codable, CaseIterable {
    case priceDropped = "15% OFF"
    case trending = "Trending"
    case lowStock = "Selling Fast"
    case seasonal = "Festive Pick"
    case backInStock = "Back in Stock"
    case outOfStock = "Out of Stock"
}

struct WishlistItem: Identifiable, Codable, Equatable {
    let id: String
    let product: ProductItem
    let savedAt: Date
    let originalPrice: Double
    let currentPrice: Double
    let stockCount: Int
    let trendingState: Bool
    let smartTags: [SmartTag]
    let lastViewed: Date
    
    // Future AI & Routing Support
    let engagementScore: Double
    let notificationId: String?
    let deepLinkRoute: String?
    
    var isOutOfStock: Bool {
        return smartTags.contains(.outOfStock) || stockCount == 0
    }
    
    static func == (lhs: WishlistItem, rhs: WishlistItem) -> Bool {
        return lhs.id == rhs.id
    }
}
