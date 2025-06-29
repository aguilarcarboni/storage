//
//  WishListCSVImportView.swift
//  storage
//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct WishListCSVImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isImporting = false
    @State private var showingFilePicker = false
    @State private var importResult: ImportResult?
    @State private var selectedFileURL: URL?
    
    enum ImportResult {
        case success(count: Int)
        case error(message: String)
        
        var isSuccess: Bool {
            if case .success = self {
                return true
            }
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.blue)
                        
                        VStack(spacing: 8) {
                            Text("Import CSV File")
                                .font(.title2)
                                .bold()
                            
                            Text("Select a CSV file to import wish list items")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // CSV structure info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Required CSV Structure:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 4))
                                    .foregroundStyle(.secondary)
                                Text("name (string) - Required")
                            }
                            HStack {
                                Image(systemName: "circle")
                                    .font(.system(size: 4))
                                    .foregroundStyle(.secondary)
                                Text("url (string) - Optional")
                            }
                            HStack {
                                Image(systemName: "circle")
                                    .font(.system(size: 4))
                                    .foregroundStyle(.secondary)
                                Text("imagePaths (semicolon-separated) - Optional")
                            }
                        }
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    
                    // Selected file section
                    if let selectedFileURL {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundStyle(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Selected File:")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(selectedFileURL.lastPathComponent)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Import result section
                    if let result = importResult {
                        Group {
                            switch result {
                            case .success(let count):
                                VStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.green)
                                    Text("Successfully imported \(count) items!")
                                        .font(.headline)
                                        .foregroundStyle(.green)
                                }
                            case .error(let message):
                                VStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.red)
                                    Text("Import Failed")
                                        .font(.headline)
                                        .foregroundStyle(.red)
                                    Text(message)
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(result.isSuccess ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingFilePicker = true
                        }) {
                            HStack {
                                Image(systemName: "folder")
                                Text("Select CSV File")
                            }
                            .frame(minWidth: 200)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isImporting)
                        
                        if selectedFileURL != nil {
                            Button(action: {
                                importCSV()
                            }) {
                                HStack {
                                    if isImporting {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Importing...")
                                    } else {
                                        Image(systemName: "square.and.arrow.down")
                                        Text("Import")
                                    }
                                }
                                .frame(minWidth: 200)
                            }
                            .buttonStyle(.bordered)
                            .disabled(isImporting || selectedFileURL == nil)
                        }
                        
                        if case .success = importResult {
                            Button("Done") {
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: 500, maxHeight: .infinity)
            .frame(minWidth: 480, minHeight: 400)
            .navigationTitle("Import CSV")
            .navigationBarBackButtonHidden(isImporting)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isImporting)
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedFileURL = url
                        importResult = nil
                    }
                case .failure(let error):
                    importResult = .error(message: "Failed to select file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func importCSV() {
        guard let fileURL = selectedFileURL else { return }
        
        isImporting = true
        importResult = nil
        
        Task {
            do {
                // Start accessing the security-scoped resource
                let accessing = fileURL.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        fileURL.stopAccessingSecurityScopedResource()
                    }
                }
                
                let csvData = try String(contentsOf: fileURL, encoding: .utf8)
                let items = try parseCSV(csvData)
                
                await MainActor.run {
                    // Add items to model context
                    for item in items {
                        modelContext.insert(item)
                    }
                    
                    try? modelContext.save()
                    importResult = .success(count: items.count)
                    isImporting = false
                }
            } catch {
                await MainActor.run {
                    importResult = .error(message: error.localizedDescription)
                    isImporting = false
                }
            }
        }
    }
    
    private func parseCSV(_ csvContent: String) throws -> [WishListItem] {
        let lines = csvContent.components(separatedBy: .newlines)
        guard !lines.isEmpty else {
            throw CSVImportError.emptyFile
        }
        
        // Remove empty lines
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard nonEmptyLines.count >= 2 else {
            throw CSVImportError.insufficientData
        }
        
        // Parse header
        let header = parseCSVLine(nonEmptyLines[0])
        try validateHeader(header)
        
        // Create column mapping
        let columnMapping = createColumnMapping(header)
        
        var items: [WishListItem] = []
        
        for lineIndex in 1..<nonEmptyLines.count {
            let line = nonEmptyLines[lineIndex]
            let columns = parseCSVLine(line)
            
            guard columns.count == header.count else {
                throw CSVImportError.inconsistentColumns(line: lineIndex + 1)
            }
            
            do {
                let item = try createWishListItem(from: columns, using: columnMapping)
                items.append(item)
            } catch {
                throw CSVImportError.invalidData(line: lineIndex + 1, error: error.localizedDescription)
            }
        }
        
        return items
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var inQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                columns.append(currentColumn.trimmingCharacters(in: .whitespaces))
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
            
            i = line.index(after: i)
        }
        
        columns.append(currentColumn.trimmingCharacters(in: .whitespaces))
        return columns
    }
    
    private func validateHeader(_ header: [String]) throws {
        let requiredColumns = ["name"]
        let optionalColumns = ["url", "imagePaths"]
        let allowedColumns = requiredColumns + optionalColumns
        
        // Check for required columns
        for required in requiredColumns {
            if !header.contains(where: { $0.lowercased() == required.lowercased() }) {
                throw CSVImportError.missingRequiredColumn(required)
            }
        }
        
        // Check for unknown columns
        for column in header {
            if !allowedColumns.contains(where: { $0.lowercased() == column.lowercased() }) {
                throw CSVImportError.unknownColumn(column)
            }
        }
    }
    
    private func createColumnMapping(_ header: [String]) -> [String: Int] {
        var mapping: [String: Int] = [:]
        for (index, column) in header.enumerated() {
            mapping[column.lowercased()] = index
        }
        return mapping
    }
    
    private func createWishListItem(from columns: [String], using mapping: [String: Int]) throws -> WishListItem {
        guard let nameIndex = mapping["name"] else {
            throw CSVImportError.missingRequiredColumn("name")
        }
        
        let name = columns[nameIndex]
        guard !name.isEmpty else {
            throw CSVImportError.emptyRequiredField("name")
        }
        
        let url: String? = {
            if let urlIndex = mapping["url"] {
                let urlString = columns[urlIndex]
                return urlString.isEmpty ? nil : urlString
            }
            return nil
        }()
        
        let imagePaths: [String] = {
            if let imagePathsIndex = mapping["imagepaths"] {
                let paths = columns[imagePathsIndex]
                return paths.isEmpty ? [] : paths.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            }
            return []
        }()
        
        return WishListItem(
            name: name,
            url: url,
        )
    }
}

enum CSVImportError: LocalizedError {
    case emptyFile
    case insufficientData
    case missingRequiredColumn(String)
    case unknownColumn(String)
    case inconsistentColumns(line: Int)
    case invalidData(line: Int, error: String)
    case emptyRequiredField(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyFile:
            return "The CSV file is empty."
        case .insufficientData:
            return "The CSV file must contain at least a header row and one data row."
        case .missingRequiredColumn(let column):
            return "Missing required column: '\(column)'"
        case .unknownColumn(let column):
            return "Unknown column: '\(column)'. Only 'name', 'url', and 'imagePaths' are allowed."
        case .inconsistentColumns(let line):
            return "Line \(line) has a different number of columns than the header."
        case .invalidData(let line, let error):
            return "Invalid data on line \(line): \(error)"
        case .emptyRequiredField(let field):
            return "Required field '\(field)' cannot be empty."
        }
    }
}

#Preview {
    WishListCSVImportView()
        .modelContainer(for: WishListItem.self, inMemory: true)
} 
