//
//  ContentView.swift
//  MyFirstApp
//
//  Created by Varun Patel on 8/24/25.
//
//  This file contains the main application view that manages the tab-based navigation
//  and overall app structure. It coordinates between different views and handles
//  the creation of new lists.
//
//  Model and DataStore are defined in:
//  - Models/MyList.swift
//  - ViewModels/DataStore.swift

import SwiftUI
import SwiftData

// MARK: - BlurView

/// A wrapper view that provides a blur effect using UIKit's UIVisualEffectView.
/// This is used for creating frosted glass or blur overlay effects in the UI.
///
/// This view bridges UIKit's blur effect functionality to SwiftUI, allowing for
/// sophisticated visual effects that aren't natively available in SwiftUI.
///
/// ## Example
/// ```swift
/// BlurView(style: .systemUltraThinMaterial)
///     .frame(width: 200, height: 200)
/// ```
struct BlurView: UIViewRepresentable {
    // MARK: - Properties
    
    /// The style of the blur effect to apply.
    /// - Note: Defaults to `.systemMaterial` which provides a standard frosted glass effect.
    /// - SeeAlso: `UIBlurEffect.Style` for available blur styles
    var style: UIBlurEffect.Style = .systemMaterial
    
    // MARK: - UIViewRepresentable Methods
    
    /// Creates and configures the underlying UIKit view.
    /// - Returns: A configured `UIVisualEffectView` with the specified blur effect.
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    /// Updates the state of the specified view with new information from SwiftUI.
    /// - Parameters:
    ///   - uiView: The view to update.
    ///   - context: The context in which the update occurs.
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// MARK: - ContentView

/// The root view of the application that manages the main tab-based navigation.
///
/// This view serves as the main container for the entire application, coordinating
/// between different app sections and managing the creation of new lists. It's responsible
/// for the overall app structure and navigation flow.
///
/// ## Key Responsibilities
/// - Manages tab-based navigation between app sections (Lists, Deleted, Stats, Profile)
/// - Handles creation of new shopping lists via a floating action button
/// - Coordinates with `DataStore` for data management
/// - Manages global UI state like selected tab and list detail visibility
///
/// ## State Management
/// - Uses `@State` for view-specific state (selectedTab, isShowingListDetail, etc.)
/// - Uses `@EnvironmentObject` to access the shared `DataStore`
/// - Manages focus state for text fields
///
/// ## Lifecycle
/// - Initializes with default tab selection (Lists tab)
/// - Updates UI state when tabs change
/// - Handles view transitions and animations
///
/// ## Accessibility
/// - Supports Dynamic Type for text scaling
/// - Includes accessibility labels and hints for interactive elements
/// - Maintains proper contrast ratios for text and controls
///
/// - Note: This view is typically the root view of the app's view hierarchy.
struct ContentView: View {
    // MARK: - Environment
    
    /// The shared data store for managing all app data.
    /// Injected as an environment object for access throughout the view hierarchy.
    @EnvironmentObject private var dataStore: DataStore
    
    // MARK: - State
    
    /// The currently selected tab in the tab view.
    ///
    /// - 0: Lists - Displays active shopping lists
    /// - 1: Deleted - Shows soft-deleted lists that can be restored
    /// - 2: Stats - Displays usage statistics and analytics
    /// - 3: Profile - Shows user profile and settings
    @State private var selectedTab: Int = 0
    
    /// Controls the visibility of the floating action button when in list detail view.
    ///
    /// - Note: The FAB is automatically hidden when viewing list details to avoid UI clutter.
    ///   This provides a cleaner interface when users are focused on a specific list.
    @State private var isShowingListDetail = false
    
    /// Controls the visibility of the new list creation sheet.
    ///
    /// - When `true`, presents a modal sheet for creating a new list.
    /// - The sheet includes a form with validation and keyboard management.
    @State private var showingNewListDialog = false
    
    /// The name of the new list being created.
    ///
    /// - Bound to the text field in the new list creation sheet.
    /// - Validated to ensure non-empty before allowing list creation.
    @State private var newListName = ""
    
    /// Controls the visibility of the delete all confirmation dialog.
    ///
    /// - When `true`, shows a confirmation dialog before deleting all lists.
    /// - Uses the system's standard alert presentation style.
    @State private var showingListsDeleteAllDialog = false
    
    /// Controls the focus state of the new list name text field.
    ///
    /// - Used to automatically focus the text field when the new list sheet appears.
    /// - Improves user experience by showing the keyboard immediately.
    @FocusState private var isTextFieldFocused: Bool

    // MARK: - Body
    
    // MARK: - Subviews
    
    /// A floating action button that allows users to create new shopping lists.
    ///
    /// This button appears in the bottom-right corner of the screen and is only visible
    /// when the user is on the Lists tab and not viewing list details. Tapping it presents
    /// a sheet for creating a new list.
    ///
    /// ## Visual Design
    /// - Uses a circular white background with 80% opacity
    /// - Features a black plus icon in the center
    /// - Includes a subtle shadow for depth
    /// - Has a smooth scale transition when appearing/disappearing
    ///
    /// - Note: The button is positioned to avoid overlapping with the tab bar
    ///   and includes extra padding for comfortable tapping.
    private var addButton: some View {
        Button(action: {
            // Reset the new list name and show the creation dialog
            newListName = ""
            showingNewListDialog = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(.black)
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Circle()) // Ensure the entire circular area is tappable
        .frame(width: 56, height: 56)
        .padding(.trailing, 30) // Position from the right edge
        .padding(.bottom, 70)   // Position from the bottom (accounts for tab bar)
        .transition(.scale)     // Smooth scale animation
        .zIndex(1)              // Ensure it's above the tab bar
        .accessibility(label: Text("Create new list"))
        .accessibility(hint: Text("Opens a dialog to create a new shopping list"))
    }

    /// The Lists tab view showing all active shopping lists.
    /// - Note: Includes the main list interface and delete all functionality.
    private var listsTab: some View {
        NavigationStack {
            ListsView(isShowingListDetail: $isShowingListDetail)
                .onChange(of: selectedTab) {
                    // Reset list detail state when switching tabs
                    isShowingListDetail = false
                }
                // Hide tab bar when viewing list details for a cleaner interface
                .toolbar(selectedTab == 0 && isShowingListDetail ? .hidden : .visible, for: .tabBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Only show delete all button if there are active lists
                        if !dataStore.lists.filter({ !$0.isDeleted }).isEmpty {
                            Button(role: .destructive) {
                                showingListsDeleteAllDialog = true
                            } label: {
                                Text("Delete All")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                // Confirmation dialog for delete all action
                .confirmationDialog("Delete All Lists?",
                                 isPresented: $showingListsDeleteAllDialog,
                                 titleVisibility: .visible) {
                    Button("Delete All", role: .destructive) {
                        deleteAllLists()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to move all your lists to Deleted? This can be undone from the Deleted tab.")
                }
        }
    }
    
    /// Moves all active lists to the deleted state.
    /// - Note: This performs a soft delete, allowing lists to be restored later.
    private func deleteAllLists() {
        for var list in dataStore.lists {
            list.isDeleted = true
            list.updatedAt = Date()
            dataStore.updateList(list)
        }
    }
    
    /// The Deleted tab view showing all soft-deleted lists.
    /// - Note: Allows users to restore or permanently delete lists.
    private var deletedTab: some View {
        NavigationStack {
            DeletedView()
        }
    }
    
    /// The Stats tab view showing app usage statistics and list analytics.
    private var statsTab: some View {
        NavigationStack {
            StatsView()
        }
        .tabItem { tabLabel(title: "Stats", systemImage: "chart.bar", tag: 2) }
        .tag(2)
    }
    
    /// The Profile tab view showing user profile and settings.
    private var profileTab: some View {
        NavigationStack {
            ProfileView()
        }
    }
    
    /// Creates a styled tab bar item with consistent appearance.
    /// - Parameters:
    ///   - title: The title to display for the tab.
    ///   - systemImage: The SF Symbol to use for the tab icon.
    ///   - tag: The unique identifier for this tab.
    /// - Returns: A view representing the styled tab item.
    private func tabLabel(title: String, systemImage: String, tag: Int) -> some View {
        Label {
            Text(title)
                .foregroundStyle(selectedTab == tag ? .primary : .secondary)
                .fontWeight(selectedTab == tag ? .bold : .regular)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(selectedTab == tag ? .primary : .secondary)
                .fontWeight(selectedTab == tag ? .bold : .regular)
        }
    }
    
    /// The sheet for creating a new list.
    /// - Note: Includes form validation and keyboard management.
    private var newListSheet: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter List Name", text: $newListName, onCommit: createNewList)
                        .focused($isTextFieldFocused)
                        .onAppear {
                            // Set focus immediately when the view appears
                            isTextFieldFocused = true
                        }
                        .submitLabel(.done)
                } header: {
                    Text("")
                } footer: {
                    Text("Enter a name for your new list")
                }
            }
            .onAppear {
                // Ensure focus is set when the sheet appears
                DispatchQueue.main.async {
                    isTextFieldFocused = true
                }
            }
            .onDisappear {
                // Reset the text field when the sheet is dismissed
                newListName = ""
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingNewListDialog = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createNewList()
                        showingNewListDialog = false
                    }
                    .disabled(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        // Handle swipe-to-dismiss with state cleanup
        .onChange(of: showingNewListDialog) { isPresented in
            if !isPresented {
                // Reset the text field when dismissed
                newListName = ""
            }
        }
    }
    
    /// Creates a new list with the current name and adds it to the data store.
    /// - Note: Trims whitespace and newlines from the list name.
    private func createNewList() {
        let trimmedName = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            let newList = MyList(name: trimmedName)
            dataStore.addList(newList)
            newListName = ""
        }
    }
    
    // MARK: - Main View
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main tab view container
            TabView(selection: $selectedTab) {
                // Lists tab - shows all active shopping lists
                listsTab
                    .tabItem { tabLabel(title: "Lists", systemImage: "list.bullet", tag: 0) }
                    .tag(0)
                    .badge(dataStore.lists.filter { !$0.isDeleted }.count)
                
                // Deleted tab - shows soft-deleted lists that can be restored
                deletedTab
                    .tabItem { tabLabel(title: "Deleted", systemImage: "trash", tag: 1) }
                    .tag(1)
                    .badge(dataStore.lists.filter { $0.isDeleted }.count)
                
                // Stats tab - shows app usage statistics
                statsTab
                
                // Profile tab - user profile and settings
                profileTab
                    .tabItem { tabLabel(title: "Profile", systemImage: "person.crop.circle", tag: 3) }
                    .tag(3)
            }
            
            // Floating action button and search bar for creating new lists and filtering
            // Only show in the Lists tab and when not viewing list details
            if selectedTab == 0 && !isShowingListDetail {
                addButton
            }
        }
        // Present the new list sheet when requested
        .sheet(isPresented: $showingNewListDialog) {
            newListSheet
        }
        // Ensure keyboard doesn't affect the layout
        .ignoresSafeArea(.keyboard)
    }
}


// MARK: - Preview

#Preview {
    // Set up a preview environment with sample data
    let dataStore = DataStore()
    
    // Create sample lists for preview
    let groceryList = MyList(
        name: "Grocery List",
        items: [
            ItemRow(name: "Milk", isCompleted: false, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Bread", isCompleted: false, createdAt: Date(), updatedAt: Date())
        ],
        isDeleted: false,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    let workList = MyList(
        name: "Work Tasks",
        items: [
            ItemRow(name: "Finish report", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Team meeting", isCompleted: false, createdAt: Date(), updatedAt: Date())
        ],
        isDeleted: false,
        createdAt: Date().addingTimeInterval(-86400), // Yesterday
        updatedAt: Date()
    )
    
    let deletedList = MyList(
        name: "Old List",
        items: [],
        isDeleted: true,
        createdAt: Date().addingTimeInterval(-2592000), // 30 days ago
        updatedAt: Date().addingTimeInterval(-2592000)
    )
    
    dataStore.lists = [groceryList, workList, deletedList]
    
    // Return the preview with the populated data store
    return ContentView()
        .environmentObject(dataStore)
}
