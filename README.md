# MyFirstApp - Shopping List Manager

A modern, intuitive iOS application for managing shopping lists with a clean and user-friendly interface.

## Features

### Core Functionality
- Create and manage multiple shopping lists
- Soft delete lists (move to trash)
- Permanently delete lists
- Restore deleted lists from trash
- View list creation and deletion timestamps
- Search functionality for lists
- Swipe actions for quick operations

### UI/UX
- Tab-based navigation (Lists, Deleted, Stats, Profile)
- Floating action button for adding new lists
- Confirmation dialogs for destructive actions
- Empty state views with helpful messages
- Smooth animations and transitions

## Technical Details

### Architecture
- MVVM (Model-View-ViewModel) pattern
- EnvironmentObject for state management
- @State and @Binding for view state

### Data Management
- Data persistence using UserDefaults
- JSON encoding/decoding for list storage
- In-memory data management with DataStore class

### Views
1. **ContentView**
   - Main container with tab view
   - Floating action button for adding lists
   - Tab navigation between sections

2. **ListsView**
   - Displays all active shopping lists
   - Search functionality
   - Swipe to delete
   - List details navigation

3. **DeletedView**
   - Shows soft-deleted lists
   - Options to restore or permanently delete
   - Empty state handling

4. **ListDetailView**
   - View for individual list contents
   - Item management
   - List editing

### Data Model
```swift
struct MyList: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var created: Date
    var isDeleted: Bool
    var deletedAt: Date?
    var itemsData: Data?
}
```

## Getting Started

### Prerequisites
- Xcode 13.0+
- iOS 15.0+
- Swift 5.5+

### Installation
1. Clone the repository
2. Open `MyFirstApp.xcodeproj` in Xcode
3. Build and run the project on a simulator or device

## Usage

### Creating a New List
1. Tap the + button in the bottom-right corner
2. A new list will be created with a default name
3. Tap on the list to add items

### Managing Lists
- **Swipe Left/Right**: Reveal actions
- **Tap**: Open list details
- **Swipe to Delete**: Move list to trash

### Working with Deleted Items
- View deleted lists in the "Deleted" tab
- Swipe to restore or permanently delete
- Use "Delete All" to empty trash

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI
- Uses native iOS design patterns
- Follows Apple's Human Interface Guidelines
