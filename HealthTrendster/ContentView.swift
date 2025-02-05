//
//  ContentView.swift
//  HealthTrendster
//
//  Created by Monty Giovenco on 5/2/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var dataPoints: [DataPoint] = []
    @State private var metrics: [Metric] = []
    @State private var selectedParameter: String? = nil

    var body: some View {
        VStack {
            if dataPoints.isEmpty {
                // Show the file import view if no data is loaded.
                FileImportView { importedDataPoints, importedMetrics in
                    dataPoints = importedDataPoints
                    metrics = importedMetrics
                    selectedParameter = importedMetrics.first?.name
                }
            } else {
                // Show the dashboard view if data exists.
                DashboardView(dataPoints: dataPoints,
                              metrics: metrics,
                              selectedParameter: $selectedParameter)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
