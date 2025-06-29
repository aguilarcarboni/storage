//
//  ContentView.swift
//  storage
//
//  Created by Andrés on 14/4/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedView: SidebarItem? = .wishList
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SidebarItem.allCases, id: \.self, selection: $selectedView) { item in
                NavigationLink(value: item) {
                    Label(item.title, systemImage: item.systemImage)
                }
            }
            .navigationTitle("Storage")
        } detail: {
            // Detail view
            Group {
                switch selectedView {
                case .wishList:
                    WishListView()
                case .none:
                    Text("Select an item from the sidebar")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

enum SidebarItem: CaseIterable {
    case wishList
    
    var title: String {
        switch self {
        case .wishList:
            return "Wish List"
        }
    }
    
    var systemImage: String {
        switch self {
        case .wishList:
            return "heart.fill"
        }
    }
}

#Preview {
    ContentView()
}
