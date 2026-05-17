//
//  EmptyWishlistView.swift
//  WSHackathonApp
//

import SwiftUI

struct EmptyWishlistView: View {
    let action: () -> Void
    @State private var isBreathing = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundColor(Color(.systemGray3))
                .scaleEffect(isBreathing ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isBreathing)
            
            Text(AppStrings.Wishlist.emptyMessage)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Button(action: action) {
                Text(AppStrings.Wishlist.emptyButton)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6).ignoresSafeArea())
        .onAppear {
            isBreathing = true
        }
    }
}
