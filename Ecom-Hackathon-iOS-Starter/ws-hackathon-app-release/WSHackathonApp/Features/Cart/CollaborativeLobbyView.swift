import SwiftUI

struct CollaborativeLobbyView: View {
    @ObservedObject var viewModel: CartViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showJoinAlert = false
    @State private var roomCode = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    
                    VStack(spacing: 20) {
                        // Option 1: Create
                        LobbyActionRow(
                            title: "Start a New Session",
                            subtitle: "Invite friends to build this cart",
                            icon: "plus.circle.fill",
                            color: .blue
                        ) {
                            startNewSession()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .blue.opacity(0.1), radius: 15, x: 0, y: 8)
                        
                        // Option 2: Join
                        LobbyActionRow(
                            title: "Join Existing Session",
                            subtitle: "Enter a room code from a friend",
                            icon: "link.circle.fill",
                            color: .purple
                        ) {
                            showJoinAlert = true
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .purple.opacity(0.1), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.vertical, 40)
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Collaborative Shopping")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Join Shared Cart", isPresented: $showJoinAlert) {
            TextField("Room Code", text: $roomCode)
                .textInputAutocapitalization(.characters)
            Button("Cancel", role: .cancel) { }
            Button("Join") {
                joinSession(code: roomCode)
            }
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
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text("Shop Better, Together")
                    .font(.title2)
                    .bold()
                
                Text("Build your dream cart with friends in real-time. React, comment, and decide together.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
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
        if !code.isEmpty {
            CollaborativeCartManager.shared.joinCart(cartId: code)
            
            // We wait a tiny bit or observe the cart state before navigating
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
}

struct LobbyActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                    .frame(width: 44)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
    }
}
