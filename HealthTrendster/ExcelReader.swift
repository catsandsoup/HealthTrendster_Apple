import Foundation
import CoreXLSX

class ExcelReader {
    /// Parses the Excel file at the given URL and returns an array of DataPoint and an array of Metric.
    static func parse(fileURL: URL) -> (dataPoints: [DataPoint], metrics: [Metric])? {
        guard let file = XLSXFile(filepath: fileURL.path) else {
            print("Unable to open file")
            return nil
        }
        
        var dates: [Date] = []
        var parameterNames = Set<String>()
        var units: [String: String] = [:]
        var testData: [String: [Double?]] = [:]
        
        do {
            // Process the first workbook and sheet.
            let workbook = try file.parseWorkbooks().first!
            let worksheetPath = try file.parseWorksheetPathsAndNames(workbook: workbook).first!.path
            let worksheet = try file.parseWorksheet(at: worksheetPath)
            
            // Example: Assuming dates are in cells C1 to G1.
            for col in 0..<5 {
                let cellReference = ColumnReference("C")!.advanced(by: col).stringValue + "1"
                if let cell = worksheet.cells[cellReference],
                   let cellValue = cell.value,
                   let date = ISO8601DateFormatter().date(from: cellValue) {
                    dates.append(date)
                }
            }
            
            // Process rows 2 to 50 for parameters
            for row in 2...50 {
                // Get parameter name from column A
                let paramRef = "A\(row)"
                if let cell = worksheet.cells[paramRef], let param = cell.value, param != "Unit" {
                    parameterNames.insert(param)
                    // Get unit from column B
                    let unitRef = "B\(row)"
                    units[param] = worksheet.cells[unitRef]?.value ?? ""
                    
                    // Initialize an empty array for this parameter’s values
                    testData[param] = []
                    // Read values from columns C to G.
                    for col in 0..<dates.count {
                        let colLetter = ColumnReference("C")!.advanced(by: col).stringValue
                        let cellRef = "\(colLetter)\(row)"
                        if let valueStr = worksheet.cells[cellRef]?.value,
                           let value = Double(valueStr) {
                            testData[param]?.append(value)
                        } else {
                            testData[param]?.append(nil)
                        }
                    }
                }
            }
            
            // Build the chart data points.
            var dataPoints: [DataPoint] = []
            for (index, date) in dates.enumerated() {
                var values: [String: Double?] = [:]
                for param in parameterNames {
                    values[param] = testData[param]?[index] ?? nil
                }
                dataPoints.append(DataPoint(date: date, values: values))
            }
            
            // Calculate metrics.
            var metrics: [Metric] = []
            for param in parameterNames {
                if let values = testData[param] {
                    // Filter out nil values.
                    let validValues = values.compactMap { $0 }
                    let latest = validValues.last
                    let previous = validValues.count >= 2 ? validValues[validValues.count - 2] : nil
                    let trend = (latest != nil && previous != nil) ? latest! - previous! : 0.0
                    let metric = Metric(name: param, latestValue: latest, unit: units[param] ?? "", trend: trend)
                    metrics.append(metric)
                }
            }
            
            return (dataPoints, metrics)
        } catch {
            print("Error parsing Excel file: \(error)")
            return nil
        }
    }
}
