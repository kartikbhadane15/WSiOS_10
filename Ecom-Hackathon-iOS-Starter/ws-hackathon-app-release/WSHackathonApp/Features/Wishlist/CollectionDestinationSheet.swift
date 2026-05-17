//
//  CollectionDestinationSheet.swift
//  WSHackathonApp
//

import SwiftUI

struct CollectionDestinationSheet: View {
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.dismiss) var dismiss
    
    @State private var isCreatingNew = false
    @State private var newCollectionName = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        withAnimation { isCreatingNew = true }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                            Text("Create New Collection...")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    if isCreatingNew {
                        HStack {
                            TextField("Collection Name", text: $newCollectionName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .submitLabel(.done)
                                .onSubmit {
                                    saveNew()
                                }
                            
                            Button("Save") {
                                saveNew()
                            }
                            .disabled(newCollectionName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .foregroundColor(newCollectionName.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                            .fontWeight(.bold)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if !wishlistManager.collections.isEmpty {
                    Section("Existing Collections") {
                        ForEach(wishlistManager.collections) { collection in
                            Button(action: {
                                addItems(to: collection.id)
                            }) {
                                HStack {
                                    Image(systemName: "folder")
                                        .foregroundColor(.secondary)
                                    Text(collection.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(collection.items.count)")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func saveNew() {
        let name = newCollectionName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let itemsToAdd = wishlistManager.wishlistItems.filter { wishlistManager.selectedItemIds.contains($0.id) }
        wishlistManager.createCollection(name: name, items: itemsToAdd)
        complete()
    }
    
    private func addItems(to collectionId: String) {
        let itemsToAdd = wishlistManager.wishlistItems.filter { wishlistManager.selectedItemIds.contains($0.id) }
        if let index = wishlistManager.collections.firstIndex(where: { $0.id == collectionId }) {
            // Filter out items already in the collection to prevent duplicates
            let existingItemIds = Set(wishlistManager.collections[index].items.map { $0.id })
            let uniqueItemsToAdd = itemsToAdd.filter { !existingItemIds.contains($0.id) }
            wishlistManager.collections[index].items.append(contentsOf: uniqueItemsToAdd)
        }
        complete()
    }
    
    private func complete() {
        wishlistManager.selectionMode = .none
        wishlistManager.selectedItemIds.removeAll()
        toastManager.show(message: "Added to Collection")
        dismiss()
    }
}
