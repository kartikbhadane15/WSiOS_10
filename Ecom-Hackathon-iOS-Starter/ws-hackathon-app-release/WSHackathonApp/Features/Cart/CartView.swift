//
//  CartView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @State private var showOrderSummary = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                if viewModel.isEmptyCart {
                    VStack {
                        EmptyCartView {
                            tabBarVM.selectTab(.home)
                        }
                        Spacer()
                    }
                } else {
                    VStack(spacing: 0) {
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                if viewModel.hesitationDetector.isHesitating {
                                    nudgeCard
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }

                                ForEach(viewModel.items) { item in
                                    CartItemRow(
                                        item: item,
                                        onAdd: { viewModel.add(item) },
                                        onRemove: { viewModel.removeItem(item) }
                                    )
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
                            }
                            .padding(16)
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
                                showOrderSummary = true
                            }) {
                                Text(AppStrings.Cart.checkoutButton)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .sheet(isPresented: $showOrderSummary) {
                                OrderSummaryView(viewModel: viewModel)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16.0)
                        .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: -2)
                    }
                }
            }
            .navigationTitle(AppStrings.Cart.title)
        }
        .onAppear {
            Task {
                viewModel.bind(repository: cartRepository)
            }
            viewModel.hesitationDetector.startCartTimer()
        }
        .onDisappear {
            viewModel.hesitationDetector.cancelCartTimer()
        }
        .onChange(of: tabBarVM.selectedTab) { newTab in
            let name: String
            switch newTab {
            case .cart: name = "cart"
            case .home: name = "home"
            default: name = "other"
            }
            viewModel.hesitationDetector.recordTabSwitch(to: name)
        }
    }

    private var nudgeCard: some View {
        HStack(spacing: 10) {
            Text("⭐")
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 2) {
                Text("Hesitating?")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Text("This product was bought by 38 people this week.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(red: 255/255, green: 249/255, blue: 230/255))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 245/255, green: 200/255, blue: 66/255), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    @ViewBuilder
    private var giftingSection: some View {
        VStack(spacing: 0) {
            Picker("Order Type", selection: $viewModel.isGift) {
                Text("For Myself").tag(false)
                Text("It's a Gift 🎁").tag(true)
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.isGift) { _ in
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
                        .onChange(of: viewModel.giftMessage) { newValue in
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
}
