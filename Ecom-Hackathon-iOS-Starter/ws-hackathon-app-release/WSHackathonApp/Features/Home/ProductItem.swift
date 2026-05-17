//
//  ProductItem.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 05/04/26.
//

import Foundation
import SwiftUI

struct ProductItem: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let price: Double?
    let path: String?
    
    // Enriched fields for the luxury editorial theme
    var regularPrice: Double? = nil
    var sellingPrice: Double? = nil
    var brand: String? = nil
    var material: String? = nil
    var productType: String? = nil
    var shippingStatus: String? = nil
    
    // Explicit memberwise initializer to preserve backward compatibility
    init(
        id: String,
        title: String,
        price: Double?,
        path: String?,
        regularPrice: Double? = nil,
        sellingPrice: Double? = nil,
        brand: String? = nil,
        material: String? = nil,
        productType: String? = nil,
        shippingStatus: String? = nil
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.path = path
        self.regularPrice = regularPrice
        self.sellingPrice = sellingPrice
        self.brand = brand
        self.material = material
        self.productType = productType
        self.shippingStatus = shippingStatus
    }
    
    var imageURL: URL? {
        if let imageUrl = path {
            return URL(string: AppConstants.API.imageBasePath + imageUrl)
        }
        return nil
    }
}

extension ProductItem {
    init(from dto: ProductItemDTO) {
        self.id = dto.id
        self.title = dto.name
        self.regularPrice = dto.price?.regularPrice
        self.sellingPrice = dto.price?.sellingPrice
        self.brand = dto.properties?.brand
        self.material = dto.properties?.material
        self.productType = dto.properties?.productType
        self.shippingStatus = dto.deliveryEstimate
        
        // Price formatting: use regularPrice if available
        if let priceValue = dto.price?.regularPrice {
            self.price = priceValue
        } else {
            self.price = 0.0
        }
        
        // Image: first ProductImage path if available
        if let firstImage = dto.media?.images?.first?.path {
            self.path = firstImage
        } else {
            self.path = nil
        }
    }
    
    // Dynamically returns the exact pastel/luxury tint color matching the Lovable specifications
    var tintColor: Color {
        let titleLower = title.lowercased()
        if titleLower.contains("walnut") || titleLower.contains("carving") {
            return Color(red: 232/255, green: 220/255, blue: 197/255) // #E8DCC5 (Warm tan carving board)
        } else if titleLower.contains("espresso") || titleLower.contains("porcelain") {
            return Color(red: 244/255, green: 239/255, blue: 227/255) // #F4EFE3 (Pale ivory espresso cup)
        } else if titleLower.contains("bowl") || titleLower.contains("stoneware") {
            return Color(red: 238/255, green: 229/255, blue: 210/255) // #EEE5D2 (Soft cream serving bowl)
        } else if titleLower.contains("oil") || titleLower.contains("conditioning") {
            return Color(red: 229/255, green: 210/255, blue: 179/255) // #E5D2B3 (Honey beige conditioning oil)
        } else if titleLower.contains("linen") || titleLower.contains("napkins") {
            return Color(red: 238/255, green: 228/255, blue: 208/255) // #EEE4D0 (Linen cream Belgian napkins)
        } else if titleLower.contains("skillet") || titleLower.contains("cast iron") {
            return Color(red: 223/255, green: 214/255, blue: 199/255) // #DFD6C7 (Cool stone cast iron skillet)
        } else {
            return Color(red: 245/255, green: 240/255, blue: 235/255) // Soft neutral gray-beige fallback
        }
    }
}
