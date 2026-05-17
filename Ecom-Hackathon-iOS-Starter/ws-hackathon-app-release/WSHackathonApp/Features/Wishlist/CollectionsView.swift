//
//  CollectionsView.swift
//  WSHackathonApp
//

import SwiftUI

struct CollectionsView: View {
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @State private var showingEmptyWishlistSheet = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            if wishlistManager.collections.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.bottom, 8)
                    
                    Text("Create your first collection ✨")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Organize your saved items into beautiful, personal spaces.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        if wishlistManager.wishlistItems.isEmpty {
                            showingEmptyWishlistSheet = true
                        } else {
                            wishlistManager.isShowingCollections = false
                            // Increase delay slightly to ensure transition is well underway
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    wishlistManager.selectedItemIds.removeAll()
                                    wishlistManager.targetCollectionForAdd = nil
                                    wishlistManager.selectionMode = .collection
                                }
                            }
                        }
                    }) {
                        Text("Create Collection")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 32)
                            .background(Color.black)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 16)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(wishlistManager.collections) { collection in
                            NavigationLink(destination: CollectionDetailView(collection: collection)) {
                                CollectionCardView(collection: collection)
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Collections")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if wishlistManager.wishlistItems.isEmpty {
                        showingEmptyWishlistSheet = true
                    } else {
                        wishlistManager.isShowingCollections = false
                        // Increase delay slightly to ensure transition is well underway
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            var transaction = Transaction()
                            transaction.disablesAnimations = true
                            withTransaction(transaction) {
                                wishlistManager.selectedItemIds.removeAll()
                                wishlistManager.targetCollectionForAdd = nil
                                wishlistManager.selectionMode = .collection
                            }
                        }
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showingEmptyWishlistSheet) {
            CollectionsEmptyStateSheet(onBrowse: {
                dismiss()
                tabBarVM.selectTab(.home)
            })
        }
    }
}

struct CollectionCardView: View {
    @EnvironmentObject var wishlistManager: WishlistManager
    let collection: WishlistCollection
    
    var previewItems: [WishlistItem] {
        return Array(collection.items.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail Grid
            thumbnailGrid
                .frame(height: 140)
                .cornerRadius(12)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(collection.items.count) Items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    @ViewBuilder
    private var thumbnailGrid: some View {
        let count = previewItems.count
        
        if count == 0 {
            Rectangle()
                .fill(Color(.systemGray6))
                .overlay(
                    Image(systemName: "photo.on.rectangle")
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.title)
                )
        } else if count == 1 {
            // Case 1: 1 Image
            imageCell(for: previewItems[0])
        } else if count == 2 {
            // Case 2: 2 Images Side-by-side
            HStack(spacing: 2) {
                imageCell(for: previewItems[0])
                imageCell(for: previewItems[1])
            }
        } else {
            // Case 3: 3+ Images (Left half, right top/bottom quarters)
            HStack(spacing: 2) {
                imageCell(for: previewItems[0])
                VStack(spacing: 2) {
                    imageCell(for: previewItems[1])
                    imageCell(for: previewItems[2])
                }
            }
        }
    }
    
    @ViewBuilder
    private func imageCell(for item: WishlistItem) -> some View {
        GeometryReader { proxy in
            AsyncImage(url: item.product.imageURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                } else if phase.error != nil {
                    Rectangle()
                        .fill(Color(.systemGray6))
                } else {
                    ZStack {
                        Color(.systemGray6)
                        ProgressView()
                    }
                }
            }
        }
    }
}
