//
//  AddressManager.swift
//  WSHackathonApp
//

import Foundation
import Combine

struct UserAddress: Codable, Identifiable, Equatable {
    var id: String
    var name: String // e.g. "Home", "Work", "Other"
    var latitude: Double
    var longitude: Double
    var houseNo: String
    var building: String
    var areaStreet: String
    var landmark: String
    var receiverName: String?
    var receiverPhone: String?
    
    var fullAddressString: String {
        let parts = [houseNo, building, areaStreet, landmark].filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return parts.isEmpty ? "Selected Location on Map" : parts.joined(separator: ", ")
    }
}

class AddressManager: ObservableObject {
    static let shared = AddressManager()
    
    @Published var savedAddresses: [UserAddress] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    @Published var activeAddress: UserAddress? {
        didSet {
            saveActiveAddressToUserDefaults()
        }
    }
    
    private init() {
        loadFromUserDefaults()
    }
    
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "ws_saved_addresses"),
           let decoded = try? JSONDecoder().decode([UserAddress].self, from: data) {
            self.savedAddresses = decoded
        } else {
            // Default mock addresses
            self.savedAddresses = [
                UserAddress(id: "1", name: "Home 🏠", latitude: 37.7749, longitude: -122.4194, houseNo: "Apt 4B, 4th Floor", building: "The Williams Tower", areaStreet: "150 Post St", landmark: "Near Union Square", receiverName: "Kartik Bhadane", receiverPhone: "+91 9876543210"),
                UserAddress(id: "2", name: "Office 💼", latitude: 37.7891, longitude: -122.4014, houseNo: "Suite 1200", building: "Salesforce Tower", areaStreet: "415 Mission St", landmark: "Opposite Salesforce Plaza", receiverName: "Kartik Bhadane", receiverPhone: "+91 9876543210")
            ]
        }
        
        if let data = UserDefaults.standard.data(forKey: "ws_active_address"),
           let decoded = try? JSONDecoder().decode(UserAddress.self, from: data) {
            self.activeAddress = decoded
        } else {
            self.activeAddress = self.savedAddresses.first
        }
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedAddresses) {
            UserDefaults.standard.set(encoded, forKey: "ws_saved_addresses")
        }
    }
    
    private func saveActiveAddressToUserDefaults() {
        if let activeAddress = activeAddress {
            if let encoded = try? JSONEncoder().encode(activeAddress) {
                UserDefaults.standard.set(encoded, forKey: "ws_active_address")
            }
        } else {
            UserDefaults.standard.removeObject(forKey: "ws_active_address")
        }
    }
    
    func selectActiveAddress(_ address: UserAddress) {
        self.activeAddress = address
    }
    
    func addAddress(_ address: UserAddress) {
        savedAddresses.append(address)
        if activeAddress == nil {
            activeAddress = address
        }
    }
    
    func updateAddress(_ address: UserAddress) {
        if let index = savedAddresses.firstIndex(where: { $0.id == address.id }) {
            savedAddresses[index] = address
            if activeAddress?.id == address.id {
                activeAddress = address
            }
        }
    }
    
    func deleteAddress(_ addressId: String) {
        savedAddresses.removeAll(where: { $0.id == addressId })
        if activeAddress?.id == addressId {
            activeAddress = savedAddresses.first
        }
    }
}
