import SwiftUI

struct BundleStripView: View {
    let bundleItems: [BundleItem]
    let cartItemIds: [String]
    let onAddBundle: ([BundleItem]) -> Void
    let onAddSingle: (BundleItem) -> Void

    @State private var animateIn = false

    private var filteredItems: [BundleItem] {
        bundleItems.filter { !cartItemIds.contains($0.id) }
    }

    var body: some View {
        let items = filteredItems

        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                headerView
                scrollView(with: items)
                footerView(for: items)
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

    private func scrollView(with items: [BundleItem]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items) { item in
                    BundleItemCard(
                        item: item,
                        onAddSingle: onAddSingle
                    )
                }
            }
        }
    }

    private func footerView(for items: [BundleItem]) -> some View {
        Button(action: { onAddBundle(items) }) {
            Text("Add all")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 42/255, green: 37/255, blue: 32/255))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

private struct BundleItemCard: View {
    let item: BundleItem
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
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .frame(width: 100)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
