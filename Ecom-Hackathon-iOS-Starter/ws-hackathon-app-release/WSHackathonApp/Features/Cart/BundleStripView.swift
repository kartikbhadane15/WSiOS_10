import SwiftUI

struct BundleStripView: View {
    let bundleItems: [BundleItem]
    let cartItemIds: [String]
    let onAddBundle: ([BundleItem]) -> Void
    let onAddSingle: (BundleItem) -> Void

    @State private var animateIn = false

    private let discountRate = 0.15

    var body: some View {
        let allInCart = bundleItems.allSatisfy { cartItemIds.contains($0.id) }

        if !bundleItems.isEmpty && !allInCart {
            VStack(alignment: .leading, spacing: 10) {
                headerView
                scrollView
                footerView
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    animateIn = true
                }
            }
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Complete the Set")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text("Frequently bought together")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private var scrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(bundleItems) { item in
                    BundleItemCard(
                        item: item,
                        discountRate: discountRate,
                        onAddSingle: onAddSingle
                    )
                }
            }
        }
    }

    private var footerView: some View {
        VStack(spacing: 10) {
            HStack {
                let originalTotal = bundleItems.reduce(0) { $0 + $1.originalPrice }
                let discount = originalTotal * discountRate
                let bundlePrice = originalTotal - discount

                VStack(alignment: .leading, spacing: 2) {
                    Text("$\(originalTotal, specifier: "%.2f")")
                        .font(.caption)
                        .strikethrough()
                        .foregroundColor(.gray)
                    Text("$\(bundlePrice, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                Text("Save $\(discount, specifier: "%.2f")")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(8)
            }

            Button(action: { onAddBundle(bundleItems) }) {
                Text("Add all \(bundleItems.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

private struct BundleItemCard: View {
    let item: BundleItem
    let discountRate: Double
    let onAddSingle: (BundleItem) -> Void

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                let url = URL(string: AppConstants.API.imageBasePath + item.imageName)
                CustomAsyncImage(url: url)
                    .frame(width: 60, height: 60)
                    .cornerRadius(6)
                    .clipped()

                Button(action: { onAddSingle(item) }) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.black)
                        .clipShape(Circle())
                }
                .offset(x: 4, y: 4)
            }

            Text(item.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 90)

            Text("$\(item.originalPrice, specifier: "%.2f")")
                .font(.caption2)
                .strikethrough()
                .foregroundColor(.gray)

            let discountedPrice = item.originalPrice * (1 - discountRate)
            Text("$\(discountedPrice, specifier: "%.2f")")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .frame(width: 100)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
