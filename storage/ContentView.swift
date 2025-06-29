//
//  ContentView.swift
//  media
//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var wishListItems: [WishListItem]
    @StateObject private var cloudKitManager = CloudKitManager.shared
    
    @State private var showingCreateSheet = false
    @State private var showingImportSheet = false
    @State private var selectedWishListItem: WishListItem?
    @State private var showingWishListItemDetail = false
    @State private var selectedSidebarItem: SidebarItem? = .wishList

    var body: some View {
        NavigationSplitView {
            // Sidebar - selectable list of media types
            List(selection: $selectedSidebarItem) {
                Section {
                    ForEach(SidebarItem.allCases, id: \.self) { item in
                        NavigationLink(value: item) {
                            Label(item.rawValue, systemImage: item.systemImage)
                        }
                    }
                }
                
                Section("Sync Status") {
                    HStack {
                        Image(systemName: cloudKitManager.isSignedInToiCloud ? "icloud.fill" : "icloud.slash")
                            .foregroundColor(cloudKitManager.isSignedInToiCloud ? .blue : .gray)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cloudKitManager.isSignedInToiCloud ? "iCloud Connected" : "iCloud Disconnected")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            Text(cloudKitManager.syncStatus.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if case .syncing = cloudKitManager.syncStatus {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                    }
                    .onTapGesture {
                        Task {
                            await cloudKitManager.forceSyncNow()
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Wish List")
            .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 250)

        } detail: {
            // Detail view
            Group {
                switch selectedSidebarItem {
                case .wishList:
                    WishListView(
                        wishListItems: wishListItems,
                    )
                case .none:
                    VStack(spacing: 16) {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("Select a category from the sidebar")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .cloudKitStatusAlert()
        .task {
            await cloudKitManager.checkCloudKitStatus()
        }
    }
}

enum SidebarItem: String, CaseIterable, Identifiable {
    case wishList = "Wish List"
    
    var id: String { self.rawValue }
    
    var systemImage: String {
        switch self {
        case .wishList:
            return "heart"
        }
    }
}
