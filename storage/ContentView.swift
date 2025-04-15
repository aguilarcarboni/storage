//
//  ContentView.swift
//  storage
//
//  Created by Andrés on 14/4/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "box.fill")
                }
            
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
        }
    }
}

#Preview {
    ContentView()
}
