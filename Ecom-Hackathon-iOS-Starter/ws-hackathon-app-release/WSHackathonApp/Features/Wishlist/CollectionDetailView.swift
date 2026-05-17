//
//  CollectionDetailView.swift
//  WSHackathonApp
//

import SwiftUI

struct CollectionDetailView: View {
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @State private var showingEmptyWishlistSheet = false
    @Environment(\.dismiss) var dismiss
    
    let collection: WishlistCollection
    
    var currentCollection: WishlistCollection? {
        wishlistManager.collections.first(where: { $0.id == collection.id })
    }
    
    var collectionItems: [WishlistItem] {
        currentCollection?.items ?? []
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            if collectionItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("This collection is empty.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        if wishlistManager.wishlistItems.isEmpty {
                            showingEmptyWishlistSheet = true
                        } else {
                            wishlistManager.isShowingCollections = false
                            // Increase delay slightly to ensure transition is well underway
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    wishlistManager.selectedItemIds.removeAll()
                                    wishlistManager.targetCollectionForAdd = collection.id
                                    wishlistManager.selectionMode = .collection
                                }
                            }
                        }
                    }) {
                        Text("Add Items")
                            .fontWeight(.medium)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 8)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(collectionItems) { item in
                            WishlistCardView(
                                item: item,
                                isSelectMode: false,
                                isSelected: false,
                                showMoveToCart: false,
                                onToggleSelect: {},
                                onMoveToCart: {},
                                onRemove: {
                                    withAnimation {
                                        wishlistManager.removeItemFromCollection(itemId: item.id, collectionId: collection.id)
                                        toastManager.show(message: "Removed from Collection")
                                    }
                                }
                            )
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }
            }
            
            // Floating Bottom Actions
            if !collectionItems.isEmpty {
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            // Move all items from the collection to the cart
                            for item in collectionItems {
                                wishlistManager.moveToCart(item: item, cartRepo: cartRepo)
                            }
                            
                            // Delete the collection after moving items
                            wishlistManager.deleteCollection(id: collection.id)
                            dismiss()
                            toastManager.show(message: "Collection moved to Cart")
                        }
                    }) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Move All to Cart")
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground).shadow(color: Color.black.opacity(0.05), radius: 10, y: -5))
            }
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        if wishlistManager.wishlistItems.isEmpty {
                            showingEmptyWishlistSheet = true
                        } else {
                            wishlistManager.isShowingCollections = false
                            // Increase delay slightly to ensure transition is well underway
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    wishlistManager.selectedItemIds.removeAll()
                                    wishlistManager.targetCollectionForAdd = collection.id
                                    wishlistManager.selectionMode = .collection
                                }
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        wishlistManager.deleteCollection(id: collection.id)
                        dismiss()
                        toastManager.show(message: "Collection deleted")
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEmptyWishlistSheet) {
            CollectionsEmptyStateSheet(onBrowse: {
                dismiss()
                tabBarVM.selectTab(.home)
            })
        }
    }
}
