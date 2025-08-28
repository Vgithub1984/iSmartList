//
//  DeletedView.swift
//  MyFirstApp
//
//  This file implements the view for managing soft-deleted shopping lists.
//  It provides functionality to restore or permanently delete lists that have been moved to the trash.
//
//  Key Features:
//  - Displays all soft-deleted shopping lists in a scrollable list
//  - Shows list details including name, deletion date, and completion status
//  - Allows restoring lists back to the main list view
//  - Supports permanent deletion of individual lists or all lists at once
//  - Integrates with DataStore for data persistence
//  - Includes search functionality (currently disabled but can be enabled)

import SwiftUI

/// Displays a list of soft-deleted shopping lists with options to restore or permanently delete them.
///
/// This view provides a recovery interface for lists that have been soft-deleted, allowing users to:
/// - View all deleted lists with their current state
/// - Restore lists back to the main list view
/// - Permanently delete individual lists or all lists at once
/// - Search through deleted lists (when enabled)
///
/// - Note: Integrates with `DataStore` for managing the underlying data and persistence.
struct DeletedView: View {
    // MARK: - Environment
    
    /// The shared data store containing all lists, including deleted ones.
    /// Automatically updates the view when the data changes.
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State
    
    /// Controls the visibility of the delete confirmation alert.
    @State private var showingDeleteAlert = false
    
    /// The list currently being considered for permanent deletion.
    @State private var listToDelete: MyList?
    
    /// Controls the visibility of the delete all confirmation dialog.
    @State private var showingDeleteAllDialog = false
    
    /// The list currently being considered for restoration.
    @State private var listToRestore: MyList? = nil
    
    /// The current search text for filtering deleted lists.
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    
    /// The list of deleted lists, filtered by search text and sorted by update time (newest first).
    private var filteredDeletedLists: [MyList] {
        let filtered: [MyList]
        if searchText.isEmpty {
            filtered = dataStore.deletedLists
        } else {
            filtered = dataStore.deletedLists.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) 
            }
        }
        return filtered.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    // MARK: - Helper Methods
    
    /// Extracts the items from a given list.
    /// - Parameter list: The list to get items from.
    /// - Returns: An array of `ItemRow` objects representing the list's items.
    private func getItems(from list: MyList) -> [ItemRow] {
        return list.items
    }

    /// Returns a mutually exclusive status string for the list based on items completion state:
    /// - 'Zero Item' if no items
    /// - 'Completed' if all items completed (>0 items)
    /// - 'Active' if some items incomplete (>0 items)
    /// - Parameter list: The list to evaluate
    /// - Returns: A status string suitable for display
    private func listStatus(for list: MyList) -> String {
        let items = list.items
        let totalCount = items.count
        let completedCount = items.filter { $0.isCompleted }.count
        
        if totalCount == 0 {
            return "Zero Item"
        } else if completedCount == totalCount {
            return "Completed"
        } else {
            return "Active"
        }
    }

    /// Creates a view for a single deleted list row with appropriate actions.
    /// - Parameter list: The list to display in the row.
    /// - Returns: A view representing the deleted list row with actions.
    private func buildDeletedListRow(for list: MyList) -> some View {
        let items = getItems(from: list)
        let totalCount = items.count
        let purchasedCount = items.filter { $0.isCompleted }.count
        let status = listStatus(for: list)

        return DeletedListRow(
            list: list,
            items: items,
            totalCount: totalCount,
            purchasedCount: purchasedCount,
            statusText: status,
            onDelete: {
                // Set up for deletion confirmation
                listToDelete = list
                showingDeleteAlert = true
            },
            onRestore: {
                // Set up for restoration confirmation
                listToRestore = list
            }
        )
    }
    
    // MARK: - Body
    
    // MARK: - Subviews
    
    /// The view displayed when there are no deleted lists.
    private var emptyStateView: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            
            VStack(spacing: 20) {
                // Trash icon for empty state
                Image(systemName: "trash")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                
                Text("No Deleted Lists")
                    .font(.headline)
                
                Text("Deleted lists will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Search functionality (currently disabled but can be enabled)
                /*SearchBar(text: $searchText)
                    .padding(.horizontal)
                 */
                
                // Show empty state if no deleted lists exist
                if filteredDeletedLists.isEmpty {
                    emptyStateView
                } else {
                    // Display each deleted list with restore/delete options
                    ForEach(filteredDeletedLists) { list in
                        buildDeletedListRow(for: list)
                    }
                }
            }
            .navigationTitle("Trash")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete Permanently", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let list = listToDelete {
                        withAnimation {
                            // Permanently delete the list
                            dataStore.permanentDelete(list)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to permanently delete this list? This action cannot be undone.")
            }
            .alert("Restore List?", 
                   isPresented: Binding<Bool>(
                    get: { listToRestore != nil }, 
                    set: { if !$0 { listToRestore = nil } }
                   )
            ) {
                Button("Restore", role: .none) {
                    if let list = listToRestore {
                        withAnimation {
                            dataStore.restoreList(list)
                        }
                        listToRestore = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    listToRestore = nil
                }
            } message: {
                if let list = listToRestore {
                    Text("Are you sure you want to restore \"\(list.name)\" back to Lists section?")
                }
            }
            .confirmationDialog(
                "Delete All Deleted Lists?", 
                isPresented: $showingDeleteAllDialog, 
                titleVisibility: .visible
            ) {
                Button("Delete All", role: .destructive) {
                    // Permanently delete all deleted lists
                    let deletedLists = dataStore.deletedLists
                    for list in deletedLists {
                        dataStore.permanentDelete(list)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to permanently delete all deleted lists? This action cannot be undone.")
            }
            .toolbar {
                // Show Delete All button only when there are deleted lists
                if !filteredDeletedLists.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            showingDeleteAllDialog = true
                        } label: {
                            Text("Delete All")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarBackground(Color.toolbarColor(for: colorScheme), for: .navigationBar)
    }
}

// MARK: - DeletedListRow

/// A view representing a single row in the deleted lists view.
///
/// Displays list information and provides actions for restoration or permanent deletion.
private struct DeletedListRow: View {
    // MARK: - Properties
    
    /// The list being displayed in this row.
    let list: MyList
    
    /// The items contained in the list.
    let items: [ItemRow]
    
    /// The total number of items in the list.
    let totalCount: Int
    
    /// The number of completed items in the list.
    let purchasedCount: Int
    
    /// The mutually exclusive status text for the list ("Zero Item", "Completed", "Active").
    let statusText: String
    
    /// The action to perform when the delete button is tapped.
    let onDelete: () -> Void
    
    /// The action to perform when the restore button is tapped.
    let onRestore: () -> Void

    // MARK: - Body
    
    var body: some View {
        Group {
            HStack(alignment: .center) {
                // List name and deletion date
                VStack(alignment: .leading, spacing: 6) {
                    Text(list.name)
                        .font(.headline)
                        .strikethrough()
                    Text("Deleted \(list.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Completion status indicator with mutually exclusive status
                HStack(spacing: 6) {
                    if statusText == "Zero Item" {
                        Text("Zero Item")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if statusText == "Completed" {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else if statusText == "Active" {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.accentColor)
                        Text("Active")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
                
                // Action menu
                Menu {
                    // Delete permanently option
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete Permanently", systemImage: "trash")
                    }
                    
                    // Restore option
                    Button(action: onRestore) {
                        Label("Restore", systemImage: "arrow.uturn.backward")
                    }
                } label: {
                    // Menu button
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 6)
        }
    }
}

/* MARK: - Previews

#Preview("With Deleted Lists") -> some View in {
    // Set up a data store with sample deleted lists
    let dataStore = DataStore()
    
    // Create a sample deleted list
    let deletedList = MyList(
        name: "Old Grocery List",
        items: [
            ItemRow(name: "Milk", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Bread", isCompleted: false, createdAt: Date(), updatedAt: Date())
        ],
        isDeleted: true,
        createdAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
        updatedAt: Date().addingTimeInterval(-86400 * 2)  // 2 days ago
    )
    
    // Add the list to the data store
    dataStore.lists = [deletedList]
    
    // Return the preview with navigation
    NavigationStack {
        DeletedView()
    }
    .environmentObject(dataStore)
}

#Preview("Empty State") -> some View in {
    // Set up an empty data store
    let dataStore = DataStore()
    dataStore.lists = []
    
    NavigationStack {
        DeletedView()
    }
    .environmentObject(dataStore)
}

#Preview("Multiple Deleted Lists") -> some View in {
    // Set up a data store with multiple deleted lists
    let dataStore = DataStore()
    
    // Create sample deleted lists with mutually exclusive statuses
    let deletedLists = [
        MyList(
            name: "Old Grocery List",
            items: [
                ItemRow(name: "Milk", isCompleted: true, createdAt: Date(), updatedAt: Date()),
                ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date())
            ],
            isDeleted: true,
            createdAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 2)  // 2 days ago
        ),
        MyList(
            name: "Work Tasks",
            items: [
                ItemRow(name: "Finish report", isCompleted: false, createdAt: Date(), updatedAt: Date())
            ],
            isDeleted: true,
            createdAt: Date().addingTimeInterval(-86400 * 3), // 3 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 1)  // 1 day ago
        ),
        MyList(
            name: "Empty List",
            items: [],
            isDeleted: true,
            createdAt: Date().addingTimeInterval(-86400 * 5),
            updatedAt: Date().addingTimeInterval(-86400 * 4)
        )
    ]
    
    // Add the lists to the data store
    dataStore.lists = deletedLists
    
    NavigationStack {
        DeletedView()
    }
    .environmentObject(dataStore)
}

*/
