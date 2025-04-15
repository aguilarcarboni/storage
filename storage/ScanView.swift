//
//  ScanView.swift
//  storage
//
//  Created by Andrés on 14/4/2025.
//

import SwiftUI
import AVFoundation
import SwiftData

struct ScanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingScanner = false
    @State private var showingBinDetail = false
    @State private var scannedBin: Bin?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    checkCameraPermission()
                }) {
                    VStack {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 100))
                        Text("Scan QR Code")
                            .font(.headline)
                            .padding(.top)
                    }
                    .foregroundColor(.blue)
                    .padding()
                }
                .sheet(isPresented: $isShowingScanner) {
                    QRScannerView(completion: handleScan)
                }
                
                Text("Point camera at a bin's QR code")
                    .foregroundColor(.secondary)
                    .padding()
            }
            .navigationTitle("Scan")
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingBinDetail) {
                if let bin = scannedBin {
                    NavigationStack {
                        BinDetailView(bin: bin)
                    }
                }
            }
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isShowingScanner = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    isShowingScanner = true
                }
            }
        default:
            errorMessage = "Camera access is required to scan QR codes. Please enable it in Settings."
            showingError = true
        }
    }
    
    private func handleScan(_ result: Result<String, Error>) {
        isShowingScanner = false
        
        switch result {
        case .success(let code):
            findBin(withId: code)
        case .failure:
            errorMessage = "Failed to scan QR code. Please try again."
            showingError = true
        }
    }
    
    private func findBin(withId id: String) {
        let descriptor = FetchDescriptor<Bin>(
            predicate: #Predicate<Bin> { bin in
                bin.id == id
            }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            if let bin = results.first {
                scannedBin = bin
                showingBinDetail = true
            } else {
                errorMessage = "No bin found with this QR code."
                showingError = true
            }
        } catch {
            errorMessage = "Failed to look up bin. Please try again."
            showingError = true
        }
    }
} 