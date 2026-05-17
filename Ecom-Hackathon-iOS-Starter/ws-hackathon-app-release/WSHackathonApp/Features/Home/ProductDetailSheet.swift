//
//  ProductDetailSheet.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

struct ProductDetailSheet: View {
    let product: ProductItem
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onAddToRegistry: () -> Void
    let onRemoveFromRegistry: () -> Void
    let canAddToRegistry: Bool
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var toastManager: ToastManager
    
    // Live reactive computed properties mapped directly to live repositories
    var quantity: Int {
        cartRepository.items.first(where: { $0.id == product.id })?.quantity ?? 0
    }
    
    var registryQuantity: Int {
        registryRepository.currentRegistry?.items.first(where: { $0.id == product.id })?.quantity ?? 0
    }
    
    // Theme Colors
    private let ivory = Color(red: 250/255, green: 246/255, blue: 240/255)
    private let walnut = Color(red: 46/255, green: 31/255, blue: 23/255)
    private let tan = Color(red: 230/255, green: 221/255, blue: 210/255)
    private let terracotta = Color(red: 194/255, green: 125/255, blue: 86/255)
    private let warmShadow = Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.04)
    
    var body: some View {
        ZStack {
            ivory
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Static Top Custom Navigation Bar (chevron.left styled identically to mockup)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.black)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // 2. Scrollable Details Content (sits elegantly below top navigation bar)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Product Brand & Type (placed BELOW top navigation bar)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.brand?.uppercased() ?? "WILLIAMS SONOMA")
                                .font(.system(size: 10, weight: .bold))
                                .kerning(2)
                                .foregroundColor(walnut.opacity(0.6))
                            
                            Text(product.productType?.replacingOccurrences(of: "-", with: " ").capitalized ?? "Collection")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(terracotta)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        
                        // Product Image
                        ZStack(alignment: .topTrailing) {
                            AsyncImage(url: product.imageURL) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 280)
                                        .cornerRadius(20)
                                } else if phase.error != nil {
                                    ZStack {
                                        Color.white
                                        Image(systemName: "photo")
                                            .foregroundColor(walnut.opacity(0.3))
                                            .font(.system(size: 40))
                                    }
                                    .frame(height: 280)
                                    .cornerRadius(20)
                                } else {
                                    ZStack {
                                        Color.white
                                        ProgressView()
                                            .tint(walnut)
                                    }
                                    .frame(height: 280)
                                    .cornerRadius(20)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                            
                            // Wishlist Button (Glassmorphic)
                            Button(action: {
                                let added = wishlistManager.toggleWishlist(product: product)
                                if added {
                                    toastManager.show(message: AppStrings.Wishlist.savedToast)
                                } else {
                                    toastManager.show(message: AppStrings.Wishlist.removedToast)
                                }
                            }) {
                                Image(systemName: wishlistManager.isWishlisted(product: product) ? "heart.fill" : "heart")
                                    .foregroundColor(wishlistManager.isWishlisted(product: product) ? .red : walnut)
                                    .font(.system(size: 15, weight: .bold))
                                    .frame(width: 44, height: 44)
                                    .background(BlurView(style: .systemThinMaterialLight))
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                            }
                            .padding(14)
                            .scaleEffect(wishlistManager.isWishlisted(product: product) ? 1.12 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: wishlistManager.isWishlisted(product: product))
                        }
                        .padding(.horizontal, 20)
                        
                        // Product Title & Price
                        VStack(alignment: .leading, spacing: 10) {
                            Text(product.title)
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(walnut)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack(spacing: 8) {
                                Text((product.price ?? 0.0).formatted(.currency(code: "USD")))
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(walnut)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        

                        
                        // Section 4: Dynamic Collaborative Cart Controls
                        VStack(alignment: .leading, spacing: 16) {
                            Text("YOUR CART SELECTIONS")
                                .font(.system(size: 10, weight: .bold))
                                .kerning(2)
                                .foregroundColor(walnut.opacity(0.5))
                                .padding(.horizontal, 4)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                if quantity == 0 {
                                    Button(action: onAdd) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "cart.badge.plus")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text("Add to Cart")
                                                .font(.system(size: 15, weight: .bold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(walnut)
                                        .cornerRadius(25)
                                    }
                                    .buttonStyle(SpringPressButtonStyle())
                                    .shadow(color: walnut.opacity(0.2), radius: 8, x: 0, y: 4)
                                } else {
                                    HStack(spacing: 0) {
                                        Button(action: onRemove) {
                                            Image(systemName: "minus")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(walnut)
                                                .frame(width: 50, height: 50)
                                                .background(Color.clear)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(SpringPressButtonStyle())
                                        
                                        Spacer()
                                        
                                        VStack(spacing: 2) {
                                            Text("\(quantity)")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(walnut)
                                            Text("items in cart")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(walnut.opacity(0.5))
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: onAdd) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(walnut)
                                                .frame(width: 50, height: 50)
                                                .background(Color.clear)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(SpringPressButtonStyle())
                                    }
                                    .frame(height: 50)
                                    .background(Color.white)
                                    .cornerRadius(25)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(tan.opacity(0.6), lineWidth: 1)
                                    )
                                    .shadow(color: warmShadow, radius: 6, x: 0, y: 3)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

// Reusable spring button style
struct SpringPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Reusable specs highlight row component
struct HighlightRow: View {
    let icon: String
    let text: String
    let subtitle: String
    let isFirst: Bool
    let isLast: Bool
    
    private let walnut = Color(red: 46/255, green: 31/255, blue: 23/255)
    private let tan = Color(red: 230/255, green: 221/255, blue: 210/255)
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(walnut)
                .frame(width: 32, height: 32)
                .background(tan.opacity(0.3))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(walnut)
                    .lineLimit(2)
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(walnut.opacity(0.6))
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
