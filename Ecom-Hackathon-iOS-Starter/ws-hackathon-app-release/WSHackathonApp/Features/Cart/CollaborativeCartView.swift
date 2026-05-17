import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Shared Theme
private let ivory      = Color(red: 250/255, green: 247/255, blue: 240/255)
private let walnut     = Color(red: 42/255,  green: 37/255,  blue: 32/255)
private let tan        = Color(red: 221/255, green: 211/255, blue: 194/255)
private let terracotta = Color(red: 107/255, green: 82/255,  blue: 64/255)
private let warmShadow = Color(red: 62/255,  green: 40/255,  blue: 28/255).opacity(0.06)
private let cardCream  = Color(red: 245/255, green: 242/255, blue: 237/255)

// MARK: - CollaborativeCartView
struct CollaborativeCartView: View {
    @State private var cartManager = CollaborativeCartManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showingInvite = false

    var body: some View {
        ZStack {
            ivory.ignoresSafeArea()
            VStack(spacing: 0) {
                squadStrip
                itemsScroll
                checkoutBar
            }
        }
        .navigationTitle("Shared Cart")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    cartManager.exitCart()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Leave").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(terracotta)
                }
            }
        }
        .sheet(isPresented: $showingInvite) {
            InviteView(cartId: cartManager.currentCartId ?? "")
        }
    }

    // MARK: Squad Strip
    private var squadStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(cartManager.members) { member in
                    VStack(spacing: 6) {
                        AsyncImage(url: URL(string: member.avatar)) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            ZStack {
                                Circle().fill(tan)
                                Image(systemName: "person.fill")
                                    .foregroundColor(walnut.opacity(0.4))
                                    .font(.system(size: 18))
                            }
                        }
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(walnut.opacity(0.12), lineWidth: 1.5))
                        .shadow(color: warmShadow, radius: 4, x: 0, y: 2)

                        Text(member.name)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(walnut.opacity(0.6))
                            .lineLimit(1)
                    }
                }
                Button { showingInvite = true } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle().fill(walnut.opacity(0.05))
                                .frame(width: 52, height: 52)
                                .overlay(Circle().stroke(tan, lineWidth: 1.5))
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(walnut)
                        }
                        Text("Invite")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(walnut.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .shadow(color: warmShadow, radius: 6, y: 3)
    }

    // MARK: Items
    private var itemsScroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                if cartManager.items.isEmpty {
                    emptyState
                } else {
                    ForEach(cartManager.items) { item in
                        CollaborativeCartItemRow(item: item) {
                            cartManager.removeItem(itemId: item.id)
                        } onReact: { emoji in
                            cartManager.addReaction(itemId: item.id, emoji: emoji)
                        } onComment: { text in
                            cartManager.addComment(itemId: item.id, text: text)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }

    // MARK: Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(tan.opacity(0.4)).frame(width: 90, height: 90)
                Image(systemName: "cart")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(walnut.opacity(0.35))
            }
            .padding(.top, 60)

            Text("The cart is empty")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(walnut)
            Text("Add items from the home screen\nand they'll appear here for everyone.")
                .font(.system(size: 14))
                .foregroundColor(walnut.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }

    // MARK: Checkout Bar
    private var checkoutBar: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Squad Total")
                    .font(.system(size: 14))
                    .foregroundColor(walnut.opacity(0.55))
                Spacer()
                Text(String(format: "$%.2f", cartManager.totalPrice))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(walnut)
            }
            .padding(.horizontal, 20)

            NavigationLink(destination: OrderSummaryView(viewModel: CartViewModel())) {
                Text("Checkout Together")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(walnut)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(color: walnut.opacity(0.22), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .padding(.top, 14)
        .background(Color.white)
        .shadow(color: warmShadow, radius: 12, y: -4)
    }
}

// MARK: - CollaborativeCartItemRow
struct CollaborativeCartItemRow: View {
    let item: LocalCartItem
    let onRemove: () -> Void
    let onReact: (String) -> Void
    let onComment: (String) -> Void

    @State private var commentText = ""
    @State private var isCommentsExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Product row
            HStack(alignment: .top, spacing: 14) {
                AsyncImage(url: URL(string: AppConstants.API.imageBasePath + (item.imagePath?.trimmingCharacters(in: ["/"]) ?? ""))) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    ZStack {
                        cardCream
                        Image(systemName: "photo").foregroundColor(walnut.opacity(0.2))
                    }
                }
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: warmShadow, radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(walnut)
                                .lineLimit(2)
                            Text(String(format: "$%.2f", item.price))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(terracotta)
                        }
                        Spacer()
                        Button(action: onRemove) {
                            Image(systemName: "trash")
                                .font(.system(size: 13))
                                .foregroundColor(walnut.opacity(0.38))
                                .frame(width: 34, height: 34)
                                .background(cardCream)
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    HStack {
                        if let addedBy = item.addedBy {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill").font(.system(size: 8))
                                Text(addedBy).font(.system(size: 10, weight: .semibold))
                            }
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(tan.opacity(0.4))
                            .foregroundColor(walnut.opacity(0.7))
                            .cornerRadius(20)
                        }
                        Spacer()
                        // Quantity stepper
                        HStack(spacing: 14) {
                            Button {
                                if item.quantity > 1 {
                                    CollaborativeCartManager.shared.updateQuantity(itemId: item.id, change: -1)
                                } else { onRemove() }
                            } label: {
                                Image(systemName: "minus").font(.system(size: 11, weight: .bold)).foregroundColor(walnut)
                            }
                            Text("\(item.quantity)")
                                .font(.system(size: 14, weight: .bold)).foregroundColor(walnut).frame(minWidth: 18)
                            Button {
                                CollaborativeCartManager.shared.updateQuantity(itemId: item.id, change: 1)
                            } label: {
                                Image(systemName: "plus").font(.system(size: 11, weight: .bold)).foregroundColor(walnut)
                            }
                        }
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(tan.opacity(0.3))
                        .cornerRadius(20)
                    }
                }
            }

            // Reactions
            HStack(spacing: 8) {
                ForEach(["❤️", "👍", "👎"], id: \.self) { emoji in
                    Button { onReact(emoji) } label: {
                        HStack(spacing: 5) {
                            Text(emoji).font(.system(size: 14))
                            if let count = item.reactions[emoji], count > 0 {
                                Text("\(count)").font(.system(size: 11, weight: .bold))
                            }
                        }
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background((item.reactions[emoji] ?? 0) > 0 ? tan.opacity(0.5) : cardCream)
                        .foregroundColor(walnut)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            // Comments
            if !item.comments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    let displayed = isCommentsExpanded ? item.comments : Array(item.comments.prefix(2))
                    ForEach(displayed) { comment in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(comment.userName)
                                .font(.system(size: 11, weight: .bold)).foregroundColor(terracotta)
                            Text(comment.text)
                                .font(.system(size: 13)).foregroundColor(walnut.opacity(0.8))
                        }
                        .padding(.leading, 10)
                        .overlay(Rectangle().fill(tan).frame(width: 2).padding(.vertical, 2), alignment: .leading)
                    }
                    if item.comments.count > 2 {
                        Button {
                            withAnimation(.spring()) { isCommentsExpanded.toggle() }
                        } label: {
                            Text(isCommentsExpanded ? "Show less" : "See \(item.comments.count - 2) more…")
                                .font(.system(size: 12, weight: .semibold)).foregroundColor(terracotta)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 248/255, green: 245/255, blue: 240/255))
                .cornerRadius(12)
            }

            // Comment input
            HStack(spacing: 10) {
                TextField("Add a thought…", text: $commentText)
                    .font(.system(size: 14))
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(cardCream)
                    .foregroundColor(walnut)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(tan, lineWidth: 1))

                Button {
                    guard !commentText.isEmpty else { return }
                    onComment(commentText)
                    commentText = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 15)).foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(walnut)
                        .clipShape(Circle())
                        .shadow(color: walnut.opacity(0.18), radius: 4, x: 0, y: 2)
                }
                .disabled(commentText.isEmpty)
                .opacity(commentText.isEmpty ? 0.35 : 1.0)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: warmShadow, radius: 10, x: 0, y: 5)
    }
}

// MARK: - InviteView
struct InviteView: View {
    let cartId: String
    @Environment(\.dismiss) var dismiss
    @State private var hasCopied = false

    var body: some View {
        ZStack {
            ivory.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Text("Invite to Squad")
                        .font(.system(size: 18, weight: .bold)).foregroundColor(walnut)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(walnut.opacity(0.5))
                            .frame(width: 32, height: 32)
                            .background(tan.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // QR
                        VStack(spacing: 16) {
                            if let qrImage = generateQRCode(from: "myapp://cart/\(cartId)") {
                                Image(uiImage: qrImage)
                                    .interpolation(.none).resizable()
                                    .frame(width: 190, height: 190)
                                    .padding(18).background(Color.white)
                                    .cornerRadius(24)
                                    .shadow(color: warmShadow, radius: 20, x: 0, y: 10)
                            }
                            VStack(spacing: 4) {
                                Text("Scan to join the squad")
                                    .font(.system(size: 15, weight: .semibold)).foregroundColor(walnut)
                                Text("Real-time collaborative shopping")
                                    .font(.system(size: 12)).foregroundColor(walnut.opacity(0.5))
                            }
                        }
                        .padding(.top, 16)

                        // Divider
                        HStack {
                            Rectangle().fill(tan).frame(height: 1)
                            Text("OR USE CODE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(walnut.opacity(0.4)).tracking(1.5).fixedSize()
                            Rectangle().fill(tan).frame(height: 1)
                        }
                        .padding(.horizontal, 40)

                        // Room code
                        HStack(spacing: 12) {
                            Text(cartId)
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(walnut)
                                .frame(maxWidth: .infinity).padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16).fill(Color.white)
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(tan, lineWidth: 1))
                                )

                            Button {
                                UIPasteboard.general.string = cartId
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation { hasCopied = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { hasCopied = false } }
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: hasCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                        .font(.system(size: 20))
                                    Text(hasCopied ? "Copied" : "Copy")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .foregroundColor(hasCopied ? .green : walnut)
                                .frame(width: 72, height: 72)
                                .background(hasCopied ? Color.green.opacity(0.08) : tan.opacity(0.3))
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(hasCopied ? Color.green.opacity(0.3) : tan, lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 24)

                        // Note
                        HStack(spacing: 10) {
                            Image(systemName: "lock.shield").font(.system(size: 13)).foregroundColor(walnut.opacity(0.4))
                            Text("Anyone with this code can view and edit the shared cart.")
                                .font(.system(size: 12)).foregroundColor(walnut.opacity(0.5))
                        }
                        .padding(.horizontal, 28).padding(.vertical, 12)
                        .background(Color.white).cornerRadius(12)
                        .shadow(color: warmShadow, radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }

                // Done
                Button { dismiss() } label: {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(walnut).cornerRadius(30)
                        .shadow(color: walnut.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24).padding(.bottom, 30)
            }
        }
    }

    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage,
           let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }
        return nil
    }
}
