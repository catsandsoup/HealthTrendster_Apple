//
//  DashboardView.swift
//  HealthTrendster
//
//  Created by Monty Giovenco on 5/2/2025.
//


import SwiftUI
import Charts

struct DashboardView: View {
    let dataPoints: [DataPoint]
    let metrics: [Metric]
    @Binding var selectedParameter: String?

    var body: some View {
        ScrollView {  // <-- Enables scrolling
            VStack(spacing: 20) {
                // Header with parameter selection.
                HStack {
                    Label("Blood Tests", systemImage: "waveform.path.ecg")
                        .font(.title2)
                    Spacer()
                    if !metrics.isEmpty {
                        Picker("Select Parameter", selection: $selectedParameter) {
                            ForEach(metrics, id: \.id) { metric in
                                Text(metric.name).tag(metric.name as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                .padding([.leading, .trailing])

                // Chart view
                if let parameter = selectedParameter {
                    Chart {
                        ForEach(dataPoints) { point in
                            if let value = point.values[parameter] as? Double {
                                LineMark(
                                    x: .value("Date", point.date),
                                    y: .value("Value", value)
                                )
                                .foregroundStyle(Color.red)
                                .interpolationMethod(.catmullRom)
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 5)) { value in
                            if let dateValue = value.as(Date.self) {
                                AxisValueLabel(formatDate(dateValue))
                            }
                        }
                    }
                    .frame(height: 250)
                    .padding()
                }

                // Health Metric Cards Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                    ForEach(metrics) { metric in
                        HealthMetricCard(
                            title: metric.name,
                            value: metric.latestValue != nil ? String(format: "%.1f", metric.latestValue!) : "N/A",
                            unit: metric.unit,
                            trend: metric.trend,
                            isSelected: metric.name == selectedParameter,
                            onClick: {
                                selectedParameter = metric.name
                            }
                        )
                    }
                }
                .padding()
            }
            .padding()
        }
        .frame(minWidth: 800, minHeight: 600)  // Ensures a minimum size
    }

    // Format the date for the X-axis.
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}
xx
