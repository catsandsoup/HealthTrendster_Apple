import Foundation
import CoreXLSX

class ExcelReader {
    /// Parses the Excel file at the given URL and returns an array of DataPoint and an array of Metric.
    static func parse(fileURL: URL) -> (dataPoints: [DataPoint], metrics: [Metric])? {
        // Start accessing the security-scoped resource.
        guard fileURL.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource")
            return nil
        }
        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }
        
        print("Attempting to parse file at path: \(fileURL.path)")
        guard let file = XLSXFile(filepath: fileURL.path) else {
            print("Unable to open file at path: \(fileURL.path)")
            return nil
        }
        
        var dates: [Date] = []
        var parameterNames = Set<String>()
        var units: [String: String] = [:]
        var testData: [String: [Double?]] = [:]
        
        do {
            // Process the first workbook and worksheet.
            let workbook = try file.parseWorkbooks().first!
            let worksheetPath = try file.parseWorksheetPathsAndNames(workbook: workbook).first!.path
            let worksheet = try file.parseWorksheet(at: worksheetPath)
            
            // Parse shared strings and ensure we have them.
            guard let sharedStrings = try file.parseSharedStrings() else {
                print("No shared strings found")
                return nil
            }
            
            // Get all cells for efficiency.
            let cells = worksheet.data?.rows.flatMap { $0.cells } ?? []
            print("Found \(cells.count) cells in worksheet")
            
            // Define the columns for date headers (assumed to be in row 1, columns C to G).
            let colLetters = "CDEFG"
            
            // Parse the date headers in row 1.
            for col in 0..<5 {
                let cellReference = colLetters[col] + "1"
                if let cell = cells.first(where: { $0.reference.description == cellReference }),
                   let cellValue = cell.value {
                    
                    // 1. Try ISO8601 format first.
                    if let date = ISO8601DateFormatter().date(from: cellValue) {
                        dates.append(date)
                    } else {
                        // 2. Try the "dd/MM/yyyy" format.
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd/MM/yyyy"
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        if let date = formatter.date(from: cellValue) {
                            dates.append(date)
                        } else if let excelSerialNumber = Double(cellValue) {
                            // 3. Attempt Excel serial date conversion.
                            let excelEpoch = DateComponents(calendar: Calendar(identifier: .gregorian), year: 1900, month: 1, day: 1).date!
                            let date = Calendar.current.date(byAdding: .day, value: Int(excelSerialNumber) - 2, to: excelEpoch)!
                            dates.append(date)
                        } else {
                            print("Failed to parse date at \(cellReference): \(cellValue)")
                        }
                    }
                } else {
                    print("No cell found at \(cellReference)")
                }
            }
            print("Parsed \(dates.count) dates")
            
            // Process rows 2 to 50 for parameters.
            for row in 2...50 {
                let paramRef = "A\(row)"
                if let cell = cells.first(where: { $0.reference.description == paramRef }),
                   let param = cell.stringValue(sharedStrings),
                   param != "Unit" {
                    parameterNames.insert(param)
                    
                    // Get the unit from column B.
                    let unitRef = "B\(row)"
                    if let unitCell = cells.first(where: { $0.reference.description == unitRef }) {
                        units[param] = unitCell.stringValue(sharedStrings) ?? ""
                    }
                    
                    // Initialize an empty array for this parameter's values.
                    testData[param] = []
                    
                    // Read values from columns C to G.
                    for col in 0..<dates.count {
                        let colLetter = colLetters[col]
                        let cellRef = "\(colLetter)\(row)"
                        if let valueCell = cells.first(where: { $0.reference.description == cellRef }),
                           let valueStr = valueCell.value,
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
            print("Constructed \(dataPoints.count) data points")
            
            // Calculate metrics.
            var metrics: [Metric] = []
            for param in parameterNames {
                if let values = testData[param] {
                    let validValues = values.compactMap { $0 }
                    let latest = validValues.last
                    let previous = validValues.count >= 2 ? validValues[validValues.count - 2] : nil
                    let trend = (latest != nil && previous != nil) ? latest! - previous! : 0.0
                    let metric = Metric(name: param, latestValue: latest, unit: units[param] ?? "", trend: trend)
                    metrics.append(metric)
                }
            }
            print("Calculated \(metrics.count) metrics")
            
            return (dataPoints, metrics)
        } catch {
            print("Error parsing Excel file: \(error)")
            return nil
        }
    }
}

// Extension to help with string subscripting.
extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
