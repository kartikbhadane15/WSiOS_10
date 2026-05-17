//
//  RegistryView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

enum RegistryRoute: Hashable {
    case create
    case success
}

struct RegistryView: View {
    
    @StateObject private var viewModel = RegistryViewModel()
    
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    // Luxury Editorial Theme Colors Aligned with Lovable AI Specifications
    private let ivory = Color(red: 250/255, green: 247/255, blue: 240/255)     // #FAF7F0 Base page background
    private let walnut = Color(red: 42/255, green: 37/255, blue: 32/255)       // #2A2520 Ink - deep near-black primary typography
    private let tan = Color(red: 221/255, green: 211/255, blue: 194/255)       // #DDD3C2 Stone Warm (borders, muted areas)
    private let terracotta = Color(red: 107/255, green: 82/255, blue: 64/255)  // #6B5240 Walnut rich brown accent
    
    var body: some View {
        NavigationStack(path: $tabBarVM.registryPath) {
            
            ZStack {
                ivory
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // MARK: - Header Image
                        GeometryReader { geometry in
                            Image(AppImages.Registry.header)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 200)
                                .clipped()
                        }
                        .frame(height: 200)
                        
                        // MARK: - Content
                        VStack(spacing: 16) {
                            
                            if viewModel.hasRegistry {
                                
                                registryHeader
                                
                                if viewModel.hasItems {
                                    registryItemsList
                                } else {
                                    emptyItemsView
                                }
                                
                            } else {
                                registryCard
                                instructionCard
                            }
                        }
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle(AppStrings.Registry.title)
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - Navigation
            
            .navigationDestination(for: RegistryRoute.self) { route in
                switch route {
                case .create:
                    CreateRegistryView()
                    
                case .success:
                    RegistrySuccessView()
                }
            }
        }
        .onAppear {
            viewModel.bind(repository: registryRepo)
        }
    }
}

// MARK: - Components
private extension RegistryView {
    
    var registryCard: some View {
        VStack(spacing: 0) {
            
            Button {
                tabBarVM.registryPath.append(.create)
            } label: {
                createRegistryButton
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.035), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
    }
    
    var createRegistryButton: some View {
        HStack(spacing: 12) {
            Image(systemName: AppImages.Registry.plus)
                .foregroundColor(walnut)
            Text(AppStrings.Registry.create)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(walnut)
            Spacer()
            Image(systemName: AppImages.Registry.chevron)
                .foregroundColor(terracotta.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    var instructionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(AppStrings.Registry.topReasons)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(walnut)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(viewModel.instructions.enumerated()), id: \.element.id) { index, item in
                    instructionRow(
                        title: item.title,
                        description: item.description
                    )
                    if index != viewModel.instructions.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.035), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
    }
    
    func instructionRow(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(walnut)
            
            Text(description)
                .font(.system(size: 11))
                .foregroundColor(terracotta.opacity(0.7))
        }
    }
    
    var emptyItemsView: some View {
        Text(AppStrings.Registry.noItemsAdded)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(terracotta.opacity(0.6))
            .padding()
    }
    
    var registryItemsList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.items) { item in
                RegistryItemRow(
                    viewModel: RegistryItemRowViewModel(
                        item: item,
                        registryRepo: registryRepo,
                        cartRepo: cartRepo,
                        tabbarVM: tabBarVM
                    )
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    var registryHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(viewModel.displayTitle)
                .font(.headline)
            
            Text(viewModel.displayDate)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button("Delete Registry") {
                viewModel.deleteRegistry(using: registryRepo)
            }
            .font(.caption)
            .foregroundColor(.red)
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.035), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
    }
}

