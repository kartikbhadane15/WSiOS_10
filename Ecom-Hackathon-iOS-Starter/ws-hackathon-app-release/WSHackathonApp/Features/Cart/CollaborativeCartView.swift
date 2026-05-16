import SwiftUI
import CoreImage.CIFilterBuiltins

struct CollaborativeCartView: View {
    @State private var cartManager = CollaborativeCartManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showingInvite = false
    @State private var newCommentText = ""
    @State private var selectedItemId: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Members (Shopping Squad)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cartManager.members) { member in
                        VStack {
                            AsyncImage(url: URL(string: member.avatar)) { image in
                                image.resizable()
                            } placeholder: {
                                Circle().fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            
                            Text(member.name)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                    
                    Button(action: { showingInvite = true }) {
                        VStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 50, height: 50)
                                .overlay(Image(systemName: "plus").foregroundColor(.blue))
                            
                            Text("Invite")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
            }
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            
            // Cart Items
            ScrollView {
                VStack(spacing: 16) {
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
                .padding()
            }
            .background(Color(.systemGray6).opacity(0.5))
            
            // Bottom: Budget Tracking
            VStack(spacing: 12) {
                HStack {
                    Text("Total Budget")
                        .font(.headline)
                    Spacer()
                    Text("$\(cartManager.totalPrice, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: OrderSummaryView(viewModel: CartViewModel())) { // Note: In a real app, bind the shared items
                    Text("Checkout Together")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

            }
            .padding(.top)
            .background(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        }
        .navigationTitle("Shared Cart")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    cartManager.exitCart()
                    dismiss()
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showingInvite) {
            InviteView(cartId: cartManager.currentCartId ?? "")
        }
    }
}

struct CollaborativeCartItemRow: View {
    let item: LocalCartItem
    let onRemove: () -> Void
    let onReact: (String) -> Void
    let onComment: (String) -> Void
    
    @State private var commentText = ""
    @State private var isCommentsExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main Content Row
            HStack(alignment: .top, spacing: 16) {
                // Product Image
                AsyncImage(url: URL(string: AppConstants.API.imageBasePath + (item.imagePath?.trimmingCharacters(in: ["/"]) ?? ""))) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        Color(.systemGray6)
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(2)
                            
                            Text("$\(item.price, specifier: "%.2f")")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: onRemove) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(.red.opacity(0.8))
                                .padding(8)
                                .background(Color.red.opacity(0.05))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    HStack {
                        if let addedBy = item.addedBy {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 8))
                                Text(addedBy)
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.blue)
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                        
                        // Quantity Controls
                        HStack(spacing: 12) {
                            Button(action: {
                                if item.quantity > 1 {
                                    CollaborativeCartManager.shared.updateQuantity(itemId: item.id, change: -1)
                                } else {
                                    onRemove()
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            
                            Text("\(item.quantity)")
                                .font(.system(size: 14, weight: .bold))
                                .frame(minWidth: 20)
                            
                            Button(action: {
                                CollaborativeCartManager.shared.updateQuantity(itemId: item.id, change: 1)
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    }
                }
            }
            
            // Reactions Row
            HStack(spacing: 8) {
                ForEach(["❤️", "👍", "👎"], id: \.self) { emoji in
                    Button(action: { onReact(emoji) }) {
                        HStack(spacing: 6) {
                            Text(emoji)
                                .font(.system(size: 14))
                            if let count = item.reactions[emoji], count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 12, weight: .bold))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(item.reactions[emoji] ?? 0 > 0 ? Color.blue.opacity(0.08) : Color(.systemGray6))
                        .foregroundColor(item.reactions[emoji] ?? 0 > 0 ? .blue : .primary)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Comments Section
            if !item.comments.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    let displayedComments = isCommentsExpanded ? item.comments : Array(item.comments.prefix(2))
                    
                    ForEach(displayedComments) { comment in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(comment.userName)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.blue)
                            
                            Text(comment.text)
                                .font(.system(size: 13))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                        .padding(.leading, 8)
                        .overlay(
                            Rectangle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 2)
                                .padding(.vertical, 2),
                            alignment: .leading
                        )
                    }
                    
                    if item.comments.count > 2 {
                        Button(action: {
                            withAnimation(.spring()) {
                                isCommentsExpanded.toggle()
                            }
                        }) {
                            Text(isCommentsExpanded ? "Show less" : "See \(item.comments.count - 2) more comments...")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6).opacity(0.6))
                .cornerRadius(12)
            }
            
            // Add Comment Input
            HStack(spacing: 12) {
                TextField("Add a thought...", text: $commentText)
                    .font(.system(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                Button(action: {
                    if !commentText.isEmpty {
                        onComment(commentText)
                        commentText = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .disabled(commentText.isEmpty)
                .opacity(commentText.isEmpty ? 0.4 : 1.0)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 15, x: 0, y: 8)
    }
}

struct InviteView: View {
    let cartId: String
    @Environment(\.dismiss) var dismiss
    @State private var hasCopied = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Close Button
            HStack {
                Spacer()
                Text("Invite Collaborators")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray.opacity(0.2))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 12)
            
            ScrollView {
                VStack(spacing: 32) {
                    // QR Code Card
                    VStack(spacing: 20) {
                        if let qrImage = generateQRCode(from: "myapp://cart/\(cartId)") {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .frame(width: 200, height: 200)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(24)
                                .shadow(color: .black.opacity(0.08), radius: 25, x: 0, y: 12)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Scan to join the squad")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Invite friends to shop in real-time")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Room Code Section
                    VStack(spacing: 16) {
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 1)
                            Text("OR USE CODE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.5)
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 40)
                        
                        HStack(spacing: 12) {
                            Text(cartId)
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.blue.opacity(0.03))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                                        )
                                )
                            
                            Button(action: {
                                UIPasteboard.general.string = cartId
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                withAnimation { hasCopied = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { hasCopied = false }
                                }
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: hasCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                        .font(.system(size: 20))
                                    Text(hasCopied ? "Copied" : "Copy")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .foregroundColor(hasCopied ? .green : .blue)
                                .frame(width: 74, height: 74)
                                .background(
                                    ZStack {
                                        if hasCopied {
                                            Color.green.opacity(0.1)
                                        } else {
                                            Color.blue.opacity(0.05)
                                        }
                                    }
                                )
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(hasCopied ? Color.green.opacity(0.2) : Color.blue.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Instruction Note
                    HStack(spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.blue.opacity(0.6))
                            .font(.system(size: 14))
                        Text("Anyone with this code can see and edit the cart.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.03))
                    .cornerRadius(12)
                }
                .padding(.bottom, 40)
            }
            
            // Bottom Action Button
            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return nil
    }
}
