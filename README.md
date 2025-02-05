## I broke it and don't know how to fix it ##

# HealthTrendster Universal App

HealthTrendster is a SwiftUI application that helps users track and visualize their blood test results over time. The app provides an intuitive interface for importing Excel-based blood test data and displays trends and metrics in an easy-to-understand format.

## Features

- 📊 Import blood test results from Excel files (.xlsx, .xls)
- 📈 Visualize health metrics over time
- 🔍 Track trends and changes in your blood test results
- 📱 Native macOS interface built with SwiftUI
- 🎨 Beautiful, interactive metric cards with trend indicators

## Requirements

- macOS 11.0 or later
- Xcode 14.0 or later
- Swift 5.5 or later

## Dependencies

- CoreXLSX - For parsing Excel files
- SwiftUI - For the user interface
- SwiftData - For data persistence

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/HealthTrendster.git
```

2. Install dependencies using Swift Package Manager:
   - Open the project in Xcode
   - Wait for the dependencies to be resolved automatically

3. Build and run the project in Xcode

## Usage

1. Launch HealthTrendster
2. Click the "Upload" button to import your blood test Excel file
3. Select the health metric you want to analyze from the dashboard
4. View trends and changes over time

### Excel File Format
Your Excel file should have the following structure:
- First column: Dates (MM/DD/YYYY format)
- Subsequent columns: Blood test parameters with their values
- First row: Header names for each parameter

## Architecture

The app follows a modern SwiftUI architecture with:
- SwiftUI views for the user interface
- Dedicated data models for blood test metrics
- Excel parsing utility for data import
- SwiftData for persistent storage

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

- Thanks to CoreOffice team for CoreXLSX
- Apple for SwiftUI and SwiftData
