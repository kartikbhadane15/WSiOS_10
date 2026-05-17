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
    let onAdd: () -> Void
    let onRemove: () -> Void
    var useTintAsCardBackground: Bool = false
    
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var cartRepository: CartRepository
    
    // Luxury Editorial Theme Colors Aligned with Lovable AI
    private let walnut = Color(red: 42/255, green: 37/255, blue: 32/255)       // #2A2520 Ink - primary deep text
    private let ivory = Color(red: 250/255, green: 247/255, blue: 240/255)     // #FAF7F0 Ivory base background
    private let tan = Color(red: 221/255, green: 211/255, blue: 194/255)       // #DDD3C2 Stone Warm (borders)
    private let terracotta = Color(red: 107/255, green: 82/255, blue: 64/255)  // #6B5240 Walnut rich brown accent
    private let warmShadow = Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.035)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Push Navigation Link for Card Tap
            NavigationLink(destination: ProductDetailSheet(
                product: product,
                onAdd: onAdd,
                onRemove: onRemove,
                onAddToRegistry: {},
                onRemoveFromRegistry: {},
                canAddToRegistry: false
            )
            .environmentObject(wishlistManager)
            .environmentObject(toastManager)
            .environmentObject(cartRepository)
            .environmentObject(registryRepository)) {
                
                VStack(alignment: .leading, spacing: 0) {
                    // 1. Image Frame (Fixed Height: 135pt)
                    ZStack(alignment: .topTrailing) {
                        // Background & Product Image
                        AsyncImage(url: product.imageURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 135)
                                    .clipped()
                                    .cornerRadius(16)
                            } else if phase.error != nil {
                                ZStack {
                                    useTintAsCardBackground ? Color.clear : product.tintColor
                                    Image(systemName: "photo")
                                        .foregroundColor(walnut.opacity(0.2))
                                        .font(.system(size: 20))
                                }
                                .frame(height: 135)
                                .cornerRadius(16)
                            } else {
                                ZStack {
                                    useTintAsCardBackground ? Color.clear : product.tintColor
                                    ProgressView()
                                        .tint(walnut)
                                }
                                .frame(height: 135)
                                .cornerRadius(16)
                            }
                        }
                        .frame(height: 135)
                        .background(useTintAsCardBackground ? Color.clear : product.tintColor)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(tan.opacity(0.2), lineWidth: 1)
                        )
                        
                        // Top-Right: Wishlist Heart (Glassmorphic)
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
                                .font(.system(size: 11, weight: .semibold))
                                .padding(6)
                                .background(BlurView(style: .systemThinMaterialLight))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        .padding(6)
                        .scaleEffect(wishlistManager.isWishlisted(product: product) ? 1.12 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: wishlistManager.isWishlisted(product: product))
                        .buttonStyle(BorderlessButtonStyle()) // Prevent nested tap interference
                    }
                    .frame(height: 135)
                    
                    Spacer(minLength: 8)
                    
                    // 2. Metadata & Title (Fixed Height: 44pt)
                    VStack(alignment: .leading, spacing: 2) {
                        // Subheading
                        let rawBrand = product.brand?.uppercased() ?? ""
                        let cleanedBrand = rawBrand.contains("WILLIAMS SONOMA") ? "" : rawBrand
                        let metaText = product.material?.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").capitalized ?? cleanedBrand
                        Text(metaText.isEmpty ? " " : metaText)
                            .font(.system(size: 8, weight: .bold))
                            .kerning(1)
                            .foregroundColor(terracotta)
                            .lineLimit(1)
                        
                        // Title (Serif design)
                        Text(product.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(walnut)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(height: 32, alignment: .topLeading)
                    }
                    .frame(height: 44)
                    .padding(.horizontal, 2)
                    
                    Spacer(minLength: 6)
                    
                    // 3. Pricing Line (Fixed Height: 18pt)
                    HStack(spacing: 6) {
                        Text((product.price ?? 0.0).formatted(.currency(code: "USD")))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(walnut)
                    }
                    .frame(height: 18)
                    .padding(.horizontal, 2)
                }
            }
            .buttonStyle(PlainButtonStyle()) // Maintain high-fidelity design without system tints
            
            Spacer(minLength: 8)
            
            // 4. Actions Toolbar (Fixed Height: 32pt) - Expanded ADD/STEPPER only!
            HStack(spacing: 0) {
                // ADD / STEPPER CAPSULE
                if quantity == 0 {
                    Button(action: onAdd) {
                        HStack(spacing: 2) {
                            Image(systemName: "plus")
                                .font(.system(size: 8, weight: .bold))
                            Text("Add")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(walnut)
                        .cornerRadius(16)
                    }
                    .buttonStyle(SpringPressButtonStyle())
                } else {
                    HStack {
                        Button(action: onRemove) {
                            Image(systemName: "minus")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(walnut)
                                .frame(width: 28, height: 28)
                                .background(Color.clear)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(SpringPressButtonStyle())
                        
                        Spacer()
                        
                        Text("\(quantity)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(walnut)
                            .frame(minWidth: 16)
                            .fixedSize()
                        
                        Spacer()
                        
                        Button(action: onAdd) {
                            Image(systemName: "plus")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(walnut)
                                .frame(width: 28, height: 28)
                                .background(Color.clear)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(SpringPressButtonStyle())
                    }
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(tan.opacity(0.5), lineWidth: 1)
                    )
                }
            }
            .frame(height: 32)
        }
        .padding(10)
        .frame(height: 272) // Mathematically fixed card height for 100% visual alignment!
        .background(useTintAsCardBackground ? product.tintColor : Color.white)
        .cornerRadius(24) // Elegant Rounded Corners
        .shadow(color: warmShadow, radius: 8, x: 0, y: 4) // Soft, lightweight organic shadow glow
    }
}
