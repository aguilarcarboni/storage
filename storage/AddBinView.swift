//
//  AddBinView.swift
//  storage
//
//  Created by Andrés on 14/4/2025.
//

import SwiftUI
import SwiftData
import CoreImage.CIFilterBuiltins
import UniformTypeIdentifiers

struct AddBinView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var bin: Bin?
    var isEditing: Bool = false
    
    @State private var type = "Set"
    @State private var binDescription = ""
    @State private var instructionLink = ""
    @State private var showingQRCode = false
    @State private var qrCodeImage: UIImage?
    
    let types = ["Set", "Loose"]
    
    init(bin: Bin? = nil, isEditing: Bool = false) {
        self.bin = bin
        self.isEditing = isEditing
        
        if let bin = bin {
            _type = State(initialValue: bin.type)
            _binDescription = State(initialValue: bin.binDescription)
            _instructionLink = State(initialValue: bin.instructionLink ?? "")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    TextField("Description", text: $binDescription)
                    
                    if type == "Set" {
                        TextField("Instruction Link (Optional)", text: $instructionLink)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                    }
                }
                
                if isEditing, let bin = bin {
                    Section("QR Code") {
                        Button("Show QR Code") {
                            generateQRCode(for: bin.id)
                            showingQRCode = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Bin" : "New Bin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        if isEditing, let bin = bin {
                            updateBin(bin)
                        } else {
                            addBin()
                        }
                        dismiss()
                    }
                    .disabled(binDescription.isEmpty)
                }
            }
            .sheet(isPresented: $showingQRCode) {
                QRCodeView(image: qrCodeImage, binDescription: binDescription)
            }
        }
    }
    
    private func addBin() {
        let newBin = Bin(
            type: type,
            binDescription: binDescription,
            instructionLink: !instructionLink.isEmpty ? instructionLink : nil
        )
        modelContext.insert(newBin)
        generateQRCode(for: newBin.id)
        showingQRCode = true
    }
    
    private func updateBin(_ bin: Bin) {
        bin.type = type
        bin.binDescription = binDescription
        bin.instructionLink = !instructionLink.isEmpty ? instructionLink : nil
    }
    
    private func generateQRCode(for id: String) {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(id.utf8)
        filter.correctionLevel = "H"
        
        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            let resizedImage = UIImage(cgImage: cgImage, scale: 3.0, orientation: .up)
            self.qrCodeImage = resizedImage
        }
    }
}

struct TransferableImage: Transferable {
    let image: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .png) { image in
            // Exporting
            guard let data = image.image.pngData() else {
                throw TransferError.conversionFailed
            }
            return data
        } importing: { data in
            // Importing
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.conversionFailed
            }
            return TransferableImage(image: uiImage)
        }
    }
    
    enum TransferError: Error {
        case conversionFailed
    }
}

struct QRCodeView: View {
    let image: UIImage?
    let binDescription: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                    
                    Text(binDescription)
                        .font(.headline)
                        .padding()
                    
                    ShareLink(
                        item: TransferableImage(image: image),
                        preview: SharePreview(
                            "QR Code for \(binDescription)",
                            image: Image(uiImage: image)
                        )
                    )
                    .padding()
                } else {
                    Text("Failed to generate QR code")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 