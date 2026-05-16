import SwiftUI

struct PaymentSuccessView: View {
    let total: Double
    let paymentMethod: String
    let onContinue: () -> Void
    @Environment(\.dismiss) private var dismiss

    private let transactionId = "PP-MOCK-\(Int.random(in: 1000...9999))"

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }

    private var methodLabel: String {
        paymentMethod == "upi" ? "UPI" : "Credit Card"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.green)

            Text("Payment Successful!")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 16)

            Text("Your order has been placed with Williams Sonoma.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)

            VStack(spacing: 12) {
                detailRow(label: "Transaction ID", value: transactionId)
                Divider()
                detailRow(label: "Amount Paid", value: String(format: "$%.2f", total))
                Divider()
                detailRow(label: "Payment Method", value: methodLabel)
                Divider()
                detailRow(label: "Date", value: formattedDate)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer()

            Button(action: {
                dismiss()
                onContinue()
            }) {
                Text("Continue Shopping")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.white)
        .ignoresSafeArea()
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}
