//
//  CartViewModel.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 05/04/26.
//

import Foundation
import Combine

@MainActor
final class CartViewModel: ObservableObject {

    @Published private(set) var items: [CartItem] = []
    @Published var isGift: Bool = false
    @Published var giftMessage: String = ""
    @Published var includesGiftWrap: Bool = false
    @Published var hesitationDetector = HesitationDetector()
    private var cancellable: AnyCancellable?
    private var repository: CartRepository?
    
    func bind(repository: CartRepository) {
        self.repository = repository
        self.items = repository.items
        
        cancellable = repository.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedItems in
                self?.items = updatedItems
            }
    }
    
    var isEmptyCart: Bool {
        items.isEmpty
    }
    
    var baseTotal: Double {
        repository?.totalPrice ?? 0
    }

    var giftWrapPrice: Double { includesGiftWrap ? 2.00 : 0.00 }

    var finalTotal: Double {
        baseTotal + giftWrapPrice
    }

    var totalPriceText: String {
        String(format: "$%.2f", finalTotal)
    }

    var baseTotalText: String {
        String(format: "$%.2f", baseTotal)
    }
    
    func removeItem(_ item: CartItem) {
        let itemId = item.id
        repository?.remove(productId: itemId)
        let newQty = repository?.items.first(where: { $0.id == itemId })?.quantity ?? 0
        hesitationDetector.recordQuantityChange(for: itemId, quantity: newQty)
    }
    
    func add(_ item: CartItem) {
        repository?.increaseQuantity(productId: item.id)
        let newQty = repository?.items.first(where: { $0.id == item.id })?.quantity ?? 0
        hesitationDetector.recordQuantityChange(for: item.id, quantity: newQty)
    }

    func addBundleItems(_ bundleItems: [BundleItem]) {
        for item in bundleItems {
            repository?.addProduct(id: item.id, title: item.name, price: item.originalPrice, path: item.imageName)
        }
    }

    func addSingleBundleItem(_ item: BundleItem) {
        repository?.addProduct(id: item.id, title: item.name, price: item.originalPrice, path: item.imageName)
    }

    func clearCart() {
        repository?.clearAll()
    }
    
}
