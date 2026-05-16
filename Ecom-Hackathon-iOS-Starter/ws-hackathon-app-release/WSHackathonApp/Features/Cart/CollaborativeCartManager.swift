import Foundation
import SocketIO
import SwiftData
import SwiftUI

struct CollaborativeMember: Codable, Identifiable {
    let id: String
    let name: String
    let avatar: String
}

@Observable
class CollaborativeCartManager {
    static let shared = CollaborativeCartManager()
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    var currentCartId: String?
    var items: [LocalCartItem] = []
    var members: [CollaborativeMember] = []
    var isConnected = false
    var errorMessage: String?
    private var repository: CartRepository?
    private var isCreating = false
    
    private init() {
        setupSocket()
    }
    
    private func setupSocket() {
        // Use the mock API URL. In a real app, this would be a config.
        guard let url = URL(string: "http://localhost:3001") else { return }
        
        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        socket = manager?.defaultSocket
        
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            print("Socket connected")
            Task { @MainActor in
                self?.isConnected = true
                if let cartId = self?.currentCartId {
                    self?.socket?.emit("join-cart", cartId)
                }
            }
        }
        
        socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("Socket disconnected")
            self?.isConnected = false
        }
        
        socket?.on("cart-updated") { [weak self] data, ack in
            guard let dict = data[0] as? [String: Any],
                  let self = self else { return }
            
            Task { @MainActor in
                self.updateLocalState(from: dict)
            }
        }
        
        socket?.on("error") { [weak self] data, ack in
            guard let dict = data[0] as? [String: Any],
                  let message = dict["message"] as? String else { return }
            
            Task { @MainActor in
                self?.errorMessage = message
                // If there's an error joining, clear the currentCartId
                self?.currentCartId = nil
            }
        }
        
        socket?.connect()
    }
    
    func bind(repository: CartRepository) {
        self.repository = repository
    }
    
    func createCart(cartId: String) {
        self.currentCartId = cartId
        self.errorMessage = nil
        if isConnected {
            socket?.emit("create-cart", cartId)
        }
    }
    
    func joinCart(cartId: String) {
        self.currentCartId = cartId
        self.errorMessage = nil
        if isConnected {
            socket?.emit("join-cart", cartId)
        }
    }
    
    func exitCart() {
        guard let cartId = currentCartId else { return }
        socket?.emit("leave-cart", cartId)
        self.currentCartId = nil
        self.items = []
        self.members = []
    }
    
    func addItem(product: ProductItem, quantity: Int = 1) {
        guard let cartId = currentCartId else { return }
        let item: [String: Any] = [
            "id": product.id,
            "name": product.title,
            "price": product.price ?? 0.0,
            "imagePath": product.path ?? "",
            "quantity": quantity
        ]
        socket?.emit("add-item", ["cartId": cartId, "item": item])
    }
    
    func removeItem(itemId: String) {
        guard let cartId = currentCartId else { return }
        socket?.emit("remove-item", ["cartId": cartId, "itemId": itemId])
    }
    
    func updateQuantity(itemId: String, change: Int) {
        guard let cartId = currentCartId else { return }
        socket?.emit("update-quantity", ["cartId": cartId, "itemId": itemId, "change": change])
    }
    
    func addReaction(itemId: String, emoji: String) {
        guard let cartId = currentCartId else { return }
        socket?.emit("add-reaction", ["cartId": cartId, "itemId": itemId, "emoji": emoji])
    }
    
    func addComment(itemId: String, text: String) {
        guard let cartId = currentCartId else { return }
        socket?.emit("add-comment", ["cartId": cartId, "itemId": itemId, "text": text])
    }
    
    private func updateLocalState(from dict: [String: Any]) {
        // Update members
        if let membersData = dict["members"] as? [[String: Any]] {
            do {
                let data = try JSONSerialization.data(withJSONObject: membersData)
                self.members = try JSONDecoder().decode([CollaborativeMember].self, from: data)
            } catch {
                print("Error decoding members: \(error)")
            }
        }
        
        // Update items
        if let itemsData = dict["items"] as? [[String: Any]] {
            self.items = itemsData.compactMap { itemDict in
                guard let id = itemDict["id"] as? String,
                      let name = itemDict["name"] as? String else { return nil }
                
                let price: Double = (itemDict["price"] as? Double) ?? Double(itemDict["price"] as? Int ?? 0)
                let quantity: Int = (itemDict["quantity"] as? Int) ?? Int(itemDict["quantity"] as? Double ?? 1)
                
                let item = LocalCartItem(id: id, name: name, price: price, quantity: quantity, addedBy: itemDict["addedBy"] as? String)
                item.imagePath = itemDict["imagePath"] as? String
                
                if let reactions = itemDict["reactions"] as? [String: Int] {
                    item.reactions = reactions
                }
                
                if let commentsData = itemDict["comments"] as? [[String: Any]] {
                    item.comments = commentsData.compactMap { cDict in
                        guard let cid = cDict["id"] as? String,
                              let text = cDict["text"] as? String,
                              let user = cDict["userName"] as? String else { return nil }
                        return LocalCartComment(id: cid, text: text, userName: user)
                    }
                }
                return item
            }
            
            // Sync with global repository so Home tab and others are updated
            self.repository?.updateFromCollaborative(sharedItems: self.items)
        }
    }
    
    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
}
