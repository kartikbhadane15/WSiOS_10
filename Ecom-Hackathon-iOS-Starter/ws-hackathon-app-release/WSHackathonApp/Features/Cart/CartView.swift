//
//  CartView.swift
//  WSHackathonApp
//

import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Active Cart Section
                            if viewModel.isEmptyCart {
                                VStack {
                                    EmptyCartView { tabBarVM.selectTab(.home) }
                                }
                                .padding(.top, 40)
                            } else {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Active Cart")
                                        .font(.headline)
                                        .padding(.horizontal, 4)
                                    
                                    ForEach(viewModel.items) { item in
                                        CartItemRow(
                                            item: item,
                                            onAdd: { viewModel.add(item) },
                                            onRemove: { viewModel.removeItem(item) },
                                            onMoveToWishlist: {
                                                withAnimation {
                                                    // Remove entirely from cart
                                                    for _ in 0..<item.quantity {
                                                        cartRepository.remove(productId: item.id)
                                                    }
                                                    // Add to wishlist
                                                    let pItem = ProductItem(id: item.id, title: item.title, price: item.price, path: item.path)
                                                    wishlistManager.addToWishlist(product: pItem)
                                                    toastManager.show(message: "Moved to Wishlist")
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                    
                    // MARK: - Bottom Total View
                    if !viewModel.isEmptyCart {
                        VStack(spacing: 12) {
                            HStack {
                                Text(AppStrings.Cart.total)
                                    .font(.headline)
                                Spacer()
                                Text(viewModel.totalPriceText)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
                            Button(action: {
                                // TODO: - Implement checkout flow
                            }) {
                                Text(AppStrings.Cart.checkoutButton)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16.0)
                        .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: -2)
                    }
                }
            }
            .navigationTitle(AppStrings.Cart.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: WishlistView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "heart")
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                                .padding(.trailing, 8)
                                .padding(.top, 4)
                            
                            if !wishlistManager.wishlistItems.isEmpty {
                                Text("\(wishlistManager.wishlistItems.count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                viewModel.bind(repository: cartRepository)
            }
        }
    }
}
