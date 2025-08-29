# MyFirstApp - Technical Documentation

## Version History

### v1.2.0 (2025-08-29)
- **Version**: 1.2.0
- **Build**: 2025.08.29.1106
- **Changes**:
  - Enhanced Deleted tab: improved empty states, batch delete, mutually exclusive status
  - Stats tab: more detailed statistics and progress tracking
  - About/Profile: now display latest version/build/timestamp
  - General UI/UX improvements and bug fixes

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

