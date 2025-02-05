//
//  DataModel.swift
//  HealthTrendster
//
//  Created by Monty Giovenco on 5/2/2025.
//

import Foundation

struct DataPoint: Identifiable {
    let id = UUID()
    let date: Date
    var values: [String: Double?]  // Dictionary mapping parameter names to values
}

struct Metric: Identifiable {
    let id = UUID()
    let name: String
    let latestValue: Double?
    let unit: String
    let trend: Double
}
