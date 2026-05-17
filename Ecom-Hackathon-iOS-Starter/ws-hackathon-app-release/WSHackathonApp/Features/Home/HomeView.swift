//
//  HomeView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var toastManager: ToastManager
    
    // Luxury Editorial Theme Colors Aligned with Lovable AI Specifications
    private let ivory = Color(red: 250/255, green: 247/255, blue: 240/255)     // #FAF7F0 Base page background
    private let walnut = Color(red: 42/255, green: 37/255, blue: 32/255)       // #2A2520 Ink - deep near-black primary typography
    private let tan = Color(red: 221/255, green: 211/255, blue: 194/255)       // #DDD3C2 Stone Warm (borders, muted areas)
    private let cardBg = Color.white                                           // #FFFFFF Card surfaces sit on Card White
    private let terracotta = Color(red: 107/255, green: 82/255, blue: 64/255)  // #6B5240 Walnut rich brown accent
    private let warmShadow = Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.04) // Soft shadow
    
    // Gradients from Lovable AI Color Palette
    private let heroStart = Color(red: 239/255, green: 227/255, blue: 206/255)  // #EFE3CE Warm cream
    private let heroEnd = Color(red: 217/255, green: 194/255, blue: 164/255)    // #D9C2A4 Warm sand
    private let stoneStart = Color(red: 235/255, green: 227/255, blue: 208/255) // #EBE3D0 Warm stone
    private let stoneEnd = Color(red: 212/255, green: 199/255, blue: 176/255)   // #D4C7B0 Stone warm
    private let coffeeStart = Color(red: 223/255, green: 208/255, blue: 184/255)// #DFD0B8 Warm coffee
    private let coffeeEnd = Color(red: 184/255, green: 160/255, blue: 130/255)  // #B8A082 Coffee dark
    private let walnutStart = Color(red: 126/255, green: 100/255, blue: 80/255) // #7E6450 Walnut start
    private let walnutEnd = Color(red: 79/255, green: 62/255, blue: 48/255)     // #4F3E30 Walnut end
    private let inkStart = Color(red: 58/255, green: 53/255, blue: 48/255)      // #3A3530 Ink start
    private let inkEnd = Color(red: 26/255, green: 22/255, blue: 18/255)        // #1A1612 Ink end
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                ivory
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. Static Top Header (NOT floating, NOT overlapping! Search is exactly at the top)
                    staticTopHeader
                    
                    // 2. Scrollable Content
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .tint(walnut)
                            .scaleEffect(1.2)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 28) { // Regular editorial rhythm between major sections
                                
                                if !viewModel.searchText.isEmpty {
                                    // MARK: - Active Search Grid View
                                    searchGridSection
                                } else {
                                    // MARK: - 6-Section Editorial Home
                                    
                                    // Section 1: Tall Premium Hero (with top padding for breathing space from search bar)
                                    heroSection
                                        .padding(.top, 16)
                                    
                                    // Section 2: Editor's Picks (Horizontal rail)
                                    editorsPicksSection
                                    
                                    // Section 3: Collections (Horizontal rail)
                                    collectionsSection
                                    
                                    // Section 4: Quietly Beautiful (2-Column compact grid)
                                    quietlyBeautifulSection
                                    
                                    // Section 5: Curated Spaces (Vertical mosaic)
                                    curatedSpacesSection
                                    
                                    // Section 6: Continue Exploring (List view)
                                    continueExploringSection
                                }
                                
                                // Bottom padding so tab bar doesn't overlap
                                Color.clear.frame(height: 30)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    viewModel.bind(
                        cartRepository: cartRepository,
                        registryRepository: registryRepository
                    )
                    await viewModel.fetchProducts()
                }
            }
        }
    }
    
    // MARK: - Subviews & Sections
    
    // 1. Static Top Header (Directly at top, de-overlapped)
    private var staticTopHeader: some View {
        VStack(spacing: 12) {
            // Top Bar Button Section (Wishlist button floating on the right)
            HStack {
                Spacer()
                
                // Wishlist Bar Button (leading to WishlistView)
                NavigationLink(destination: WishlistView()) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "heart")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(walnut)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                        
                        if !wishlistManager.wishlistItems.isEmpty || wishlistManager.collections.contains(where: { !$0.items.isEmpty }) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 2, y: -2)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Large Native iOS Title "Home" (Placed BELOW the bar button section)
            HStack {
                Text("Home")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(walnut)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Glass Search Field Capsule
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(walnut.opacity(0.4))
                    .font(.system(size: 13, weight: .bold))
                
                TextField("Search the edit...", text: $viewModel.searchText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(walnut)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(walnut.opacity(0.4))
                        }
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(Color.white.opacity(0.8))
            .cornerRadius(19)
            .overlay(
                RoundedRectangle(cornerRadius: 19)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
        .padding(.top, 12) // safe status bar inset
        .padding(.bottom, 14)
        .background(
            LinearGradient(
                colors: [ivory, ivory.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // 2. Active Search Grid View
    private var searchGridSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Search Results for \"\(viewModel.searchText)\"")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(walnut)
                .padding(.horizontal, 16)
            
            // Strict iOS spacing: 12pt horizontal grid spacing
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filteredProducts) { product in
                    ProductCardView(
                        product: product,
                        quantity: viewModel.quantity(for: product),
                        onAdd: { viewModel.addToCart(product) },
                        onRemove: { viewModel.removeFromCart(product) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // 3. Section 1: Hero Collection Card (Overlapping collage fully bounded and centered)
    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            // Background Collage of Floating Products (renders behind text/button but on the right side)
            HStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    // 1. Wood Cutting Board (Top Right)
                    if let board = productById("2505456") {
                        cutoutRect(url: board.imageURL)
                            .frame(width: 110, height: 140)
                            .rotationEffect(.degrees(12))
                            .shadow(color: warmShadow, radius: 8, x: 4, y: 4)
                            .offset(x: 35, y: -70)
                    }
                    
                    // 2. Serving Bowl (Middle)
                    if let bowl = productById("6247040") {
                        cutoutCircle(url: bowl.imageURL)
                            .frame(width: 110, height: 110)
                            .rotationEffect(.degrees(-8))
                            .shadow(color: warmShadow, radius: 6, x: -3, y: 2)
                            .offset(x: -15, y: 10)
                    }
                    
                    // 3. Olive Oil (Bottom Center)
                    if let oil = productById("5001660") {
                        cutoutCircle(url: oil.imageURL)
                            .frame(width: 80, height: 120)
                            .rotationEffect(.degrees(10))
                            .shadow(color: warmShadow, radius: 5, x: -2, y: 3)
                            .offset(x: -25, y: 110)
                    }
                    
                    // 4. Espresso Cup (Bottom Right)
                    if let cup = productById("1341411") {
                        cutoutCircle(url: cup.imageURL)
                            .frame(width: 90, height: 75)
                            .rotationEffect(.degrees(-12))
                            .shadow(color: warmShadow, radius: 4, x: 2, y: 2)
                            .offset(x: 45, y: 95)
                    }
                }
                .frame(width: 170, height: 310)
                .padding(.trailing, 10)
            }
            .frame(maxHeight: .infinity)
            
            // Left Text & Button Overlays
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 28) // Clean, high-end editorial top margin instead of brand text!
                
                Text("Elevate\nYour\nKitchen")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(walnut)
                    .lineSpacing(2)
                
                Spacer(minLength: 12)
                
                Text("Curated essentials for\nmodern cooking &\nhosting.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(walnut.opacity(0.7))
                    .lineSpacing(2)
                
                Spacer(minLength: 20)
                
                let collProducts = [productById("2505456"), productById("6247040"), productById("5001660"), productById("1341411")].compactMap { $0 }
                
                NavigationLink(destination: CuratedCollectionView(
                    title: "Curated Essentials",
                    products: collProducts,
                    viewModel: viewModel
                )
                .environmentObject(toastManager)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Explore")
                            .font(.system(size: 12, weight: .bold))
                        HStack(spacing: 4) {
                            Text("Collection")
                                .font(.system(size: 12, weight: .bold))
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(walnut)
                    .cornerRadius(24)
                }
                .buttonStyle(SpringPressButtonStyle())
                .padding(.bottom, 24)
            }
            .padding(.leading, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 350) // Premium tall height matching reference exactly!
        .background(
            LinearGradient(
                colors: [heroStart, heroEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32)) // Perfectly cuts/clips all child overflows inside the card boundaries!
        .padding(.horizontal, 16)
    }
    
    // Auxiliary helpers for cutout images
    private func cutoutCircle(url: URL?) -> some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Color.white
            }
        }
        .background(Color.white)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
    }
    
    private func cutoutRect(url: URL?) -> some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Color.white
            }
        }
        .background(Color.white)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white, lineWidth: 2))
    }
    
    // 4. Section 2: Editor's Picks (Horizontal Rail)
    private var editorsPicksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header text (aligned exactly with screen margins)
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("HAND PICKED")
                        .font(.system(size: 9, weight: .bold))
                        .kerning(2)
                        .foregroundColor(walnut.opacity(0.5))
                    
                    Text("Editor's Picks")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(walnut)
                }
            }
            .padding(.horizontal, 16)
            
            // Snapping edge-to-edge scroll view
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) { // strict 12pt card spacing
                    let pickIds = ["2505456", "1341411", "6247040", "181543"]
                    ForEach(pickIds.compactMap { productById($0) }) { product in
                        ProductCardView(
                            product: product,
                            quantity: viewModel.quantity(for: product),
                            onAdd: { viewModel.addToCart(product) },
                            onRemove: { viewModel.removeFromCart(product) },
                            useTintAsCardBackground: true
                        )
                        .frame(width: 160) // Mathematically locks width. Height is locked at 272 inside ProductCardView!
                    }
                }
                .padding(.horizontal, 16) // Snapping margin padding (rests exactly on 16pt!)
                .padding(.vertical, 4)
            }
        }
    }
    
    // 5. Section 3: Collections (Horizontal Rail)
    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("COLLECTION")
                        .font(.system(size: 9, weight: .bold))
                        .kerning(2)
                        .foregroundColor(walnut.opacity(0.5))
                    
                    Text("The Edit")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(walnut)
                }
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) { // 12pt card spacing
                    
                    // Card 1: Hosting Essentials
                    collectionCard(
                        title: "Hosting Essentials",
                        subtitle: "For the table you set",
                        bgGradients: [stoneStart, stoneEnd],
                        isDarkCard: false,
                        p1: productById("6247040"),
                        p2: productById("2505456")
                    )
                    
                    // Card 2: Coffee Corner
                    collectionCard(
                        title: "Coffee Corner",
                        subtitle: "Slow mornings",
                        bgGradients: [coffeeStart, coffeeEnd],
                        isDarkCard: false,
                        p1: productById("1341411"),
                        p2: productById("8381456")
                    )
                    
                    // Card 3: Chef Favorites (Dark Card)
                    collectionCard(
                        title: "Chef Favorites",
                        subtitle: "Professional tools",
                        bgGradients: [walnutStart, walnutEnd],
                        isDarkCard: true,
                        p1: productById("8227593"),
                        p2: productById("5001660")
                    )
                    
                    // Card 4: Sunday Brunch
                    collectionCard(
                        title: "Sunday Brunch",
                        subtitle: "Weekend ease",
                        bgGradients: [heroStart, heroEnd],
                        isDarkCard: false,
                        p1: productById("6247040"),
                        p2: productById("1341411")
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // Collections Horizontal Card View
    private func collectionCard(title: String, subtitle: String, bgGradients: [Color], isDarkCard: Bool = false, p1: ProductItem?, p2: ProductItem?) -> some View {
        let titleColor = isDarkCard ? Color.white : walnut
        let subColor = isDarkCard ? Color.white.opacity(0.7) : walnut.opacity(0.6)
        let tagColor = isDarkCard ? Color.white.opacity(0.5) : walnut.opacity(0.4)
        
        return HStack(spacing: 12) {
            // Text left
            VStack(alignment: .leading, spacing: 8) {
                Text("COLLECTION")
                    .font(.system(size: 8, weight: .bold))
                    .kerning(1.5)
                    .foregroundColor(tagColor)
                
                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(titleColor)
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(subColor)
                
                Spacer()
                
                let collProducts = [p1, p2].compactMap { $0 }
                
                NavigationLink(destination: CuratedCollectionView(
                    title: title,
                    products: collProducts,
                    viewModel: viewModel
                )
                .environmentObject(toastManager)) {
                    HStack(spacing: 4) {
                        Text("Shop")
                            .font(.system(size: 11, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8, weight: .bold))
                    }
                    .foregroundColor(titleColor)
                }
            }
            .padding(.vertical, 16)
            .padding(.leading, 16)
            .frame(width: 140, alignment: .leading)
            
            // Collage circles right
            VStack(spacing: -12) {
                if let first = p1 {
                    AsyncImage(url: first.imageURL) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill()
                        } else {
                            Color.white
                        }
                    }
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                
                if let second = p2 {
                    AsyncImage(url: second.imageURL) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill()
                        } else {
                            Color.white
                        }
                    }
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .offset(x: -15)
                }
            }
            .padding(.trailing, 12)
        }
        .frame(width: 250, height: 155)
        .background(
            LinearGradient(colors: bgGradients, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(24)
        .shadow(color: warmShadow, radius: 5, x: 0, y: 3)
    }
    
    // 6. Section 4: Quietly Beautiful (2-Column Grid)
    private var quietlyBeautifulSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("NEW THIS WEEK")
                        .font(.system(size: 9, weight: .bold))
                        .kerning(2)
                        .foregroundColor(walnut.opacity(0.5))
                    
                    Text("Quietly Beautiful")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(walnut)
                }
            }
            .padding(.horizontal, 16)
            
            // Display first 4 items in a strict 12pt grid
            let items = Array(viewModel.products.prefix(4))
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { product in
                    ProductCardView(
                        product: product,
                        quantity: viewModel.quantity(for: product),
                        onAdd: { viewModel.addToCart(product) },
                        onRemove: { viewModel.removeFromCart(product) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // 7. Section 5: Curated Spaces (Mosaic Grid)
    private var curatedSpacesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("MOODBOARD")
                        .font(.system(size: 9, weight: .bold))
                        .kerning(2)
                        .foregroundColor(walnut.opacity(0.5))
                    
                    Text("Curated Spaces")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(walnut)
                }
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                // Card 1: Coffee Ritual (Coffee gradient)
                curatedSpaceCard(
                    ritualTitle: "Coffee Ritual",
                    description: "Three pieces, one slow morning",
                    bgGradient: [coffeeStart, coffeeEnd],
                    textColor: walnut,
                    isDark: false,
                    items: [productById("1341411"), productById("8381456"), productById("8227593")]
                )
                
                // Card 2: Hosting Night (Stone gradient)
                curatedSpaceCard(
                    ritualTitle: "Hosting Night",
                    description: "A table that lingers",
                    bgGradient: [stoneStart, stoneEnd],
                    textColor: walnut,
                    isDark: false,
                    items: [productById("2505456"), productById("6247040"), productById("6121370")]
                )
                
                // Card 3: Minimal Dining (Near-black Ink gradient)
                curatedSpaceCard(
                    ritualTitle: "Minimal Dining",
                    description: "Everything you need, nothing you don't",
                    bgGradient: [inkStart, inkEnd],
                    textColor: .white,
                    isDark: true,
                    items: [productById("181543"), productById("5001660"), productById("9670912")]
                )
            }
            .padding(.horizontal, 16)
        }
    }
    
    // Curated Space Mosaic Card View
    private func curatedSpaceCard(ritualTitle: String, description: String, bgGradient: [Color], textColor: Color, isDark: Bool, items: [ProductItem?]) -> some View {
        HStack(spacing: 16) {
            // Text Details Left
            VStack(alignment: .leading, spacing: 8) {
                Text("RITUAL")
                    .font(.system(size: 8, weight: .bold))
                    .kerning(1.5)
                    .foregroundColor(textColor.opacity(0.5))
                
                Text(ritualTitle)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(textColor)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(textColor.opacity(0.7))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                let spaceProducts = items.compactMap { $0 }
                
                NavigationLink(destination: CuratedCollectionView(
                    title: ritualTitle,
                    products: spaceProducts,
                    viewModel: viewModel
                )
                .environmentObject(toastManager)) {
                    HStack(spacing: 4) {
                        Text("Shop")
                            .font(.system(size: 11, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8, weight: .bold))
                    }
                    .foregroundColor(isDark ? walnut : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isDark ? .white : walnut)
                    .cornerRadius(12)
                }
            }
            .padding(.vertical, 20)
            .padding(.leading, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Mosaic Right (Vertical capsule + floating left circle)
            ZStack {
                let list = items.compactMap { $0 }
                
                // 1. Right side: Vertical Capsule holding 2 items
                Capsule()
                    .fill(isDark ? Color.white.opacity(0.15) : Color.white.opacity(0.4))
                    .frame(width: 58, height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            if list.count > 1 {
                                AsyncImage(url: list[1].imageURL) { phase in
                                    if let img = phase.image {
                                        img.resizable().scaledToFill()
                                    } else {
                                        Color.white
                                    }
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            }
                            if list.count > 2 {
                                AsyncImage(url: list[2].imageURL) { phase in
                                    if let img = phase.image {
                                        img.resizable().scaledToFill()
                                    } else {
                                        Color.white
                                    }
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            }
                        }
                    )
                    .offset(x: 25)
                
                // 2. Left side: Floating circle holding the primary item, overlapping slightly
                if list.count > 0 {
                    AsyncImage(url: list[0].imageURL) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill()
                        } else {
                            Color.white
                        }
                    }
                    .frame(width: 58, height: 58)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(isDark ? .clear : bgGradient[0], lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: -3, y: 3)
                    .offset(x: -25)
                }
            }
            .frame(width: 120, height: 160)
            .padding(.trailing, 10)
        }
        .frame(height: 170)
        .background(
            LinearGradient(colors: bgGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(24)
        .shadow(color: warmShadow, radius: 6, x: 0, y: 3)
    }
    
    // 8. Section 6: Continue Exploring (List view)
    private var continueExploringSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("FOR YOU")
                        .font(.system(size: 9, weight: .bold))
                        .kerning(2)
                        .foregroundColor(walnut.opacity(0.5))
                    
                    Text("Continue Exploring")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(walnut)
                }
                
                Spacer()
                
                NavigationLink(destination: CuratedCollectionView(
                    title: "All Products",
                    products: viewModel.products,
                    viewModel: viewModel
                )
                .environmentObject(toastManager)) {
                    Text("See all")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(walnut)
                }
            }
            .padding(.horizontal, 16)
            
            // Render remaining products in horizontal row panels
            let remList = viewModel.products.count > 4 ? Array(viewModel.products.suffix(from: 4)) : viewModel.products
            
            VStack(spacing: 12) {
                ForEach(remList) { product in
                    HStack(spacing: 12) {
                        NavigationLink(destination: ProductDetailSheet(
                            product: product,
                            onAdd: {
                                viewModel.addToCart(product)
                            },
                            onRemove: {
                                viewModel.removeFromCart(product)
                            },
                            onAddToRegistry: {},
                            onRemoveFromRegistry: {},
                            canAddToRegistry: false
                        )
                        .environmentObject(wishlistManager)
                        .environmentObject(toastManager)
                        .environmentObject(cartRepository)
                        .environmentObject(registryRepository)) {
                            HStack(spacing: 12) {
                                // Left: Circle Image
                                AsyncImage(url: product.imageURL) { phase in
                                    if let img = phase.image {
                                        img.resizable().scaledToFill()
                                    } else {
                                        ZStack {
                                            Color(.systemGray6)
                                            Image(systemName: "photo").font(.caption)
                                        }
                                    }
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                
                                // Center Info
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(product.title)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(walnut)
                                        .lineLimit(1)
                                    
                                    Text(product.brand?.capitalized ?? "Williams Sonoma")
                                        .font(.system(size: 11))
                                        .foregroundColor(walnut.opacity(0.5))
                                }
                                
                                Spacer()
                                
                                // Price
                                Text((product.price ?? 0.0).formatted(.currency(code: "USD")))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(walnut)
                                    .padding(.trailing, 8)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Add Button (Simple circle plus) or Stepper
                        let qty = viewModel.quantity(for: product)
                        if qty == 0 {
                            Button(action: {
                                viewModel.addToCart(product)
                                toastManager.show(message: "Added to Cart 🛒")
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(walnut)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(SpringPressButtonStyle())
                        } else {
                            HStack(spacing: 0) {
                                Button(action: {
                                    viewModel.removeFromCart(product)
                                }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(walnut)
                                        .frame(width: 28, height: 32)
                                        .background(Color.clear)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(SpringPressButtonStyle())
                                
                                Text("\(qty)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(walnut)
                                    .frame(minWidth: 16)
                                    .fixedSize()
                                
                                Button(action: {
                                    viewModel.addToCart(product)
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(walnut)
                                        .frame(width: 28, height: 32)
                                        .background(Color.clear)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(SpringPressButtonStyle())
                            }
                            .frame(height: 32)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(tan.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(cardBg)
                    .cornerRadius(20)
                    .shadow(color: warmShadow, radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Utilities
    
    // Search products by ID helper
    private func productById(_ id: String) -> ProductItem? {
        viewModel.products.first(where: { $0.id == id })
    }
}

// MARK: - iOS Native Curated Collection View
struct CuratedCollectionView: View {
    let title: String
    let products: [ProductItem]
    @ObservedObject var viewModel: HomeViewModel
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var toastManager: ToastManager
    
    private let ivory = Color(red: 250/255, green: 247/255, blue: 242/255)
    private let walnut = Color(red: 38/255, green: 26/255, blue: 18/255)
    private let tan = Color(red: 234/255, green: 226/255, blue: 216/255)
    private let cardBg = Color(red: 252/255, green: 250/255, blue: 247/255)
    private let terracotta = Color(red: 194/255, green: 125/255, blue: 86/255)
    
    var body: some View {
        ZStack {
            ivory.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Custom Navigation Bar (with premium circular blue chevron back button on the left)
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
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // 2. Large Page Title (placed BELOW the bar button section)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(walnut)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 12)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        let columns = [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(products) { product in
                                ProductCardView(
                                    product: product,
                                    quantity: viewModel.quantity(for: product),
                                    onAdd: {
                                        viewModel.addToCart(product)
                                        toastManager.show(message: "Added to Cart 🛒")
                                    },
                                    onRemove: { viewModel.removeFromCart(product) }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
