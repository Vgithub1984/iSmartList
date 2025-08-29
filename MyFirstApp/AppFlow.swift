//
//  AppFlow.swift
//  MyFirstApp
//
//  Documentation of user flows and component interactions.
//
//  This file provides a high-level overview of the application's architecture,
//  user flows, and how different components interact with each other.
//  It serves as living documentation for the codebase.
//

import SwiftUI

// MARK: - Application Overview
/*
 iSmartList is a privacy-focused shopping list application emphasizing on-device data storage and user-centric design. Key features include:
 - Manage user identity and profile information with user name persistence
 - Create and manage multiple shopping lists with robust item handling
 - Add items via text input or voice dictation with advanced autocorrect and duplicate prevention
 - Mark items as completed or pending with fine-grained controls
 - View rich statistics, analytics, and usage insights for better shopping management
 - On-device privacy: No data leaves the device ensuring user data confidentiality
 - Comprehensive profile management including storage and privacy preferences

 The app follows the MVVM (Model-View-ViewModel) architecture pattern with the following key components:
 - Views: Present UI and handle user interactions
 - ViewModels: Manage data and business logic with granular observable state
 - Models: Define data structures and business rules
 */

// MARK: - Main Application Flow
/*
 1. App Launch:
    - MyFirstAppApp initializes the DataStore as an environment object
    - ContentView is loaded as the root view
    - DataStore loads persisted user profile and shopping list data from secure local storage

 2. Main Tabs Navigation:
    - ContentView provides a TabView with 4 main sections:
      a. Lists (ListsView) - Active shopping lists management
      b. Deleted (DeletedView) - Shows soft-deleted lists and items for restore or permanent delete
      c. Stats (StatsView) - Advanced statistics and analytics about usage and completion trends
      d. Profile (ProfileView) - User profile, account, storage & privacy settings, about and contact info
*/

// MARK: - Core Components

/*
 1. Data Management:
    - DataStore: Central data repository that manages all lists, items, and user profile data
      - Persists data securely on-device with encryption
      - Provides CRUD operations for lists and items with validation and duplicates prevention
      - Exposes computed published properties for:
         - Active lists (non-deleted)
         - Lists with zero items
         - Completed lists/items
         - Deleted/archived lists and items
      - Manages userName persistence and profile data
      - Supports granular updates and notifications to views

 2. Main Views:
    - ContentView: Root view containing the main tab navigation and environment injection
    - ListsView: Displays all active shopping lists with add/delete/rename functionality
    - ListDetailView: Shows items in a specific list with add/remove/edit and completion toggles
    - DeletedView: Shows soft-deleted lists and items with options to restore or permanently delete
    - StatsView: Displays rich usage statistics, completion rates, item trends, and history charts
    - ProfileView: User profile and settings with sections for:
      - Account management (user name and identity)
      - Storage and privacy preferences emphasizing on-device data and manual data removal
      - App settings customization
      - About the app and contact support information

 3. Supporting Components:
    - SpeechRecognizer: Handles voice input and speech-to-text conversion
      - Only adds list items after final transcript is confirmed (i.e., after pauses)
      - Implements robust autocorrect, punctuation, and duplicate prevention on voice input
    - ToolBarColor: Provides consistent toolbar theming and styling across views
    - Custom UI Components:
      - SearchBar: Search functionality for filtering lists and items
      - InfoRow: Reusable information display rows with icon and text
      - StorageItemView: Visual components representing storage usage and data stats
*/

// MARK: - User Flows

/*
 1. Creating a New List:
    - User taps "+" button in ListsView
    - Presents a dialog to enter the list name with validation
    - Creates a new MyList object and adds it to DataStore
    - Automatically navigates to the newly created list's detail view

 2. Adding Items to a List:
    Manual Entry:
    - User types item text into the input field and presses return
    - ListDetailView.addItem() is called with input string
    - DataStore validates, autocorrects, and prevents duplicate entries
    - Item is added to the list and UI updates accordingly

    Voice Entry:
    - User taps microphone button to start speech recognition
    - SpeechRecognizer begins recording and transcribing in real time
    - Items are only added after the user pauses and the transcript is finalized (handleFinalTranscript())
    - Robust autocorrect and duplicate prevention applied to voice input
    - Items added with "(v)" suffix to indicate voice origin

 3. Completing/Deleting Items and Lists:
    - Tapping an item's checkbox toggles its completion state
    - Swipe to delete removes item immediately from UI and DataStore
    - Deleted lists and items move to DeletedView for soft-deletion
    - Users can restore or permanently delete items and lists from DeletedView
    - Deletions and restorations update DataStore accordingly

 4. Viewing Statistics:
    - StatsView presents comprehensive analytics including completion rates, item counts, historical trends, and usage insights
    - Data visualizations pull from DataStore's aggregated list and item history

 5. Managing Profile and Privacy:
    - ProfileView allows editing user name and account information
    - Storage and privacy section details on-device data management
    - User can clear app data manually to ensure privacy
    - Settings for app customization and access to about/contact information
*/

// MARK: - Component Interactions

/*
 1. Data Flow:
    - DataStore is the single source of truth for the entire app state
    - Views observe changes to DataStore via @EnvironmentObject and receive finely filtered published collections
    - All creations, updates, and deletions of lists and items go through DataStore methods enforcing validation and business rules

 2. Speech Recognition Flow:
    - User taps microphone -> SpeechRecognizer.start() begins recording
    - Audio input feeds into Speech framework producing incremental transcripts
    - UI updates show live transcript but do not create items yet
    - When speech pauses, handleFinalTranscript() processes input to add items in bulk with autocorrect and duplicate checks

 3. Navigation:
    - Tab-based navigation for main app sections (Lists, Deleted, Stats, Profile)
    - NavigationStack used within sections for drill-down views like ListDetailView
    - Modal sheets and alerts used for creating, editing, and confirming destructive actions
*/

// MARK: - Key Design Patterns

/*
 1. ObservableObject:
    - DataStore and ViewModels use granular @Published properties for state updates
    - Views subscribe to these changes and refresh UI declaratively

 2. EnvironmentObject:
    - DataStore injected at root level to enable easy access across all views

 3. MVVM:
    - Views are declarative and passive, focusing on UI presentation
    - ViewModels contain business logic, data transformation, and state management
    - Models represent immutable data structures and validation rules

 4. Dependency Injection:
    - Dependencies injected via initializers and environment to improve modularity and testability

 5. Preview Macros:
    - Use of advanced SwiftUI preview macros for faster UI development and testing
*/

// MARK: - Important Notes

/*
 - All user data is stored exclusively on-device ensuring maximum privacy
 - No cloud sync or external data transmission occurs by default (future iCloud sync planned)
 - Async operations and error handling implemented to manage persistence and speech recognition failures gracefully
 - App strictly follows SwiftUI best practices and Swift language guidelines for maintainability and performance
*/

// MARK: - Future Considerations

/*
 - Add iCloud sync for seamless cross-device data synchronization
 - Implement sharing of lists with other users or via export/import
 - Extend statistics with more advanced insights and customizable reports
 - Introduce support for categories, tags, and filtering of items and lists
 - Improve dark mode theming and accessibility support for all users
 - Continuous privacy improvements and data protection enhancements
*/

// MARK: - File Structure Reference

/*
 MyFirstApp/
 ├── AppFlow.swift (This file)
 ├── ContentView.swift             # Main tab navigation
 ├── ListsView.swift               # List of shopping lists
 ├── ListDetailView.swift          # Items in a specific list
 ├── DeletedView.swift             # Deleted/archived lists and items
 ├── StatsView.swift               # Statistics and analytics with rich charts
 ├── ProfileView.swift             # User profile, storage/privacy, settings, about, contact
 ├── SpeechRecognizer.swift        # Voice input handling with finalized transcript item addition
 ├── ToolBarColor.swift            # Theming and toolbar color consistency
 ├── ViewModels/
 │   └── DataStore.swift           # Central data management and user profile
 └── Views/
     ├── CustomBackButton.swift    # Custom navigation back button
     ├── InfoRow.swift             # Reusable list row with icon and text
     ├── SearchBar.swift           # Search bar for filtering lists and items
     └── StorageItemView.swift     # Visual storage usage components
 */
