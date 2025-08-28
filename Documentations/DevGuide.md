# Developer Guide

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0+ target
- Swift 5.9+
- Git for version control
- SwiftLint for code style enforcement

### Project Structure
```
MyFirstApp/
├── MyFirstApp/
│   ├── Models/           # Data models and business logic
│   │   └── MyList.swift  # List data model
│   │   └── ListItem.swift # List item model
│   │
│   ├── ViewModels/       # View models and state management
│   │   └── DataStore.swift # Central data management
│   │
│   ├── Views/            # SwiftUI views and view modifiers
│   │   ├── ContentView.swift      # Root view
│   │   ├── ListsView.swift        # Main lists view
│   │   ├── DeletedView.swift      # Deleted items view
│   │   ├── ProfileView.swift      # User profile and settings
│   │   ├── ListDetailView.swift   # List editing view
│   │   └── Components/            # Reusable UI components
│   │       ├── SearchBar.swift
│   │       ├── InfoRow.swift
│   │       └── CustomBackButton.swift
│   │
│   ├── Utilities/        # Extensions and helpers
│   │   └── Extensions/   # Swift extensions
│   │
│   └── Assets.xcassets/  # App assets and resources
│
├── MyFirstApp.xcodeproj  # Xcode project file
└── Documentations/       # Project documentation
   ├── README.md          # Project overview
   ├── TECHNICAL_DOCUMENTATION.md # Technical details
   └── DevGuide.md        # This developer guide
```

### Environment Setup
1. Clone the repository
2. Install dependencies: `brew install swiftlint`
3. Open `MyFirstApp.xcodeproj`
4. Build the project (⌘B)
5. Run tests (⌘U)
6. Run the app (⌘R)

## Development Workflow

### Git Flow
We follow a simplified Git Flow workflow:

#### Main Branches
- `main` - Production-ready code (protected)
  - Always deployable
  - Only updated via pull requests
  - Tagged with version numbers
- `develop` - Integration branch for features
  - Main development branch
  - Should always be in a working state
  - Automatically tested on push

#### Supporting Branches
1. **Feature Branches** (`feature/*`)
   - Branch from: `develop`
   - Merge back to: `develop`
   - Naming: `feature/description` (e.g., `feature/dark-mode`)

2. **Bugfix Branches** (`bugfix/*`)
   - Branch from: `develop` or `main` (for hotfixes)
   - Merge back to: `develop` or `main`
   - Naming: `bugfix/issue-#` or `bugfix/description`

3. **Release Branches** (`release/*`)
   - Branch from: `develop`
   - Merge to: `develop` and `main`
   - Naming: `release/v1.2.0`

### Pull Request Process
1. Create a feature/bugfix branch
2. Make your changes with clear, atomic commits
3. Push your branch and create a PR
4. Request review from at least one team member
5. Address review feedback
6. Once approved, squash and merge
7. Delete the feature branch

### Commit Message Guidelines

#### Format
```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

#### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or modifying tests
- `chore`: Changes to build process or auxiliary tools

#### Examples
```
feat(list): add swipe to delete functionality

- Implemented swipe actions for list items
- Added confirmation dialog for delete action
- Updated documentation and tests

Fixes #42
```

```
fix(profile): resolve crash in dark mode

- Fixed force unwrap in ProfileView
- Added null checks for theme colors
- Updated snapshot tests

Closes #123
```

#### Rules
- Use present tense ("add" not "added")
- No period at the end of the subject line
- Keep the subject line under 50 characters
- Wrap the body at 72 characters
- Use the body to explain what and why vs. how

## Code Style

### SwiftLint
We use SwiftLint to enforce code style. Key rules:

#### Formatting
- 4 spaces for indentation (no tabs)
- Max line length: 120 characters
- Trailing newline at end of file
- No trailing whitespace
- One blank line between methods
- Two blank lines between sections

#### Naming
- Types: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `camelCase` (use `let` for immutability)
- Private properties: `_camelCase`
- Enums: `PascalCase` with cases in `lowerCamelCase`
- Protocols: `PascalCase` + `-able`/`-ible`/`-ing`

#### Best Practices
- Use `let` by default, `var` only when necessary
- Prefer value types (structs, enums) over classes
- Use `guard` for early returns
- Avoid force unwrapping (`!`)
- Use `if let` or `guard let` for optionals
- Keep functions small and focused
- Maximum nesting level: 3
- Maximum file length: 500 lines

#### Documentation
- Document all public interfaces
- Use Xcode's documentation syntax (`///`)
- Include parameter and return value descriptions
- Document all `@Published` properties
- Add `// MARK: -` for code organization

### Documentation Standards

#### Code Documentation
```swift
/// Creates a new list with the given name and optional items.
/// - Parameters:
///   - name: The name of the list. Must be non-empty and unique.
///   - items: Optional array of `ListItem` to initialize the list with.
///   - isPinned: Whether the list should be pinned to the top. Defaults to `false`.
/// - Returns: A new `MyList` instance.
/// - Throws: `ListError.invalidName` if name is empty or contains only whitespace.
/// - Note: The list will be created with the current date as creation date.
/// - Warning: This operation will trigger a UI update.
func createList(
    named name: String,
    items: [ListItem] = [],
    isPinned: Bool = false
) throws -> MyList {
    // Implementation
}
```

#### Documentation Rules
1. **Public Interfaces**
   - Document all public types, methods, and properties
   - Include parameter descriptions, return values, and possible errors
   - Document thread safety requirements

2. **Complex Logic**
   - Add comments explaining non-obvious code
   - Include references to algorithms or external documentation
   - Document performance characteristics if non-trivial

3. **Markup**
   - Use `MARK:` to organize code into logical sections
   - Use `TODO:`, `FIXME:`, and `NOTE:` where appropriate
   - Document known issues and workarounds

## Testing Strategy

### Unit Tests
- **Location**: `MyFirstAppTests/`
- **Coverage Goal**: 80%+
- **Focus Areas**:
  - Business logic in ViewModels
  - Data transformations
  - State management
  - Model validation

#### Best Practices
- Follow Arrange-Act-Assert pattern
- Use descriptive test names (`testMethodName_StateUnderTest_ExpectedBehavior`)
- Test edge cases and error conditions
- Mock all external dependencies
- Keep tests independent and fast

### UI Tests
- **Location**: `MyFirstAppUITests/`
- **Focus Areas**:
  - Critical user journeys
  - Complex interactions
  - State persistence
  - Accessibility

#### Best Practices
- Use accessibility identifiers for UI elements
- Keep tests independent and isolated
- Use `XCUIElement` queries effectively
- Handle system dialogs and permissions
- Run in both light and dark mode

### Performance Tests
- **Location**: `MyFirstAppPerformanceTests/`
- **Focus Areas**:
  - List rendering performance
  - Data loading times
  - Memory usage
  - App launch time

### Snapshot Tests
- **Location**: `MyFirstAppSnapshotTests/`
- **Focus Areas**:
  - UI components in different states
  - Different device sizes
  - Localization
  - Accessibility settings

### Test Automation
- Run unit tests on every commit
- Run UI tests on pull requests
- Generate code coverage reports
- Enforce minimum test coverage

## Build and Run

### Development
1. Clone the repository: `git clone <repo-url>`
2. Install dependencies: `brew bundle`
3. Open workspace: `open MyFirstApp.xcodeproj`
4. Select target device/simulator
5. Build and run: `⌘R`

### Build Configurations
- **Debug**: Development build with debug symbols
- **Release**: Optimized build for distribution
- **Staging**: Release build with staging environment

### Fastlane
We use Fastlane for automation:

```bash
# Run tests
fastlane test

# Build for TestFlight
fastlane beta

# Release to App Store
fastlane release

# Update screenshots
fastlane snapshot
```

## Deployment

### Versioning
We follow [Semantic Versioning 2.0.0](https://semver.org/):
- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible functionality
- **PATCH**: Backwards-compatible bug fixes

### Release Process
1. Create release branch: `release/vX.Y.Z`
2. Update version in:
   - Xcode project settings
   - CHANGELOG.md
   - Documentation
3. Run tests and verify all checks pass
4. Merge to `main` and tag the release
5. Create GitHub release with release notes
6. Deploy to TestFlight
7. After successful testing, submit to App Store Review

### App Store Submission
1. Update marketing materials in App Store Connect
2. Add new screenshots for all device sizes
3. Prepare release notes
4. Submit for review
5. Monitor review status
6. Release to the App Store (manual or automatic)

### Post-Release
1. Merge `main` back to `develop`
2. Update documentation
3. Archive release notes
4. Monitor crash reports and user feedback
