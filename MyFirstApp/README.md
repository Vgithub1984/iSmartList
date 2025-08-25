# MyFirstApp - Shopping List Manager

A modern, intuitive iOS application for managing shopping lists with a clean and user-friendly interface, built with SwiftUI.

## 🚀 Features

### Core Functionality
- ✅ Create and manage multiple shopping lists
- ✅ Add, edit, and remove items within lists
- ✅ Mark items as purchased
- ✅ Track completion progress for each list
- ⏳ Soft delete lists (move to trash)
- ⏳ Permanently delete lists
- ⏳ Restore deleted lists from trash
- ⏳ Search functionality for lists

### UI/UX
- 🎨 Clean, modern interface with smooth animations
- 📱 Tab-based navigation (Lists, Deleted, Stats, Profile)
- ➕ Floating action button for adding new lists
- ⚠️ Confirmation dialogs for destructive actions
- 📝 Empty state views with helpful messages
- 🎯 Progress tracking for list completion
- 🔄 Pull-to-refresh support

## 🛠 Technical Details

### Architecture
- **MVVM** (Model-View-ViewModel) pattern
- **@EnvironmentObject** for state management
- **@State** and **@Binding** for view state
- **ObservableObject** for reactive updates

### Data Management
- **UserDefaults** for persistent storage
- **JSON** encoding/decoding for list storage
- **DataStore** class for centralized data management
- Type-safe data models with **Codable** conformance

### Views
1. **ContentView**
   - Main container with tab-based navigation
   - Floating action button for new lists
   - Tab bar with badges for list counts

2. **ListsView**
   - Displays all active shopping lists
   - Swipe actions for quick operations
   - Search functionality

3. **ListDetailView**
   - View and manage individual lists
   - Add/remove items
   - Track completion progress
   - Mark items as purchased

4. **DeletedView**
   - View soft-deleted lists
   - Restore or permanently delete lists
   - Empty state with helpful message

5. **ProfileView**
   - User profile information
   - App settings and preferences

## 📂 Project Structure
```
MyFirstApp/
├── MyFirstApp/
│   ├── Models/
│   │   └── MyList.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── ListsView.swift
│   │   ├── ListDetailView.swift
│   │   ├── DeletedView.swift
│   │   └── ProfileView.swift
│   ├── ViewModels/
│   │   └── DataStore.swift
│   └── Assets.xcassets/
└── MyFirstApp.xcodeproj/
```

## 🔧 Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## 🚀 Getting Started
1. Clone the repository
2. Open `MyFirstApp.xcodeproj` in Xcode
3. Build and run the project on a simulator or device

## 📝 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
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


## Author

Created by Varun Patel, 2025-08-25.
