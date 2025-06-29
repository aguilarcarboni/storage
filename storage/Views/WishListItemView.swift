//
//  WishListItemView.swift
//  storage
//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI

struct WishListItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let item: WishListItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if let url = item.url, !url.isEmpty {
                    Link(destination: URL(string: url) ?? URL(string: "https://")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.caption)
                            Text("URL")
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
           
            // Metadata
            HStack {
                Text("Added \(item.created.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if item.updated > item.created {
                    Text("Updated \(item.updated.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .cornerRadius(12)
    }
}
