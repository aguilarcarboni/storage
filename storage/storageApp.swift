//
//  storageApp.swift
//  storage
//
//  Created by Andrés on 14/4/2025.
//

import SwiftUI
import SwiftData

@main
struct LegoStorageApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Bin.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
