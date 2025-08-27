# MyFirstApp - Shopping List Manager

## 📋 Version History

### v1.1 (2025-08-26)
- Updated project version to 1.1
- Incremented build number to 2
- Added version history documentation

### v1.0 (Initial Release)
- Initial release with core shopping list functionality

A modern, intuitive iOS application for managing shopping lists with a clean and user-friendly interface, built with SwiftUI.

## 🚀 Features

### Core Functionality
- ✅ Create and manage multiple shopping lists
- ✅ Add, edit, and remove items within lists
- ✅ Mark items as purchased
- ✅ Track completion progress for each list
- ⏳ Soft delete lists (move to trash) with restore capability
- ⏳ Permanently delete lists individually or all at once
- ⏳ Search functionality for active and deleted lists
- ⚠️ Confirmation dialogs for destructive actions (delete, restore, empty trash)
- ➕ Floating action button for adding new lists with modern dialogs
- 🔢 Tab badges indicating counts of lists and deleted items

### UI/UX
- 🎨 Clean, modern interface with smooth animations
- 📱 Tab-based navigation with clearly defined sections:
  - Lists: Active shopping lists with swipe actions and search
  - Deleted: Soft-deleted lists with options to restore or permanently delete
  - Stats: Progress tracking and usage statistics
  - Profile: User profile info and app settings with improved layout
- 📝 Empty state views providing helpful messages and guidance for each tab
- 🔄 Pull-to-refresh support for lists and deleted items
- 🎯 Visual progress indicators for list completion

## 🛠 Technical Details

### Architecture & State Management
- **MVVM** (Model-View-ViewModel) pattern for clean separation
- **@MainActor** annotation on DataStore for thread-safe UI updates
- **@EnvironmentObject** for global shared state injection
- **@State** and **@Binding** for local view state management
- **ObservableObject** enables reactive UI updates on model changes
- Soft-delete pattern through `isDeleted` and `deletedAt` properties

### Data Management
- Persistent storage using **UserDefaults**
- Data encoded/decoded using **JSON** for lists and their items
- Centralized **DataStore** class managing all data operations and syncing
- Codable, Identifiable, and Hashable data models for type safety

### Views
- **ContentView**: Main tab container with floating action button and tab badges
- **ListsView**: Displays active shopping lists with search and swipe actions
- **ListDetailView**: Manage individual list contents, items, and progress
- **DeletedView**: Shows soft-deleted lists with restore/permanent delete options
- **ProfileView**: User profile and app settings interface

## 📂 Project Structure

- App/
  - MyFirstAppApp.swift   // App entry point and environment setup
- Views/
  - ContentView.swift     // Main tab container and app navigation
  - ListsView.swift       // Displays all active shopping lists
  - ListDetailView.swift  // Shows and manages items in a specific list
  - DeletedView.swift     // Manages deleted lists and restoration
  - ProfileView.swift     // User profile/settings interface
- Models/
  - MyList.swift          // Shopping list data model definition
- ViewModels/
  - DataStore.swift       // Central app state and data management
- Supporting/
  - README.md             // This file (moved as part of project structuring)
  - DevGuide.md           // Developer guide and onboarding

### Getting Started

1. Clone the repository
2. Open `MyFirstApp.xcodeproj` in Xcode 15+
3. Build & run on simulator or device (iOS 17+ recommended)

### Contribution & Support

- Contributions welcome: Fork, branch, and submit pull requests.
- For bug reports or feature requests, open an issue in the tracker.

---
