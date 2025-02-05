import SwiftUI

struct HealthMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let trend: Double
    let isSelected: Bool
    let onClick: () -> Void
    
    // Return an appropriate image for the trend.
    private var trendIcon: some View {
        if trend > 0 {
            return Image(systemName: "arrow.up")
                .foregroundColor(.green)
        } else if trend < 0 {
            return Image(systemName: "arrow.down")
                .foregroundColor(.red)
        } else {
            return Image(systemName: "circle.fill")
                .foregroundColor(.gray)
        }
    }
    
    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    trendIcon
                        .font(.caption)
                }
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HealthMetricCard_Previews: PreviewProvider {
    static var previews: some View {
        HealthMetricCard(
            title: "Hemoglobin",
            value: "14.5",
            unit: "g/dL",
            trend: 0.3,
            isSelected: true,
            onClick: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
