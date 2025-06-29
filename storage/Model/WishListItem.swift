//
//  WishListItem.swift
//  storage
//
//  Created by Andrés on 14/4/2025.
//

import Foundation
import SwiftData
import CloudKit

@Model
final class WishListItem: Identifiable {
    var id: UUID = UUID()
    var name: String = ""
    var url: String?
    var created: Date = Date()
    var updated: Date = Date()
    
    init(
        name: String,
        url: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.created = Date()
        self.updated = Date()
    }
    
    // MARK: - Actions
    
    func updateItem(name: String? = nil, url: String? = nil) {
        if let name = name {
            self.name = name
        }
        if let url = url {
            self.url = url
        }
        self.updated = Date()
    }
    
    // MARK: - CloudKit Support
    
    /// Creates a CloudKit-compatible dictionary representation
    func cloudKitRecord() -> [String: Any] {
        var record: [String: Any] = [:]
        record["id"] = id.uuidString
        record["name"] = name
        record["url"] = url
        record["created"] = created
        record["updated"] = updated
        return record
    }
}
