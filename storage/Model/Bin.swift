// Bin.swift
//  storage
//
//  Created by Andrés on 14/4/2025.
//

import Foundation
import SwiftData

@Model
final class Bin {
    @Attribute(.unique) var id: String
    var type: String
    var binDescription: String
    var instructionLink: String?
    var createdAt: Date
    
    init(id: String = UUID().uuidString, type: String, binDescription: String, instructionLink: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.type = type
        self.binDescription = binDescription
        self.instructionLink = instructionLink
        self.createdAt = createdAt
    }
}
