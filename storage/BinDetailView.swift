//
//  BinDetailView.swift
//  storage
//
//  Created by Andrés on 14/4/2025.
//

import SwiftUI
import SwiftData

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