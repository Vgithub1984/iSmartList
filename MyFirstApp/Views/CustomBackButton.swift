import SwiftUI

/// A custom back button that matches the app's design system
/// - Parameters:
///   - title: The title to display (defaults to "Back")
///   - action: The action to perform when the button is tapped
struct CustomBackButton: View {
    var title: String = "Back"
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.subheadline)
            }
            .foregroundColor(.accentColor)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomBackButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            CustomBackButton {}
            Spacer()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
