//
//  WishlistView.swift
//  WSHackathonApp
//

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = true
    @State private var activeSmartFilters: Set<SmartTag> = []
    @State private var showingDestinationSheet = false
    
    var filteredItems: [WishlistItem] {
        var items = wishlistManager.wishlistItems
        if !activeSmartFilters.isEmpty {
            items = items.filter { item in
                activeSmartFilters.isSubset(of: Set(item.smartTags))
            }
        }
        return items
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Waking up AI Engine...")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            
                            // MARK: - Collections Card
                            NavigationLink(destination: CollectionsView(), isActive: $wishlistManager.isShowingCollections) {
                                if wishlistManager.selectionMode == .none {
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                        
                                        Text("Collections")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 4) {
                                            Text("\(wishlistManager.collections.count)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                                } else {
                                    EmptyView()
                                }
                            }
                            
                            if wishlistManager.wishlistItems.isEmpty {
                                VStack {
                                    Spacer().frame(height: 80)
                                    EmptyWishlistView {
                                        dismiss()
                                        tabBarVM.selectTab(.home)
                                    }
                                }
                            } else {
                                // MARK: - Grid
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredItems) { item in
                                        WishlistCardView(
                                            item: item,
                                            isSelectMode: wishlistManager.selectionMode != .none,
                                            isSelected: wishlistManager.selectedItemIds.contains(item.id),
                                            isAlreadyInCollection: {
                                                if let targetId = wishlistManager.targetCollectionForAdd,
                                                   let collection = wishlistManager.collections.first(where: { $0.id == targetId }) {
                                                    return collection.items.contains(where: { $0.id == item.id })
                                                }
                                                return false
                                            }(),
                                            showMoveToCart: wishlistManager.selectionMode == .none,
                                            onToggleSelect: {
                                                withAnimation(.spring()) {
                                                    if wishlistManager.selectedItemIds.contains(item.id) {
                                                        wishlistManager.selectedItemIds.remove(item.id)
                                                    } else {
                                                        wishlistManager.selectedItemIds.insert(item.id)
                                                    }
                                                }
                                            },
                                            onMoveToCart: {
                                                wishlistManager.moveToCart(item: item, cartRepo: cartRepo)
                                                toastManager.show(message: "Moved to Cart")
                                            },
                                            onRemove: {
                                                withAnimation {
                                                    wishlistManager.removeFromWishlist(product: item.product)
                                                    toastManager.show(message: "Removed from Wishlist")
                                                }
                                            }
                                        )
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(.bottom, wishlistManager.selectionMode == .standard ? 80 : 0)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            
            // Floating Action Bar (Only for .standard mode)
            if wishlistManager.selectionMode == .standard && !wishlistManager.selectedItemIds.isEmpty {
                VStack {
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation {
                                for id in wishlistManager.selectedItemIds {
                                    if let item = wishlistManager.wishlistItems.first(where: { $0.id == id }) {
                                        wishlistManager.removeFromWishlist(product: item.product)
                                    }
                                }
                                wishlistManager.selectedItemIds.removeAll()
                                wishlistManager.selectionMode = .none
                                toastManager.show(message: "Items removed")
                            }
                        }) {
                            Text("Remove")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 24)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            withAnimation {
                                for id in wishlistManager.selectedItemIds {
                                    if let item = wishlistManager.wishlistItems.first(where: { $0.id == id }) {
                                        if !item.isOutOfStock {
                                            wishlistManager.moveToCart(item: item, cartRepo: cartRepo)
                                        }
                                    }
                                }
                                wishlistManager.selectedItemIds.removeAll()
                                wishlistManager.selectionMode = .none
                                toastManager.show(message: "Moved available items to Cart")
                            }
                        }) {
                            Text("Move to Cart")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.black)
                                .cornerRadius(12)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(wishlistManager.selectionMode != .none ? "Select Items" : AppStrings.Wishlist.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(wishlistManager.selectionMode != .none)
        .toolbar {
            if wishlistManager.selectionMode == .none {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !wishlistManager.wishlistItems.isEmpty {
                        Button(action: {
                            withAnimation(.spring()) {
                                wishlistManager.selectionMode = .standard
                                wishlistManager.selectedItemIds.removeAll()
                            }
                        }) {
                            Text("Select")
                                .fontWeight(.medium)
                        }
                    }
                }
            } else {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.spring()) {
                            wishlistManager.selectionMode = .none
                            wishlistManager.selectedItemIds.removeAll()
                            wishlistManager.targetCollectionForAdd = nil
                        }
                    }) {
                        Text("Cancel")
                            .foregroundColor(.primary)
                    }
                }
                
                if wishlistManager.selectionMode == .collection {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if let target = wishlistManager.targetCollectionForAdd {
                                let itemsToAdd = wishlistManager.wishlistItems.filter { wishlistManager.selectedItemIds.contains($0.id) }
                                if let index = wishlistManager.collections.firstIndex(where: { $0.id == target }) {
                                    let existingItemIds = Set(wishlistManager.collections[index].items.map { $0.id })
                                    let uniqueItemsToAdd = itemsToAdd.filter { !existingItemIds.contains($0.id) }
                                    wishlistManager.collections[index].items.append(contentsOf: uniqueItemsToAdd)
                                }
                                withAnimation {
                                    wishlistManager.selectionMode = .none
                                    wishlistManager.selectedItemIds.removeAll()
                                    wishlistManager.targetCollectionForAdd = nil
                                }
                                toastManager.show(message: "Added to Collection")
                            } else {
                                showingDestinationSheet = true
                            }
                        }) {
                            Text("Continue")
                                .fontWeight(.bold)
                                .foregroundColor(wishlistManager.selectedItemIds.isEmpty ? .gray : .blue)
                        }
                        .disabled(wishlistManager.selectedItemIds.isEmpty)
                    }
                }
            }
        }
        .sheet(isPresented: $showingDestinationSheet) {
            CollectionDestinationSheet()
                .environmentObject(wishlistManager)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { isLoading = false }
            }
        }
    }
}

