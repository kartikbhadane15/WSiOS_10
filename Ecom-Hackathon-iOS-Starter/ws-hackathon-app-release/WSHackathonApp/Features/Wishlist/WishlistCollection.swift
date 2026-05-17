//
//  WishlistCollection.swift
//  WSHackathonApp
//

import Foundation

struct WishlistCollection: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    let createdAt: Date
    var items: [WishlistItem]
    
    static func == (lhs: WishlistCollection, rhs: WishlistCollection) -> Bool {
        return lhs.id == rhs.id
    }
}
