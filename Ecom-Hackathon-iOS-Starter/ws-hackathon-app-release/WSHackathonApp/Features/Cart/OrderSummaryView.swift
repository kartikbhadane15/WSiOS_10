import SwiftUI

struct OrderSummaryView: View {
    @ObservedObject var viewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false

    private var subtotal: Double {
        viewModel.items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    private var tax: Double {
        subtotal * 0.08
    }

    private var total: Double {
        subtotal + tax
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
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
            .alert("Order Placed!", isPresented: $showAlert) {
                Button("OK") {
                    viewModel.clearCart()
                    dismiss()
                }
            } message: {
                Text("Your order has been placed successfully.")
            }
        }
    }

    private var itemsSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.items) { item in
                HStack(spacing: 12) {
                    CustomAsyncImage(url: item.imageURL)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .clipped()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(2)

                        Text("Qty: \(item.quantity)")
                            .font(.caption)
                            .foregroundColor(.gray)
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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Delivering to:")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("123 Main St, New York, NY")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Spacer()
            Button(action: {}) {
                Text("Change")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    private var placeOrderButton: some View {
        Button(action: { showAlert = true }) {
            Text("Place Order")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16.0)
        .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: -2)
    }
}
