import SwiftUI

struct OrderSummaryView: View {
    @ObservedObject var viewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showPayPalSheet = false
    @State private var showSuccessScreen = false
    @State private var selectedPaymentMethod = ""

    @ObservedObject var addressManager = AddressManager.shared

    // Luxury Editorial Theme Colors
    private let walnut = Color(red: 42/255, green: 37/255, blue: 32/255)       // #2A2520 Ink
    private let terracotta = Color(red: 107/255, green: 82/255, blue: 64/255)  // #6B5240 Accent
    private let warmShadow = Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.04)

    private var subtotal: Double {
        if CollaborativeCartManager.shared.currentCartId != nil {
            return CollaborativeCartManager.shared.totalPrice
        }
        return viewModel.items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    private var tax: Double {
        subtotal * 0.08
    }

    private var total: Double {
        subtotal + tax + (viewModel.includesGiftWrap ? 2.00 : 0)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Collaborative Shopping Squad Header
                        if CollaborativeCartManager.shared.currentCartId != nil {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Shopping Squad")
                                    .font(.headline)
                                    .padding(.horizontal, 4)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: -12) {
                                        ForEach(CollaborativeCartManager.shared.members) { member in
                                            AsyncImage(url: URL(string: member.avatar)) { image in
                                                image.resizable()
                                            } placeholder: {
                                                Circle().fill(Color.gray.opacity(0.3))
                                            }
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        }
                                        
                                        if CollaborativeCartManager.shared.members.count > 1 {
                                            Text("+\(CollaborativeCartManager.shared.members.count - 1) others")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.leading, 16)
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            .padding(.bottom, 8)
                        }

                        itemsSection

                        Divider()

                        priceBreakdownSection

                        Divider()

                        deliverySection
                    }
                    .padding(16)
                }

                placeOrderButton
            }
            .background(Color.white)
            .navigationTitle("Order Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showPayPalSheet, onDismiss: {
                if !selectedPaymentMethod.isEmpty {
                    showSuccessScreen = true
                }
            }) {
                MockPayPalSheet(total: total, selectedMethod: $selectedPaymentMethod)
            }
            .fullScreenCover(isPresented: $showSuccessScreen) {
                PaymentSuccessView(total: total, paymentMethod: selectedPaymentMethod) {
                    showSuccessScreen = false
                    viewModel.clearCart()
                    dismiss()
                }
            }
        }
    }

    private var itemsSection: some View {
        VStack(spacing: 12) {
            let displayItems = CollaborativeCartManager.shared.currentCartId != nil ? CollaborativeCartManager.shared.items : viewModel.items.map { LocalCartItem(id: $0.id, name: $0.title, price: $0.price, imagePath: $0.path, quantity: $0.quantity) }
            
            ForEach(displayItems) { item in
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: AppConstants.API.imageBasePath + (item.imagePath?.trimmingCharacters(in: ["/"]) ?? ""))) { image in
                        image.resizable()
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.1))
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(2)

                        Text("Qty: \(item.quantity)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if let addedBy = item.addedBy {
                            Text("Added by \(addedBy)")
                                .font(.system(size: 8))
                                .foregroundColor(.blue)
                        }
                    }

                    Spacer()

                    Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var priceBreakdownSection: some View {
        VStack(spacing: 8) {
            priceRow(label: "Subtotal", amount: String(format: "$%.2f", subtotal))
            priceRow(label: "Shipping", amount: "Free")
            priceRow(label: "Tax (8%)", amount: String(format: "$%.2f", tax))
            if viewModel.includesGiftWrap {
                priceRow(label: "Gift Wrap", amount: "+$2.00")
            }
            Divider()
            priceRow(label: "Total", amount: String(format: "$%.2f", total))
                .fontWeight(.bold)
        }
    }

    private func priceRow(label: String, amount: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(amount)
                .font(.subheadline)
        }
    }

    private var deliverySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Delivering to:")
                .font(.caption)
                .foregroundColor(.gray)
            
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
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
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
                
                // "Change" Button goes directly to AddressManagementView
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
    }

    private var placeOrderButton: some View {
        let hasAddress = addressManager.activeAddress != nil
        return Button(action: {
            if hasAddress {
                showPayPalSheet = true
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title3)
                Text(hasAddress ? "Pay with PayPal" : "Select Address to Pay")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(hasAddress ? Color(red: 42/255, green: 37/255, blue: 32/255) : Color.gray)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .disabled(!hasAddress)
        .padding()
        .background(Color.white)
        .cornerRadius(24.0)
        .shadow(color: Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.04), radius: 8, x: 0, y: -4)
    }
}
