//
//  SearchBar.swift
//  MyFirstApp
//
//  A reusable search bar component that provides a consistent search experience
//  across the application. Features include:
//  - Text input with clear button
//  - Search icon for better visual indication
//  - Smooth animations for focus state changes
//  - Auto-correction and auto-capitalization disabled for better search experience

import SwiftUI

/// A reusable search bar component that can be used across the app.
///
/// This view provides a consistent search interface with the following features:
/// - Displays a magnifying glass icon on the leading edge
/// - Shows a clear button when text is entered
/// - Supports focus state for keyboard management
/// - Includes smooth animations for state changes
/// - Disables auto-correction and auto-capitalization by default
struct SearchBar: View {
    // MARK: - Properties
    
    /// The text to display and edit in the search bar.
    @Binding var text: String
    
    /// A binding to manage the keyboard focus state of the search field.
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            // Search bar container
            HStack {
                // Search icon
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                // Search text field
                TextField("Search", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                // Clear button (visible when text is not empty)
                if !text.isEmpty {
                    Button(action: { 
                        // Clear the search text
                        text = "" 
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        // Smooth animation for focus state changes
        .animation(.easeInOut, value: isFocused)
        .padding(.vertical, 8)
    }
}

// MARK: - Previews

#Preview("Empty Search") {
    @State var searchText = ""
    return SearchBar(text: $searchText)
        .padding()
}

#Preview("With Text") {
    @State var searchText = "Sample search"
    return SearchBar(text: $searchText)
        .padding()
}

#Preview("Focused") {
    @State var searchText = ""
    return SearchBar(text: $searchText)
        .padding()
        .onAppear {
            // Focus the search field when preview appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Focus is handled by @FocusState in the view
            }
        }
}
