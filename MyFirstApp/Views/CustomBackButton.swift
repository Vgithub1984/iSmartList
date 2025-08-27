//
//  CustomBackButton.swift
//  MyFirstApp
//
//  A reusable custom back button component that provides a consistent
//  navigation experience across the app. Features include:
//  - Customizable title with default value
//  - Chevron icon for visual indication
//  - Subtle background highlight on tap
//  - Matches app's design system

import SwiftUI

/// A custom back button that matches the app's design system.
///
/// This component provides a consistent back button experience throughout the app
/// with the following features:
/// - Customizable title with a default value of "Back"
/// - Chevron icon for clear visual indication of navigation
/// - Subtle background highlight for better touch feedback
/// - Matches the app's color scheme and design language
///
/// - Parameters:
///   - title: The title to display next to the back arrow (defaults to "Back")
///   - action: The closure to execute when the button is tapped
struct CustomBackButton: View {
    // MARK: - Properties
    
    /// The text displayed next to the back arrow icon.
    /// Defaults to "Back" if not specified.
    var title: String = "Back"
    
    /// The action to perform when the button is tapped.
    var action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                // Back arrow icon
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                
                // Button text
                Text(title)
                    .font(.subheadline)
            }
            // Styling
            .foregroundColor(.accentColor)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.1))
            )
        }
        // Remove default button styling for custom appearance
        .buttonStyle(PlainButtonStyle())
        // Improve accessibility
        .accessibilityLabel("Back")
        .accessibilityHint("Navigates to the previous screen")
    }
}

// MARK: - Previews

struct CustomBackButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default back button
            HStack {
                CustomBackButton {}
                Spacer()
            }
            .padding()
            .previewDisplayName("Default")
            
            // Custom title
            HStack {
                CustomBackButton(title: "Go Back") {}
                Spacer()
            }
            .padding()
            .previewDisplayName("Custom Title")
            
            // Dark mode
            HStack {
                CustomBackButton(title: "Back") {}
                Spacer()
            }
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .previewLayout(.sizeThatFits)
    }
}
