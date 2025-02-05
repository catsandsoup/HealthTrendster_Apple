import SwiftUI
import UniformTypeIdentifiers

struct FileImportView: View {
    /// Completion handler returns the parsed data points and metrics.
    var onFileImported: (_ dataPoints: [DataPoint], _ metrics: [Metric]) -> Void
    @State private var isImporting: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Import Blood Test Results")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("Upload your lab results to track your health metrics over time")
                .foregroundColor(.gray)
            
            Button(action: {
                isImporting = true
            }) {
                VStack {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                        .foregroundColor(.red)
                    Text("Click to Upload")
                        .font(.headline)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [UTType(filenameExtension: "xlsx")!, UTType(filenameExtension: "xls")!],
                onCompletion: { result in
                    switch result {
                    case .success(let url):
                        if let (dataPoints, metrics) = ExcelReader.parse(fileURL: url) {
                            onFileImported(dataPoints, metrics)
                        }
                    case .failure(let error):
                        print("Failed to import file: \(error)")
                    }
                }
            )
            
            Text("Supports Excel (.xlsx, .xls) files")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct FileImportView_Previews: PreviewProvider {
    static var previews: some View {
        FileImportView { _, _ in }
    }
}
