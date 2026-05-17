//
//  CartItemRow.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import SwiftUI

struct CartItemRow: View {
    
    let item: CartItem
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onMoveToWishlist: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            let url = item.imageURL
            // MARK: - Image
            CustomAsyncImage(url: url)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()
            
            // MARK: - Info
            VStack(alignment: .leading, spacing: 6) {
                
                Text(item.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 42/255, green: 37/255, blue: 32/255))
                    .lineLimit(2)
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 107/255, green: 82/255, blue: 64/255)) // Walnut rich brown accent
                
                Spacer()
                
                // MARK: - Quantity Controls
                HStack(spacing: 12) {
                    Button(action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                    }
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 13, weight: .bold))
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                .font(.title3)
                .foregroundColor(Color(red: 42/255, green: 37/255, blue: 32/255)) // Ink
                
                Button(action: onMoveToWishlist) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                        Text("Move to Wishlist")
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 107/255, green: 82/255, blue: 64/255).opacity(0.8))
                }
                .padding(.top, 4)
            }
            
            Spacer()
            
            // MARK: - Total Price per item
            Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(red: 42/255, green: 37/255, blue: 32/255))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.035), radius: 6, x: 0, y: 3)
    }
}
