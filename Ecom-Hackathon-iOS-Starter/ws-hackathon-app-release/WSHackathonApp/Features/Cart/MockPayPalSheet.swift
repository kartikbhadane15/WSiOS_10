import SwiftUI

struct MockPayPalSheet: View {
    let total: Double
    @Binding var selectedMethod: String
    @Environment(\.dismiss) private var dismiss
    @State private var localSelected: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        payPalHeader
                        merchantRow
                        paymentOptions
                    }
                    .padding(20)
                }

                payButton
            }
            .background(Color.white)
            .navigationTitle("")
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
        }
    }

    private var payPalHeader: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                Text("Pay")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0/255, green: 48/255, blue: 135/255))
                Text("Pal")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0/255, green: 156/255, blue: 222/255))
            }
            Text("Choose a payment method")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private var merchantRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Williams Sonoma")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(String(format: "Total: $%.2f", total))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(String(format: "$%.2f", total))
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var paymentOptions: some View {
        VStack(spacing: 0) {
            paymentRow(
                icon: "indianrupeesign.circle.fill",
                title: "UPI",
                subtitle: "Pay via any UPI app",
                tag: "upi"
            )
            Divider()
                .padding(.leading, 52)
            paymentRow(
                icon: "creditcard.fill",
                title: "Credit / Debit Card",
                subtitle: "Visa, Mastercard, Amex",
                tag: "card"
            )
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func paymentRow(icon: String, title: String, subtitle: String, tag: String) -> some View {
        Button(action: { localSelected = tag }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.black)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if localSelected == tag {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(14)
            .background(localSelected == tag ? Color(red: 230/255, green: 241/255, blue: 251/255) : Color.clear)
        }
    }

    private var payButton: some View {
        Button(action: {
            if let method = localSelected {
                selectedMethod = method
                dismiss()
            }
        }) {
            Text(String(format: "Pay $%.2f", total))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(localSelected != nil ? Color(red: 255/255, green: 196/255, blue: 57/255) : Color.gray.opacity(0.3))
                .foregroundColor(localSelected != nil ? Color(red: 0/255, green: 48/255, blue: 135/255) : Color.gray)
                .cornerRadius(10)
        }
        .disabled(localSelected == nil)
        .padding()
        .background(Color.white)
        .cornerRadius(16.0)
        .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: -2)
    }
}
