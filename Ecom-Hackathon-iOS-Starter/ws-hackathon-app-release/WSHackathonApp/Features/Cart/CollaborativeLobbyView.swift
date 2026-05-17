import SwiftUI

// MARK: - CollaborativeLobbyView
struct CollaborativeLobbyView: View {
    @ObservedObject var viewModel: CartViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showJoinAlert = false
    @State private var roomCode = ""

    // Shared luxury editorial palette
    private let ivory      = Color(red: 250/255, green: 247/255, blue: 240/255)
    private let walnut     = Color(red: 42/255,  green: 37/255,  blue: 32/255)
    private let tan        = Color(red: 221/255, green: 211/255, blue: 194/255)
    private let terracotta = Color(red: 107/255, green: 82/255,  blue: 64/255)
    private let warmShadow = Color(red: 62/255,  green: 40/255,  blue: 28/255).opacity(0.06)

    var body: some View {
        ZStack {
            ivory.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        headerSection
                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 40)
                }
            }
        }
        .navigationTitle("Collaborative Shopping")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Join Shared Cart", isPresented: $showJoinAlert) {
            TextField("Room Code", text: $roomCode)
                .textInputAutocapitalization(.characters)
            Button("Cancel", role: .cancel) { }
            Button("Join") { joinSession(code: roomCode) }
        } message: {
            Text("Enter the 6-digit room code shared by your friend.")
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .navigationDestination(isPresented: Binding<Bool>(
            get: { viewModel.isShowingCollaborativeCart },
            set: { viewModel.isShowingCollaborativeCart = $0 }
        )) {
            CollaborativeCartView()
        }
        .onAppear {
            if CollaborativeCartManager.shared.currentCartId != nil {
                viewModel.isShowingCollaborativeCart = true
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(tan.opacity(0.45))
                    .frame(width: 100, height: 100)
                Image(systemName: "person.2.fill")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(walnut.opacity(0.6))
            }
            .shadow(color: warmShadow, radius: 12, x: 0, y: 6)

            VStack(spacing: 8) {
                Text("Shop Better, Together")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(walnut)

                Text("Build your dream cart with friends in\nreal-time. React, comment, and decide.")
                    .font(.system(size: 14))
                    .foregroundColor(walnut.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 14) {
            LobbyActionRow(
                title: "Start a New Session",
                subtitle: "Invite friends to build this cart",
                icon: "plus.circle.fill",
                walnut: walnut,
                tan: tan,
                terracotta: terracotta,
                warmShadow: warmShadow
            ) {
                startNewSession()
            }

            LobbyActionRow(
                title: "Join Existing Session",
                subtitle: "Enter a room code from a friend",
                icon: "link.circle.fill",
                walnut: walnut,
                tan: tan,
                terracotta: terracotta,
                warmShadow: warmShadow
            ) {
                showJoinAlert = true
            }
        }
    }

    // MARK: - Logic
    private func startNewSession() {
        let cartId = UUID().uuidString.prefix(6).uppercased()
        CollaborativeCartManager.shared.createCart(cartId: String(cartId))
        for item in viewModel.items {
            let product = ProductItem(id: item.id, title: item.title, price: item.price, path: item.path)
            CollaborativeCartManager.shared.addItem(product: product, quantity: item.quantity)
        }
        viewModel.isShowingCollaborativeCart = true
    }

    private func joinSession(code: String) {
        guard !code.isEmpty else { return }
        CollaborativeCartManager.shared.joinCart(cartId: code)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if CollaborativeCartManager.shared.errorMessage == nil {
                for item in viewModel.items {
                    let product = ProductItem(id: item.id, title: item.title, price: item.price, path: item.path)
                    CollaborativeCartManager.shared.addItem(product: product, quantity: item.quantity)
                }
                viewModel.isShowingCollaborativeCart = true
            } else {
                viewModel.errorMessage = CollaborativeCartManager.shared.errorMessage
            }
        }
    }
}

// MARK: - LobbyActionRow
struct LobbyActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let walnut: Color
    let tan: Color
    let terracotta: Color
    let warmShadow: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon badge
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(tan.opacity(0.45))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(walnut)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(walnut)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(walnut.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(walnut.opacity(0.25))
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: warmShadow, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
