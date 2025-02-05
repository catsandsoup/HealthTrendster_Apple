//
//  Item.swift
//  HealthTrendster
//
//  Created by Monty Giovenco on 5/2/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
