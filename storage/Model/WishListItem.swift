//
//  WishListItem.swift
//  storage
//
//  Created by Andrés on 14/4/2025.
//

import Foundation
import SwiftData

@Model
final class WishListItem {
    var id: UUID
    var name: String
    var url: String?
    var created: Date
    var updated: Date
    
    init(
        name: String,
        url: String? = nil,
    ) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.created = Date()
        self.updated = Date()
    }
}
