# MyFirstApp - Technical Documentation

## Version History

### v1.1 (2025-08-26)
- **Version**: 1.1
- **Build**: 2
- **Changes**:
  - Updated project version to 1.1
  - Incremented build number to 2
  - Added version history documentation

### v1.0 (Initial Release)
- **Version**: 1.0
- **Build**: 1
- **Changes**:
  - Initial release with core shopping list functionality
  - Basic CRUD operations for lists and items
  - UserDefaults-based persistence


## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Data Model](#data-model)
3. [View Hierarchy](#view-hierarchy)
4. [State Management](#state-management)
5. [Key Components](#key-components)
6. [Persistence Layer](#persistence-layer)
7. [Navigation Flow](#navigation-flow)
8. [Performance Considerations](#performance-considerations)
9. [Testing Strategy](#testing-strategy)
10. [Future Improvements](#future-improvements)

## Architecture Overview

The application follows the MVVM (Model-View-ViewModel) architecture pattern with the following key components:

- **Models**: Define the data structure and business logic
- **Views**: SwiftUI views that display the UI
- **ViewModels**: Handle the presentation logic and state management
- **DataStore**: Centralized data management and persistence

## Data Model

### Core Data Structures

#### `MyList`
- Represents a shopping list
- Properties:
  - `id`: Unique identifier (UUID)
  - `name`: Display name of the list
  - `items`: Array of `ItemRow`
  - `isDeleted`: Soft delete flag
  - `createdAt`: Creation timestamp
  - `updatedAt`: Last modification timestamp

#### `ItemRow`
- Represents an item in a shopping list
- Properties:
  - `id`: Unique identifier (UUID)
  - `name`: Item name
  - `isCompleted`: Completion status
  - `createdAt`: Creation timestamp
  - `updatedAt`: Last modification timestamp

## View Hierarchy

```
ContentView (TabView)
├── ListsView (NavigationStack)
│   └── ListDetailView
├── DeletedView
├── StatsView
└── ProfileView
```

## State Management

The app uses a combination of:
- `@State` for view-local state
- `@Binding` for two-way data flow
- `@EnvironmentObject` for app-wide state (DataStore)
- `@Published` for observable objects

## Key Components

### DataStore

Centralized data management class that handles:
- In-memory data storage
- Data persistence using UserDefaults
- CRUD operations for lists and items
- Data filtering and sorting

Key methods:
- `addList(_:)`: Adds a new list
- `updateList(_:)`: Updates an existing list
- `deleteList(_:)`: Soft deletes a list
- `save()`: Persists changes to UserDefaults
- `load()`: Loads data from UserDefaults

### Custom Views

#### SearchBar
Reusable search component used across multiple views for filtering content.

#### ListRowView
Displays a single list item with completion toggle and swipe actions.

## Persistence Layer

Data is persisted using `UserDefaults` with JSON encoding/decoding:
- All lists are serialized to JSON and stored in UserDefaults
- Automatic saving on relevant state changes
- Data is loaded during app launch

## Navigation Flow

1. **Lists Tab**: Main screen showing all active lists
   - Tap on list → Opens ListDetailView
   - Swipe to delete → Moves to Deleted tab
   
2. **Deleted Tab**: Shows soft-deleted lists
   - Swipe to restore or permanently delete
   
3. **Stats Tab**: Displays usage statistics (placeholder)

4. **Profile Tab**: User settings and preferences

## Performance Considerations

1. **List Optimization**:
   - Uses `Identifiable` for efficient diffing
   - Implements lazy loading for large lists
   
2. **State Management**:
   - Minimizes re-renders with proper state management
   - Uses `@StateObject` and `@ObservedObject` appropriately

3. **Memory Management**:
   - Implements proper cleanup in `onDisappear`
   - Uses weak references where appropriate

## Testing Strategy

### Unit Tests
- Data model validation
- DataStore operations
- ViewModel logic

### UI Tests
- Navigation flows
- User interactions
- State changes

## Future Improvements

1. **Data Persistence**
   - Migrate to Core Data or SwiftData for better performance
   - Implement iCloud sync

2. **Offline Support**
   - Handle offline mode with local storage
   - Sync when connection is restored

3. **Accessibility**
   - Add VoiceOver support
   - Improve dynamic type support

4. **Analytics**
   - Track user interactions
   - Monitor app performance

5. **Internationalization**
   - Add support for multiple languages
   - Localize date and number formats

## Dependencies

- SwiftUI
- Combine (for reactive programming)
- Swift Standard Library

## Minimum Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Known Issues

- Large lists may experience performance issues (consider pagination)
- Limited error handling for data persistence

## Troubleshooting

### Common Issues
1. **Data not persisting**
   - Ensure `save()` is called after modifications
   - Check UserDefaults for stored data

2. **UI not updating**
   - Verify `@Published` properties are used correctly
   - Check for missing `@ObservedObject` or `@StateObject`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
