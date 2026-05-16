import SwiftUI

struct HesitationCardView: View {
    enum Variant {
        case itemBased(CartItem)
        case timeBased
    }

    let variant: Variant
    let onDismiss: () -> Void
    let onGoToCheckout: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            leftContent
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 2) {
                headline
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)

                bodyText
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                if case .timeBased = variant {
                    Text("Most orders arrive in 3\u{2013}5 days.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    Button(action: { onGoToCheckout?() }) {
                        Text("Go to Checkout")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
        }
        .padding(12)
        .background(Color(red: 255 / 255, green: 248 / 255, blue: 231 / 255))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var leftContent: some View {
        switch variant {
        case .itemBased(let item):
            CustomAsyncImage(url: item.imageURL)
                .frame(width: 60, height: 60)
                .cornerRadius(8)
        case .timeBased:
            ZStack {
                Color(.systemGray5)
                Image(systemName: "cart.badge.questionmark")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)
            }
            .cornerRadius(8)
        }
    }

    @ViewBuilder
    private var headline: some View {
        switch variant {
        case .itemBased:
            Text("Are you sure?")
        case .timeBased:
            Text("Your cart is waiting!")
        }
    }

    @ViewBuilder
    private var bodyText: some View {
        switch variant {
        case .itemBased:
            Text("38 people bought this item this week.")
        case .timeBased:
            Text("You've been browsing for a while. Ready to check out?")
        }
    }
}
