//
//  InventoryView.swift
//  storage
//
//  Created by Andrés on 14/4/2025.
//

import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bin.createdAt, order: .reverse) private var bins: [Bin]
    @State private var searchText = ""
    @State private var showingAddBin = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredBins) { bin in
                    NavigationLink(destination: BinDetailView(bin: bin)) {
                        VStack(alignment: .leading) {
                            Text(bin.binDescription)
                                .font(.headline)
                            Text(bin.type)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteBins)
            }
            .navigationTitle("Inventory")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBin = true }) {
                        Label("Add Bin", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBin) {
                AddBinView()
            }
        }
    }
    
    private var filteredBins: [Bin] {
        if searchText.isEmpty {
            return Array(bins)
        }
        return bins.filter { bin in
            bin.binDescription.localizedCaseInsensitiveContains(searchText) ||
            bin.type.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func deleteBins(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(bins[index])
        }
    }
} 

struct BinDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let bin: Bin
    @State private var isEditing = false
    
    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Type", value: bin.type)
                LabeledContent("Description", value: bin.binDescription)
                if let link = bin.instructionLink {
                    if let url = URL(string: link) {
                        Link("Instructions", destination: url)
                    }
                }
                LabeledContent("Created", value: bin.createdAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .navigationTitle("Bin Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                AddBinView(bin: bin, isEditing: true)
            }
        }
    }
} 