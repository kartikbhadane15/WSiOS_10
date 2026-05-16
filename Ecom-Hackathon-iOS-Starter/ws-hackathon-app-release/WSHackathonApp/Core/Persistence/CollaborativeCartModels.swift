import Foundation
import SwiftData

@Model
final class LocalCartItem {
    @Attribute(.unique) var id: String
    var name: String
    var price: Double
    var imagePath: String?
    var quantity: Int
    var addedBy: String?
    var reactions: [String: Int] // emoji: count
    var comments: [LocalCartComment]
    
    init(id: String, name: String, price: Double, imagePath: String? = nil, quantity: Int = 1, addedBy: String? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.imagePath = imagePath
        self.quantity = quantity
        self.addedBy = addedBy
        self.reactions = [:]
        self.comments = []
    }
}

@Model
final class LocalCartComment {
    @Attribute(.unique) var id: String
    var text: String
    var userName: String
    var timestamp: Date
    
    init(id: String = UUID().uuidString, text: String, userName: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.userName = userName
        self.timestamp = timestamp
    }
}

@Model
final class CollaborativeSession {
    @Attribute(.unique) var cartId: String
    var createdAt: Date
    var isActive: Bool
    
    init(cartId: String, createdAt: Date = Date(), isActive: Bool = true) {
        self.cartId = cartId
        self.createdAt = createdAt
        self.isActive = isActive
    }
}
