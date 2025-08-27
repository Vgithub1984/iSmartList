import SwiftUI

struct InfoRow: View {
    let icon: String
    let title: String
    var showChevron: Bool = true
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    List {
        InfoRow(icon: "doc.text", title: "Terms of Service")
        InfoRow(icon: "hand.raised", title: "Privacy Policy")
        InfoRow(icon: "questionmark.circle", title: "Help & Support")
        InfoRow(icon: "star", title: "Rate This App")
    }
}
