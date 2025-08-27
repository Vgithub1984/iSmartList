import SwiftUI

struct StorageItemView: View {
    let icon: String
    let title: String
    let size: String
    let percentage: Double
    
    private var progressColor: Color {
        switch percentage {
        case 0.7...1.0: return .red
        case 0.4..<0.7: return .orange
        default: return .green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                
                Spacer()
                
                Text(size)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 4)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(percentage) * geometry.size.width, geometry.size.width), 
                               height: 4)
                        .foregroundColor(progressColor)
                        .animation(.linear, value: percentage)
                }
                .cornerRadius(2)
            }
            .frame(height: 4)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        StorageItemView(icon: "list.bullet", title: "Shopping Lists", size: "850 MB", percentage: 0.7)
        StorageItemView(icon: "photo", title: "Images", size: "250 MB", percentage: 0.2)
        StorageItemView(icon: "doc.text", title: "Documents", size: "100 MB", percentage: 0.1)
    }
    .padding()
}
