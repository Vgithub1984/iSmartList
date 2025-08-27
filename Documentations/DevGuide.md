# Developer Guide

## Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 16.0+ target
- Swift 5.7+
- Git for version control

### Project Structure
```
MyFirstApp/
├── MyFirstApp/
│   ├── Models/           # Data models
│   ├── ViewModels/       # View models and business logic
│   ├── Views/            # SwiftUI views
│   ├── Utilities/        # Extensions, helpers, and utilities
│   └── Assets.xcassets/  # App assets
├── MyFirstApp.xcodeproj  # Xcode project file
└── Documentations/       # Project documentation
```

## Development Workflow

### Branching Strategy
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/`: Feature branches (e.g., `feature/add-search`)
- `bugfix/`: Bug fix branches
- `release/`: Release preparation branches

### Commit Message Guidelines
- Use present tense ("Add feature" not "Added feature")
- Keep the first line under 50 characters
- Include a blank line between the subject and body
- Reference issues and pull requests

Example:
```
Add swipe to delete functionality

- Implemented swipe actions for list items
- Added confirmation dialog for delete action
- Updated documentation

Fixes #42
```

## Code Style

### SwiftLint
- 4 spaces for indentation
- Max line length: 120 characters
- Use `camelCase` for variables and functions
- Use `PascalCase` for types and protocols

### Documentation
- Document all public interfaces
- Use Markdown for formatting
- Include parameter and return value descriptions

Example:
```swift
/// Creates a new list with the given name.
/// - Parameter name: The name of the list
/// - Returns: The created `MyList` object
func createList(named name: String) -> MyList {
    // Implementation
}
```

## Testing

### Unit Tests
- Test business logic in ViewModels
- Mock dependencies for isolated testing
- Follow the Arrange-Act-Assert pattern

### UI Tests
- Test critical user flows
- Use accessibility identifiers for UI elements
- Keep tests independent and isolated

## Build and Run
1. Clone the repository
2. Open `MyFirstApp.xcodeproj`
3. Select a simulator or device
4. Build and run (⌘R)

## Deployment

### Versioning
- Follow Semantic Versioning (MAJOR.MINOR.PATCH)
- Update version in project settings
- Create a Git tag for releases

### App Store
1. Update version and build numbers
2. Update app metadata in App Store Connect
3. Archive and upload using Xcode
4. Submit for review
