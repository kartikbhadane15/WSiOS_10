// VisualSearchSupportViews.swift
// WSHackathonApp – Visual Search / Style Board
//
// Contains:
//   • VisualProductItem model
//   • ProductGridView  – 2-column async image grid with match score badge
//   • ColorPaletteView – horizontal swatch row
//   • StyleTagsView    – wrapping chip layout
//   • ErrorView        – inline error with retry

import SwiftUI

// MARK: – Model

struct VisualProductItem: Identifiable, Equatable {
    let id: String
    let name: String
    let price: Double
    let currency: String
    let imageURL: URL?
    let matchScore: Double   // 0.0 – 1.0
    let tags: [String]

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: price)) ?? "\(currency) \(price)"
    }

    var matchPercentage: String { "\(Int(matchScore * 100))% match" }
}

// MARK: – Product grid

struct ProductGridView: View {
    let products: [VisualProductItem]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Matching Products")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(products) { product in
                    ProductCard(product: product)
                }
            }
        }
    }
}

private struct ProductCard: View {
    let product: VisualProductItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Async product image
            AsyncImage(url: product.imageURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(ProgressView())
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 160)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                Text(product.matchPercentage)
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .padding(6)
            }

            Text(product.name)
                .font(.caption.bold())
                .lineLimit(2)

            Text(product.formattedPrice)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: – Colour palette

struct ColorPaletteView: View {
    let colors: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Colour Palette")
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                    Circle()
                        .fill(color)
                        .frame(width: 44, height: 44)
                        .shadow(color: color.opacity(0.4), radius: 4, y: 2)
                }
                Spacer()
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: – Style tags

struct StyleTagsView: View {
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detected Style")
                .font(.headline)

            // Wrapping chip layout
            WrapLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: – Error view

struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button(action: retry) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 42/255, green: 37/255, blue: 32/255))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 24)
    }
}

// MARK: – WrapLayout (chip wrapping)
// A simple Layout that wraps its children, like a CSS flex-wrap row.

private struct WrapLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        y += rowHeight
        return CGSize(width: maxWidth, height: y)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
