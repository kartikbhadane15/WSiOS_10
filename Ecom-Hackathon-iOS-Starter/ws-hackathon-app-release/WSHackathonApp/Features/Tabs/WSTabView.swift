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
    
    init() {
        let appearance = UITabBarAppearance()
        
        // Configure standard tab item badge appearance with clear background and red bullet
        appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = .clear
        appearance.stackedLayoutAppearance.normal.badgeTextAttributes = [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        
        appearance.stackedLayoutAppearance.selected.badgeBackgroundColor = .clear
        appearance.stackedLayoutAppearance.selected.badgeTextAttributes = [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        
        appearance.inlineLayoutAppearance.normal.badgeBackgroundColor = .clear
        appearance.inlineLayoutAppearance.normal.badgeTextAttributes = [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        
        appearance.inlineLayoutAppearance.selected.badgeBackgroundColor = .clear
        appearance.inlineLayoutAppearance.selected.badgeTextAttributes = [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        
        appearance.compactInlineLayoutAppearance.normal.badgeBackgroundColor = .clear
        appearance.compactInlineLayoutAppearance.normal.badgeTextAttributes = [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        
        appearance.compactInlineLayoutAppearance.selected.badgeBackgroundColor = .clear
        appearance.compactInlineLayoutAppearance.selected.badgeTextAttributes = [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        
        // Set the badge position offset slightly downwards so it floats perfectly in the top right
        let offset = UIOffset(horizontal: 0, vertical: 4)
        appearance.stackedLayoutAppearance.normal.badgeTitlePositionAdjustment = offset
        appearance.stackedLayoutAppearance.selected.badgeTitlePositionAdjustment = offset
        appearance.inlineLayoutAppearance.normal.badgeTitlePositionAdjustment = offset
        appearance.inlineLayoutAppearance.selected.badgeTitlePositionAdjustment = offset
        appearance.compactInlineLayoutAppearance.normal.badgeTitlePositionAdjustment = offset
        appearance.compactInlineLayoutAppearance.selected.badgeTitlePositionAdjustment = offset
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $viewModel.selectedTab) {
                ForEach(viewModel.tabs, id: \.rawValue) { tab in
                    view(for: tab)
                        .tabItem {
                            Label(tab.title, systemImage: tab.icon)
                        }
                        .tag(tab)
                        .badge(tab == .cart ? (cartRepository.items.count > 0 ? "•" : nil) : nil)
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
