//
//  CollectionsEmptyStateSheet.swift
//  WSHackathonApp
//

import SwiftUI

struct CollectionsEmptyStateSheet: View {
    @Environment(\.dismiss) var dismiss
    let onBrowse: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Premium Illustration / Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .opacity(isAnimating ? 0.5 : 1.0)
                
                Image(systemName: "heart.text.square")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .symbolEffect(.bounce, value: isAnimating)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            VStack(spacing: 12) {
                Text("Your Wishlist is empty ✨")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Save items to your Wishlist before creating a collection.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 16) {
                Button(action: {
                    dismiss()
                    onBrowse()
                }) {
                    Text("Browse Products")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(14)
                }
                
                Button(action: { dismiss() }) {
                    Text("Maybe Later")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(.vertical, 40)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
