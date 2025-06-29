//
//  CreateWishListItemView.swift
//  storage
//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI
import SwiftData

struct CreateWishListItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var url = ""
    @State private var imagePathsText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $name)
                    
                    TextField("URL (optional)", text: $url)
                    
                }
            }
            .navigationTitle("Add Wish List Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedUrl = url.trimmingCharacters(in: .whitespaces)
        let imagePaths = imagePathsText.components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let newItem = WishListItem(
            name: trimmedName,
            url: trimmedUrl.isEmpty ? nil : trimmedUrl,
        )
        
        modelContext.insert(newItem)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving wish list item: \(error)")
        }
    }
}

#Preview {
    CreateWishListItemView()
        .modelContainer(for: WishListItem.self, inMemory: true)
} 
