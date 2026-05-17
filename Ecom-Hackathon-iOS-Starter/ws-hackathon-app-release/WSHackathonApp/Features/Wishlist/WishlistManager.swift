//
//  WishlistManager.swift
//  WSHackathonApp
//

import Foundation
import SwiftUI
import Combine
import UIKit

enum WishlistSelectionMode {
    case none
    case standard
    case collection
}

class WishlistManager: ObservableObject {
    @Published var wishlistItems: [WishlistItem] = [] {
        didSet {
            saveWishlist()
        }
    }
    
    @Published var collections: [WishlistCollection] = [] {
        didSet {
            saveCollections()
        }
    }
    
    // Routing & Selection State
    @Published var selectionMode: WishlistSelectionMode = .none
    @Published var selectedItemIds: Set<String> = []
    @Published var isShowingCollections = false
    @Published var targetCollectionForAdd: String? = nil
    
    private let wishlistKey = "SmartWishlistItems"
    private let collectionsKey = "SmartWishlistCollections"
    
    init() {
        loadWishlist()
        loadCollections()
    }
    
    func addToWishlist(product: ProductItem) {
        if !isWishlisted(product: product) {
            let newItem = SmartWishlistService.shared.generateMetadata(for: product)
            wishlistItems.append(newItem)
        }
    }
    
    func removeFromWishlist(product: ProductItem) {
        wishlistItems.removeAll { $0.id == product.id }
    }
    
    func toggleWishlist(product: ProductItem) -> Bool {
        if isWishlisted(product: product) {
            removeFromWishlist(product: product)
            return false // removed
        } else {
            addToWishlist(product: product)
            return true // added
        }
    }
    
    func isWishlisted(product: ProductItem) -> Bool {
        return wishlistItems.contains(where: { $0.id == product.id })
    }
    
    @MainActor
    func moveToCart(item: WishlistItem, cartRepo: CartRepository) {
        cartRepo.add(product: item.product)
        wishlistItems.removeAll { $0.id == item.id }
    }
    
    private func saveWishlist() {
        if let encoded = try? JSONEncoder().encode(wishlistItems) {
            UserDefaults.standard.set(encoded, forKey: wishlistKey)
        }
    }
    
    private func loadWishlist() {
        if let data = UserDefaults.standard.data(forKey: wishlistKey),
           let decoded = try? JSONDecoder().decode([WishlistItem].self, from: data) {
            self.wishlistItems = decoded
        }
    }
    
    // MARK: - Collections Support
    
    private func saveCollections() {
        if let encoded = try? JSONEncoder().encode(collections) {
            UserDefaults.standard.set(encoded, forKey: collectionsKey)
        }
    }
    
    private func loadCollections() {
        if let data = UserDefaults.standard.data(forKey: collectionsKey),
           let decoded = try? JSONDecoder().decode([WishlistCollection].self, from: data) {
            self.collections = decoded
        }
    }
    
    func createCollection(name: String, items: [WishlistItem]) {
        let newCollection = WishlistCollection(
            id: UUID().uuidString,
            name: name,
            createdAt: Date(),
            items: items
        )
        collections.append(newCollection)
    }
    
    func deleteCollection(id: String) {
        collections.removeAll { $0.id == id }
    }
    
    func removeItemFromCollection(itemId: String, collectionId: String) {
        if let index = collections.firstIndex(where: { $0.id == collectionId }) {
            collections[index].items.removeAll { $0.id == itemId }
        }
    }
}
