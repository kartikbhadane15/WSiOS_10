//
//  CartRepository.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
import Combine

@MainActor
final class CartRepository: ObservableObject {
    
    @Published private(set) var items: [CartItem] = []
    
    // MARK: - Add Item
    func add(product: ProductItem, quantity: Int = 1) {
        guard let priceValue = product.price else { return }
        
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            items[index].quantity += 1
            // Sync with shared cart
            if CollaborativeCartManager.shared.currentCartId != nil {
                CollaborativeCartManager.shared.updateQuantity(itemId: product.id, change: 1)
            }
        } else {
            let newItem = CartItem(
                id: product.id,
                title: product.title,
                price: priceValue,
                path: product.path,
                quantity: quantity
            )
            items.append(newItem)
            // Sync with shared cart
            if CollaborativeCartManager.shared.currentCartId != nil {
                CollaborativeCartManager.shared.addItem(product: product, quantity: quantity)
            }
        }
    }
    
    // MARK: - Remove Item
    func remove(productId: String) {
        guard let index = items.firstIndex(where: { $0.id == productId }) else { return }
        let item = items[index]
        if item.quantity > 1 {
            items[index].quantity -= 1
            // Sync with shared cart
            if CollaborativeCartManager.shared.currentCartId != nil {
                CollaborativeCartManager.shared.updateQuantity(itemId: productId, change: -1)
            }
        } else {
            items.remove(at: index)
            // Sync with shared cart
            if CollaborativeCartManager.shared.currentCartId != nil {
                CollaborativeCartManager.shared.removeItem(itemId: productId)
            }
        }
    }
    
    // MARK: - Total Price
    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    // MARK: - Total Count
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    func increaseQuantity(productId: String) {
        guard let index = items.firstIndex(where: { $0.id == productId }) else { return }
        items[index].quantity += 1
        // Sync with shared cart
        if CollaborativeCartManager.shared.currentCartId != nil {
            CollaborativeCartManager.shared.updateQuantity(itemId: productId, change: 1)
        }
    }

    // MARK: - Clear All Items
    func clearAll() {
        items.removeAll()
        // Sync with shared cart
        if CollaborativeCartManager.shared.currentCartId != nil {
            // Option: Could clear all shared items or just let them stay
            // For now, let's just clear local
        }
    }

    // MARK: - Add Item by Identifier
    func addProduct(id: String, title: String, price: Double, path: String?, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].quantity += quantity
            // Sync with shared cart
            if CollaborativeCartManager.shared.currentCartId != nil {
                CollaborativeCartManager.shared.updateQuantity(itemId: id, change: quantity)
            }
        } else {
            let newItem = CartItem(
                id: id,
                title: title,
                price: price,
                path: path,
                quantity: quantity
            )
            items.append(newItem)
            // Sync with shared cart
            if CollaborativeCartManager.shared.currentCartId != nil {
                let product = ProductItem(id: id, title: title, price: price, path: path)
                CollaborativeCartManager.shared.addItem(product: product, quantity: quantity)
            }
        }
    }

    // MARK: - Collaborative Sync (Internal)
    func updateFromCollaborative(sharedItems: [LocalCartItem]) {
        // We map sharedItems back to CartItem
        let newItems = sharedItems.map { shared in
            CartItem(
                id: shared.id,
                title: shared.name,
                price: shared.price,
                path: shared.imagePath,
                quantity: shared.quantity
            )
        }
        
        // Directly update the published property
        // To avoid triggering another socket emit from the repository methods, 
        // we update the items array directly here.
        DispatchQueue.main.async {
            self.items = newItems
        }
    }
}
