//
//  WishlistCardView.swift
//  WSHackathonApp
//

import SwiftUI

struct WishlistCardView: View {
    let item: WishlistItem
    let isSelectMode: Bool
    let isSelected: Bool
    var isAlreadyInCollection: Bool = false
    var showMoveToCart: Bool = true
    
    let onToggleSelect: () -> Void
    let onMoveToCart: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if isSelectMode {
                if isAlreadyInCollection {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.4))
                        .font(.title3)
                        .padding(.top, 24)
                } else {
                    Button(action: onToggleSelect) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .blue : .gray)
                            .font(.title3)
                            .padding(.top, 24)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Image
            AsyncImage(url: item.product.imageURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if phase.error != nil {
                    ZStack { Color(.systemGray5); Image(systemName: "photo").foregroundColor(.gray) }
                } else {
                    ZStack { Color(.systemGray5); ProgressView() }
                }
            }
            .frame(width: 90, height: 90)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text(item.currentPrice.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(item.currentPrice < item.originalPrice ? .red : .primary)
                    
                    if item.currentPrice < item.originalPrice {
                        Text(item.originalPrice.formatted(.currency(code: "USD")))
                            .font(.caption2)
                            .strikethrough()
                            .foregroundColor(.gray)
                    }
                }
                
                if isSelectMode && isAlreadyInCollection {
                    Text("✓ Already in Collection")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }

                if !isSelectMode {
                    HStack(spacing: 12) {
                        if showMoveToCart {
                            Button(action: item.isOutOfStock ? {} : onMoveToCart) {
                                Text(item.isOutOfStock ? "Notify Me" : "Move to Cart")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(item.isOutOfStock ? Color(.systemGray4) : Color.black)
                                    .foregroundColor(item.isOutOfStock ? .gray : .white)
                                    .cornerRadius(4)
                            }
                            .disabled(item.isOutOfStock)
                        }
                        
                        Button(action: onRemove) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(isSelectMode && isSelected ? Color.blue.opacity(0.05) : Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(isSelectMode && isSelected ? 0.1 : 0.03), radius: isSelectMode && isSelected ? 12 : 8, x: 0, y: isSelectMode && isSelected ? 6 : 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelectMode && isSelected ? Color.blue.opacity(0.5) : Color(.systemGray6), lineWidth: 1)
        )
        .scaleEffect(isSelectMode && isSelected ? 0.98 : 1.0)
        .opacity((item.isOutOfStock || (isSelectMode && isAlreadyInCollection)) ? 0.6 : 1.0)
        .onTapGesture {
            if isSelectMode && !isAlreadyInCollection {
                onToggleSelect()
            }
        }
    }
}
