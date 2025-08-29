//
//  ListsView.swift
//  MyFirstApp
//
//  This file implements the main list view that displays all active shopping lists.
//  It provides functionality to view, search, and manage lists with swipe actions.
//
//  Key Features:
//  - Displays a scrollable list of all active shopping lists
//  - Supports searching and filtering lists by name
//  - Provides swipe actions for quick list management
//  - Shows empty states and helpful guidance
//  - Integrates with DataStore for data persistence

import SwiftUI
import Foundation

/// Displays a scrollable list of all active shopping lists with search and management capabilities.
///
/// This view serves as the primary interface for users to interact with their shopping lists.
/// It handles displaying lists, searching, and basic list management operations.
///
/// - Note: Integrates with `DataStore` for data management and supports swipe actions for list operations.
struct ListsView: View {
    // MARK: - Environment
    
    /// The shared data store containing all lists and their items.
    /// Automatically updates the view when the data changes.
    @EnvironmentObject private var dataStore: DataStore
    
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Properties
    
    /// Binding to track if the list detail view is currently shown.
    /// - Note: Used by the parent view to control the visibility of the floating action button.
    @Binding var isShowingListDetail: Bool
    
    // MARK: - State
    
    /// Controls the visibility of the delete confirmation alert.
    @State private var showDeleteAlert = false
    
    /// The list that is currently being considered for deletion.
    @State private var listToDelete: MyList? = nil
    
    // MARK: - Initializer
    
    init(isShowingListDetail: Binding<Bool>) {
        self._isShowingListDetail = isShowingListDetail
    }
    
    // MARK: - Helper Computed Properties for List Categories
    
    /// Lists that are fully completed.
    private var completedLists: [MyList] { dataStore.completedLists }
    /// Lists that are active (have incomplete items).
    private var activeLists: [MyList] { dataStore.activeLists }
    /// Lists that have zero items.
    private var zeroItemLists: [MyList] { dataStore.zeroItemLists }
    /// Lists that are marked as deleted.
    private var deletedLists: [MyList] { dataStore.deletedLists }
    
    /// Combined active lists excluding deleted and zero item lists, sorted by updatedAt descending.
    private var filteredLists: [MyList] {
        // Show active, zero item, and completed lists combined but excluding deleted
        // Sort by updatedAt descending so the most recently updated lists appear first
        let combined = activeLists + completedLists + zeroItemLists
        return combined.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    // MARK: - Subviews
    
    /// The view displayed when there are no lists to show.
    /// - Note: Shows a message indicating there are no lists available.
    private var emptyStateView: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            
            VStack(spacing: 20) {
                // Icon representing empty state
                Image(systemName: "list.bullet")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                
                // Title and message
                VStack(spacing: 8) {
                    Text(emptyStateTitle)
                        .font(.headline)
                    
                    Text(emptyStateMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            VStack(spacing: 5) {
                Text("Important Gestures:")
                    .font(.headline)
                    .padding(.top, 15)
                
                HStack(spacing: 12) {
                    Image(systemName: "hand.point.left.fill")
                        .foregroundColor(.secondary)
                    Text("Swipe Left or Right to delete the list")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Image(systemName: "hand.point.right.fill")
                        .foregroundColor(.secondary)
                }
            }
            .opacity(0.8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Properties
    
    /// The title to display in the empty state view.
    /// - Returns: A string indicating no lists are available.
    private var emptyStateTitle: String {
        "No Lists Available"
    }
    
    /// The message to display in the empty state view.
    /// - Returns: Guidance to create the first list.
    private var emptyStateMessage: String {
        "Tap the + button to create your first list"
    }
    
    // MARK: - Helper Methods
    
    /// Creates a view for a single list row with navigation and delete functionality.
    /// - Parameters:
    ///   - list: The list to display in this row.
    ///   - index: The index of the list in the filtered array (unused but preserved for future use).
    /// - Returns: A view representing the list row with swipe actions and navigation.
    private func listRow(for list: MyList, at index: Int) -> some View {
        // Create a binding to the list for two-way data flow
        let listBinding = Binding<MyList>(
            get: { list },
            set: { updatedList in
                if let index = dataStore.lists.firstIndex(where: { $0.id == updatedList.id }) {
                    dataStore.lists[index] = updatedList
                }
            }
        )
        
        // Create the list row view with delete action
        return ListRowView(list: list, onDelete: {
            listToDelete = list
            showDeleteAlert = true
        })
        // Add hidden navigation link for list detail view
        .background(
            NavigationLink(
                destination: ListDetailView(list: listBinding)
                    .onAppear { isShowingListDetail = true }
                    .onDisappear {
                        isShowingListDetail = false
                        dataStore.save()
                    },
                label: { EmptyView() }
            )
            .opacity(0) // Hide the default navigation link styling
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            // Show empty state or list of lists
            if filteredLists.isEmpty {
                emptyStateView
            } else {
                ForEach(Array(filteredLists.enumerated()), id: \.element.id) { index, list in
                    listRow(for: list, at: index)
                }
                Text("Swipe Left or Right to delete the list")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }
        }
        // MARK: - View Modifiers
        .navigationTitle("Lists")
        .navigationBarTitleDisplayMode(.inline)
        // Confirmation dialog for list deletion
        .alert("Delete List?", isPresented: $showDeleteAlert, presenting: listToDelete) { list in
            Button("Delete", role: .destructive) {
                withAnimation {
                    dataStore.softDeleteList(list)
                }
                listToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                listToDelete = nil
            }
        } message: { list in
            Text("Are you sure you want to move \"\(list.name)\" to the Deleted tab? You can restore it later.")
        }
    }
}

// MARK: - ListRowView

/// A view representing a single row in the lists view.
///
/// Displays list information including name, creation date, and completion status.
/// Supports swipe actions for list management.
struct ListRowView: View {
    // MARK: - Properties
    
    /// The list to display in this row.
    let list: MyList
    
    /// The action to perform when the delete action is triggered.
    let onDelete: () -> Void
    
    // MARK: - Computed Properties
    
    /// The number of completed items in the list.
    private var purchasedCount: Int { list.items.filter { $0.isCompleted }.count }
    
    /// The total number of items in the list.
    private var totalCount: Int { list.items.count }
    
    /// Whether the list is considered active (has incomplete items).
    private var isActive: Bool { purchasedCount != totalCount && totalCount > 0 }
    
    /// Whether the list is considered completed (all items completed and not empty).
    private var isCompleted: Bool { purchasedCount == totalCount && totalCount > 0 }
    
    /// Whether the list has zero items.
    private var isZeroItem: Bool { totalCount == 0 }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center) {
            // List name and creation date
            VStack(alignment: .leading, spacing: 6) {
                Text(list.name)
                    .font(.headline.bold())
                    .foregroundColor(.accentColor)
                Text(list.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Completion status and count
            VStack(alignment: .trailing) {
                HStack(spacing: 6) {
                    // Cart icon with color based on canonical mutually exclusive completion status
                    Group {
                        if isCompleted {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.green)
                        } else if isZeroItem {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.gray)
                        } else if isActive {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.accentColor)
                        } else {
                            // Fallback to gray icon if no category matched
                            Image(systemName: "cart.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Completion count (e.g., "3/5")
                    Text("\(purchasedCount) / \(totalCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Status text below the count (mutually exclusive)
                Group {
                    if isZeroItem {
                        Text("Zero Items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if isCompleted {
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if isActive {
                        Text("Active")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        // No status text for empty fallback
                        EmptyView()
                    }
                }
            }
            
            Text("")
            VStack(alignment: .trailing) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
           
        }
        .padding(.vertical, 0)
        .padding(.horizontal,10)
        
        // Swipe actions for list management
        
        // Swipe from right: Delete action (red, full swipe enabled)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        
        // Swipe from left: Additional actions (currently same as right swipe)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Previews

#Preview("With Lists") {
    // Create a preview data store with sample lists
    let dataStore = DataStore()
    dataStore.lists = [
        MyList(
            name: "Grocery List",
            items: [
                ItemRow(name: "Milk", isCompleted: true, createdAt: Date(), updatedAt: Date()),
                ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date()),
                ItemRow(name: "Bread", isCompleted: false, createdAt: Date(), updatedAt: Date())
            ],
            isDeleted: false,
            createdAt: Date().addingTimeInterval(-86400 * 2),
            updatedAt: Date()
        ),
        MyList(
            name: "Work Tasks",
            items: [
                ItemRow(name: "Finish report", isCompleted: true, createdAt: Date(), updatedAt: Date()),
                ItemRow(name: "Team meeting", isCompleted: false, createdAt: Date(), updatedAt: Date())
            ],
            isDeleted: false,
            createdAt: Date().addingTimeInterval(-86400),
            updatedAt: Date()
        ),
        MyList(
            name: "Home Improvement",
            items: [],
            isDeleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    // Use a State for isShowingDetail to provide a binding
    struct WrapperView: View {
        @State private var isShowingDetail = false
        @EnvironmentObject var dataStore: DataStore
        
        var body: some View {
            NavigationStack {
                ListsView(isShowingListDetail: $isShowingDetail)
                    .environmentObject(dataStore)
            }
        }
        
        @Environment(\.colorScheme) private var colorScheme
    }
    
    return WrapperView()
        .environmentObject(dataStore)
}

#Preview("Empty State") {
    // Empty data store for empty state preview
    let dataStore = DataStore()
    
    struct WrapperView: View {
        @State private var isShowingDetail = false
        @EnvironmentObject var dataStore: DataStore
        
        var body: some View {
            NavigationStack {
                ListsView(isShowingListDetail: $isShowingDetail)
                    .environmentObject(dataStore)
            }
        }
        
        @Environment(\.colorScheme) private var colorScheme
    }
    
    return WrapperView()
        .environmentObject(dataStore)
}

