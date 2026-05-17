//
//  EmptyCartView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 05/04/26.
//
import SwiftUI
struct EmptyCartView: View {
    
    var onContinueShopping: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                HStack {
                    Text(AppStrings.Cart.emptyMessage)
                        .font(.system(size: 16, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(red: 42/255, green: 37/255, blue: 32/255))
                    Spacer()
                }.padding(16)
                 
                Button(action: {
                    onContinueShopping?()
                }) {
                    HStack {
                        Text(AppStrings.Cart.emptyButton)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 42/255, green: 37/255, blue: 32/255))
                    .cornerRadius(30)
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.04), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
}
