//
//  WishListView.swift
//  storage
//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI
import SwiftData

struct WishListView: View {
    let wishListItems: [WishListItem]
    @State private var showingCreateItem = false
    @State private var showingCSVImport = false
    
    var body: some View {
        NavigationStack {
            Group {
                if wishListItems.isEmpty {
                    // Empty state
                    ContentUnavailableView(
                        "No Wish List Items",
                        systemImage: "heart",
                        description: Text("Add items to your wish list or import from CSV")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(wishListItems) { item in
                                WishListItemView(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Wish List")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingCSVImport = true
                        } label: {
                            Label("Import from CSV", systemImage: "doc.text")
                        }
                }
            }
        }
        .sheet(isPresented: $showingCreateItem) {
            CreateWishListItemView()
        }
        .sheet(isPresented: $showingCSVImport) {
            WishListCSVImportView()
        }
    }
}
