//
//  WSTabView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

struct WSTabView: View {
    @EnvironmentObject var viewModel: WSTabBarViewModel
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $viewModel.selectedTab) {
                ForEach(viewModel.tabs, id: \.rawValue) { tab in
                    view(for: tab)
                        .tabItem {
                            Label(tab.title, systemImage: tab.icon)
                        }
                        .tag(tab)
                        .badge(tab == .cart ? (viewModel.cartItemCount > 0 ? viewModel.cartItemCount : 0) : 0)
                }
            }
            
            if toastManager.showToast {
                Text(toastManager.toastMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .onAppear {
            CollaborativeCartManager.shared.bind(repository: cartRepository)
        }
    }
    
    @ViewBuilder
    private func view(for tab: TabItem) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .registry:
            RegistryView()
        case .cart:
            CartView()
        case .styleSearch:
            VisualSearchView()
        }
    }
}

#Preview {
    WSTabView()
}
