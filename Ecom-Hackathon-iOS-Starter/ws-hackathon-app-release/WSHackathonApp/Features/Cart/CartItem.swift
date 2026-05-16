//
//  CartItem.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
struct CartItem: Identifiable, Equatable {
    let id: String
    let title: String
    let price: Double
    let path: String?
    var quantity: Int
    
    var imageURL: URL? {
        if let imageUrl = path {
            return URL(string: AppConstants.API.imageBasePath + imageUrl)
        }
        return nil
    }

    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id && lhs.quantity == rhs.quantity
    }
}
