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
                                ForEach(viewModel.items) { item in
                                    CartItemRow(
                                        item: item,
                                        onAdd: { viewModel.add(item) },
                                        onRemove: { viewModel.removeItem(item) }
                                    )
                                }

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
                        VStack(spacing: 12) {
                            
                            HStack {
                                Text(AppStrings.Cart.total)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(viewModel.totalPriceText)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
                            Button(action: {
                                // TODO: - Implement checkout flow
                            }) {
                                Text(AppStrings.Cart.checkoutButton)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
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
        }
    }
}
