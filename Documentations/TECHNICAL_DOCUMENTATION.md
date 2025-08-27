# Technical Documentation

## Architecture

iSmartList follows the MVVM (Model-View-ViewModel) architecture pattern with the following components:

### Models
- `MyList`: Represents a list with properties for name, creation date, and items
- `ListItem`: Represents an individual item within a list
- `DataStore`: Manages the app's data and business logic

### Views
- `ContentView`: Main container with tab-based navigation
- `ListsView`: Displays active lists
- `DeletedView`: Shows deleted lists that can be restored
- `ProfileView`: User profile and statistics
- `ListDetailView`: Detailed view of a specific list

### ViewModels
- `DataStore`: Acts as the ViewModel, managing the app's state and business logic

## Key Features Implementation

### List Management
- Lists are stored in `DataStore` as an array of `MyList` objects
- Each list has a unique ID and can be marked as deleted (soft delete)
- Lists can be restored from the Deleted tab

### State Management
- `@State` and `@Binding` for local state management
- `@EnvironmentObject` for app-wide state (DataStore)
- `@Published` properties in DataStore for reactive updates

### UI Components
- Custom `SearchBar` for list filtering
- Custom alert views with focus management
- Swipe actions for list items
- Empty state views with helpful messages

## Recent Updates

### Version 1.1.1 (August 27, 2025)
- **Documentation**: Updated documentation and version consistency
- **UI Improvements**: Enhanced navigation styling and version display
- **Code Quality**: Refactored view components for better maintainability

### Version 1.1.0 (August 26, 2025)
- **Enhanced List Creation**: Auto-focus on text field with improved UI
- **Improved Empty States**: Added gesture hints and better visual feedback
- **Performance**: Optimized list rendering and state updates
- **Accessibility**: Improved VoiceOver support and dynamic type

## Dependencies
- SwiftUI for UI
- Combine for reactive programming
- Core Data for local persistence

## Known Issues
- None at this time

## Future Improvements
- iCloud sync
- List sharing
- Custom list icons
- Tags and categories
