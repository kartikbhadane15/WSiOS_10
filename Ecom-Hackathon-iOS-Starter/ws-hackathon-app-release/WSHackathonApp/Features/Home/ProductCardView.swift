//
//  ProductCardView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import Foundation
import SwiftUI

struct ProductCardView: View {
    let product: ProductItem
    let quantity: Int
    let registryQuantity: Int
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onAddToRegistry: () -> Void
    let onRemoveFromRegistry: () -> Void
    
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: product.imageURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: 150)
                                .clipped()
                                .cornerRadius(8)
                        } else if phase.error != nil {
                            ZStack {
                                Color(.systemGray5)
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 30))
                            }
                            .frame(width: geo.size.width, height: 150)
                            .cornerRadius(8)
                        } else {
                            ZStack {
                                Color(.systemGray5)
                                ProgressView()
                            }
                            .frame(width: geo.size.width, height: 150)
                            .cornerRadius(8)
                        }
                    }
                    
                    // Wishlist Button
                    Button(action: {
                        let added = wishlistManager.toggleWishlist(product: product)
                        if added {
                            toastManager.show(message: AppStrings.Wishlist.savedToast)
                        } else {
                            toastManager.show(message: AppStrings.Wishlist.removedToast)
                        }
                    }) {
                        Image(systemName: wishlistManager.isWishlisted(product: product) ? "heart.fill" : "heart")
                            .foregroundColor(wishlistManager.isWishlisted(product: product) ? .red : .gray)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .padding(8)
                    .scaleEffect(wishlistManager.isWishlisted(product: product) ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: wishlistManager.isWishlisted(product: product))
                }
            }
            .frame(height: 150) // fix GeometryReader height
            
            // Product Text
            Text(product.title)
                .font(.subheadline)
            
            Text(product.price?.formatted(.currency(code: "USD")) ?? "")
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            // Add To Cart
            if quantity == 0 {
                Button(action: onAdd) {
                    Text(AppStrings.Home.addToCartButton)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                HStack {
                    Text(AppStrings.Cart.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 60, alignment: .leading)
                    
                    Button(action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                    }
                    
                    Spacer()
                    
                    Text("\(quantity)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                .font(.title3)
                .foregroundColor(.black)
            }
            // Add To Registry
            if registryQuantity == 0 {
                Button(AppStrings.Home.addToRegistry, action: onAddToRegistry)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                HStack {
                    Text(AppStrings.Registry.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 60, alignment: .leading)
                    
                    Button(action: onRemoveFromRegistry) {
                        Image(systemName: "minus.circle.fill")
                    }
                    
                    Spacer()
                    
                    Text("\(registryQuantity)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button(action: onAddToRegistry) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                .font(.title3)
                .foregroundColor(.black)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
        .frame(maxWidth: .infinity)
    }
}
