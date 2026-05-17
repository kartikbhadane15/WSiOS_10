//
//  CartView.swift
//  WSHackathonApp
//

import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @State private var showOrderSummary = false
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var registryRepository: RegistryRepository
    @State private var recommendedProducts: [ProductItem] = [
        ProductItem(id: "1341411", title: "Staub Enameled Cast Iron Round Cocotte", price: 470.0, path: "media/staub_cocotte.jpg", brand: "Staub"),
        ProductItem(id: "8381456", title: "Cuisinart PerfecTemp Coffee Maker", price: 119.95, path: "media/cuisinart_coffeemaker.jpg", brand: "Cuisinart"),
        ProductItem(id: "8227593", title: "Hold Everything Lazy Susan", price: 59.95, path: "media/lazysusan.jpg", brand: "Hold Everything")
    ]

    // Luxury Editorial Theme Colors Aligned with Lovable AI Specifications
    private let ivory = Color(red: 250/255, green: 247/255, blue: 240/255)     // #FAF7F0 Base page background
    private let walnut = Color(red: 42/255, green: 37/255, blue: 32/255)       // #2A2520 Ink - deep near-black primary typography
    private let tan = Color(red: 221/255, green: 211/255, blue: 194/255)       // #DDD3C2 Stone Warm (borders, muted areas)
    private let cardBg = Color.white                                           // #FFFFFF Card surfaces sit on Card White
    private let terracotta = Color(red: 107/255, green: 82/255, blue: 64/255)  // #6B5240 Walnut rich brown accent
    private let warmShadow = Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.04) // Soft shadow

    private var staticTopHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
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
            
            HStack {
                Text(AppStrings.Cart.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(walnut)
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 10)
    }

    @ObservedObject var addressManager = AddressManager.shared

    private var addressCardSection: some View {
        HStack(spacing: 12) {
            // Location Pin Icon
            ZStack {
                Circle()
                    .fill(walnut.opacity(0.06))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(terracotta)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                if let active = addressManager.activeAddress {
                    Text(active.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(walnut)
                    
                    Text(active.fullAddressString)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("Select Delivery Address")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(walnut)
                    
                    Text("Add an address for seamless shipping")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // "Change" Button
            NavigationLink(destination: AddressManagementView()) {
                Text("Change")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(walnut)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: warmShadow, radius: 6, x: 0, y: 3)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ivory
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    staticTopHeader
                    
                    addressCardSection
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                    
                    if viewModel.isEmptyCart {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 24) {
                                EmptyCartView {
                                    tabBarVM.selectTab(.home)
                                }
                                .padding(.top, 16)
                                
                                if !recommendedProducts.isEmpty {
                                    VStack(alignment: .leading, spacing: 14) {
                                        Text("YOU MAY ALSO LIKE")
                                            .font(.system(size: 10, weight: .bold))
                                            .kerning(2)
                                            .foregroundColor(walnut.opacity(0.5))
                                            .padding(.horizontal, 4)
                                        
                                        VStack(spacing: 12) {
                                            ForEach(recommendedProducts) { product in
                                                HStack(spacing: 12) {
                                                    NavigationLink(destination: ProductDetailSheet(
                                                        product: product,
                                                        onAdd: {
                                                            cartRepository.add(product: product)
                                                        },
                                                        onRemove: {
                                                            cartRepository.remove(productId: product.id)
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
                                                    
                                                    // Add Button (matching Home tab style)
                                                    Button(action: {
                                                        cartRepository.add(product: product)
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
                                                }
                                                .padding(12)
                                                .background(Color.white)
                                                .cornerRadius(16)
                                                .shadow(color: warmShadow, radius: 6, x: 0, y: 3)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    } else {
                        VStack(spacing: 0) {
                            ScrollView {
                                VStack(spacing: 16) {
                                hesitationCardSection

                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Active Cart")
                                        .font(.headline)
                                        .padding(.horizontal, 4)
                                    
                                    ForEach(viewModel.items) { item in
                                        CartItemRow(
                                            item: item,
                                            onAdd: { viewModel.add(item) },
                                            onRemove: { viewModel.removeItem(item) },
                                            onMoveToWishlist: {
                                                withAnimation {
                                                    // Remove entirely from cart
                                                    for _ in 0..<item.quantity {
                                                        cartRepository.remove(productId: item.id)
                                                    }
                                                    // Add to wishlist
                                                    let pItem = ProductItem(id: item.id, title: item.title, price: item.price, path: item.path)
                                                    wishlistManager.addToWishlist(product: pItem)
                                                    toastManager.show(message: "Moved to Wishlist")
                                                }
                                            }
                                        )
                                    }
                                }

                                giftingSection
                                    .padding(.top, 8)

                                let mergedItems = getMergedBundleItems(for: viewModel.items.map(\.id))
                                BundleStripView(
                                    bundleItems: mergedItems,
                                    cartItemIds: viewModel.items.map(\.id),
                                    onAddBundle: { viewModel.addBundleItems($0) },
                                    onAddSingle: { viewModel.addSingleBundleItem($0) }
                                )

                                // MARK: - Match My Style AR Button
                                Button(action: {
                                }) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 0.0, green: 0.75, blue: 0.95),
                                                            Color(red: 0.2, green: 0.4, blue: 0.9)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 40, height: 40)

                                            Image(systemName: "arkit")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.white)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Match My Style")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.black)

                                            Text("See items on your table in AR")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.white)
                                            .shadow(color: Color(red: 0.0, green: 0.6, blue: 0.9).opacity(0.15), radius: 8, x: 0, y: 2)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.0, green: 0.75, blue: 0.95).opacity(0.4),
                                                        Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.2)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                                }

                                // MARK: - Collaborative Cart Entry Card
                                NavigationLink(destination: CollaborativeLobbyView(viewModel: viewModel)) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 48, height: 48)
                                            
                                            Image(systemName: "person.2.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 20))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Collaborative Shopping")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.black)
                                            
                                            Text("Build a shared cart with your squad")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray.opacity(0.4))
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .shadow(color: Color.blue.opacity(0.08), radius: 10, x: 0, y: 5)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(16)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.hesitationCardState)
                        }

                        // MARK: - Bottom Total View
                        VStack(spacing: 8) {

                            HStack {
                                Text("Subtotal")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Spacer()

                                Text(viewModel.baseTotalText)
                                    .font(.subheadline)
                            }

                            if viewModel.includesGiftWrap {
                                HStack {
                                    Text("Gift Wrap")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Spacer()

                                    Text("+$2.00")
                                        .font(.subheadline)
                                }
                            }

                            HStack {
                                Text(AppStrings.Cart.total)
                                    .font(.headline)

                                Spacer()

                                Text(viewModel.totalPriceText)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }

                            Button(action: {
                                viewModel.didTapCheckout()
                                showOrderSummary = true
                            }) {
                                Text(AppStrings.Cart.checkoutButton)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(walnut)
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                            }
                            .sheet(isPresented: $showOrderSummary) {
                                OrderSummaryView(viewModel: viewModel)
                            }
                        }
                        .padding()
                        .background(cardBg)
                        .cornerRadius(16.0)
                        .shadow(color: warmShadow, radius: 8, x: 0, y: -4)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
        .onAppear {
            Task {
                viewModel.bind(repository: cartRepository)
                await fetchRecommendations()
            }
            viewModel.startCartTimer()
        }
        .onDisappear {
            viewModel.hesitationDetector.cancelCartTimer()
            viewModel.resetSession()
        }
        .onChange(of: tabBarVM.selectedTab) { _, newTab in
            let name: String
            switch newTab {
            case .cart: name = "cart"
            case .home: name = "home"
            default: name = "other"
            }
            viewModel.hesitationDetector.recordTabSwitch(to: name)
        }
    }

    @ViewBuilder
    private var hesitationCardSection: some View {
        switch viewModel.hesitationCardState {
        case .hidden:
            EmptyView()
        case .itemBased(let item):
            HesitationCardView(
                variant: .itemBased(item),
                onDismiss: { viewModel.dismissHesitationCard() },
                onGoToCheckout: nil
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        case .timeBased:
            HesitationCardView(
                variant: .timeBased,
                onDismiss: { viewModel.dismissHesitationCard() },
                onGoToCheckout: {
                    viewModel.didTapCheckout()
                    showOrderSummary = true
                }
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var giftingSection: some View {
        VStack(spacing: 0) {
            Picker("Order Type", selection: $viewModel.isGift) {
                Text("For Myself").tag(false)
                Text("It's a Gift 🎁").tag(true)
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.isGift) { _, _ in
                withAnimation(.easeOut(duration: 0.3)) { }
            }

            if viewModel.isGift {
                VStack(spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("Gift Message")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Spacer()
                    }

                    TextField("Write a message for your loved one", text: $viewModel.giftMessage)
                        .font(.subheadline)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .onChange(of: viewModel.giftMessage) { _, newValue in
                            if newValue.count > 150 {
                                viewModel.giftMessage = String(newValue.prefix(150))
                            }
                        }

                    Text("\(150 - viewModel.giftMessage.count) characters remaining")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Divider()

                    HStack(spacing: 8) {
                        Image(systemName: "gift.fill")
                            .font(.subheadline)
                            .foregroundColor(.black)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Add Gift Wrapping")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)

                            Text("Premium tissue wrap & ribbon")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text("+$2.00")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Toggle("", isOn: $viewModel.includesGiftWrap)
                            .labelsHidden()
                            .tint(.black)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .padding(.top, 8)
            }
        }
    }

    private func fetchRecommendations() async {
        do {
            let dtos: [ProductItemDTO] = try await APIClient.shared.request(Endpoint.products())
            let all = dtos.map { ProductItem(from: $0) }
            if !all.isEmpty {
                let shuffled = all.shuffled()
                // Take 3 random recommendations!
                self.recommendedProducts = Array(shuffled.prefix(3))
            }
        } catch {
            print("Failed to load recommendations: \(error)")
        }
    }
}
