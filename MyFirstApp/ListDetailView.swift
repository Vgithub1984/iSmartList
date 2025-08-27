//
//  ListDetailView.swift
//  MyFirstApp
//
//  This file implements the detailed view for a single shopping list.
//  It provides a complete interface for managing list items and tracking progress.
//
//  Key Features:
//  - Displays all items in a scrollable list
//  - Tracks and visualizes completion progress
//  - Supports adding, editing, and removing items
//  - Prevents duplicate items
//  - Auto-saves changes to DataStore
//  - Responsive design for all device sizes

import SwiftUI
import UIKit
import Combine

/// Displays and manages the contents of a single shopping list with full CRUD operations.
///
/// This view provides a detailed interface for interacting with a shopping list, including:
/// - Viewing all items with their completion status
/// - Adding new items with duplicate prevention
/// - Toggling item completion
/// - Deleting items
/// - Tracking overall list completion progress
///
/// - Note: Automatically persists changes to the shared `DataStore` for data persistence.
struct ListDetailView: View {
    // MARK: - Environment
    
    /// The shared data store containing all lists and their items.
    /// Automatically updates the view when the data changes.
    @EnvironmentObject private var dataStore: DataStore
    
    // MARK: - Properties
    
    /// Binding to the current list being viewed/edited.
    /// Updates both locally and in the data store when modified.
    @Binding var list: MyList
    
    /// Environment value to dismiss the current view when needed.
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    /// The current text input for adding new items.
    @State private var inputText: String = ""
    
    /// Local copy of the list's items for efficient UI updates.
    @State private var items: [ItemRow] = []
    
    /// Controls the keyboard focus state of the text input field.
    @FocusState private var isInputFocused: Bool
    
    /// Controls the visibility of the duplicate item alert.
    @State private var showDuplicateAlert = false
    
    /// The name of the duplicate item to display in the alert.
    @State private var duplicateItemName = ""
    
    // MARK: - Computed Properties
    
    /// The number of completed items in the list.
    private var purchasedCount: Int { items.filter { $0.isCompleted }.count }
    
    /// The total number of items in the list.
    private var totalCount: Int { items.count }
    
    /// The completion progress of the list, ranging from 0.0 to 1.0.
    /// Returns 0.0 if the list is empty.
    private var progress: Double { 
        totalCount == 0 ? 0.0 : Double(purchasedCount) / Double(totalCount) 
    }
    
    // MARK: - Initialization
    
    /// Creates a new instance of the list detail view.
    /// - Parameter list: A binding to the `MyList` object to be displayed and edited.
    init(list: Binding<MyList>) {
        self._list = list
        // Initialize the local items state with the list's current items
        self._items = State(initialValue: list.wrappedValue.items)
    }
    
    // MARK: - Private Methods
    
    /// Synchronizes the local items with the latest data from the data store.
    /// Called when the view appears to ensure we have the most up-to-date data.
    private func onAppear() {
        if let index = dataStore.lists.firstIndex(where: { $0.id == list.id }) {
            self.items = dataStore.lists[index].items
        }
    }
    
    /// Updates the items in the current list and persists changes to the data store.
    /// - Note: This method is called after any modification to the items array.
    private func updateListItems() {
        guard let index = dataStore.lists.firstIndex(where: { $0.id == list.id }) else { return }
        var updatedList = dataStore.lists[index]
        updatedList.items = items
        updatedList.updatedAt = Date()
        dataStore.updateList(updatedList)
        // Update the local list binding to ensure consistency
        list = updatedList
    }
    
    /// Adds a new item to the list if it doesn't already exist.
    /// - Parameter name: The name of the item to add.
    /// - Note: Performs case-insensitive duplicate checking and shows an alert if a duplicate is found.
    private func addItem(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Check for duplicate items (case insensitive comparison)
        if items.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            duplicateItemName = trimmedName
            showDuplicateAlert = true
            return
        }
        
        // Add the new item with animation
        withAnimation {
            let newItem = ItemRow(name: trimmedName)
            items.append(newItem)
            updateListItems()
            inputText = ""
            isInputFocused = true
        }
    }
    
    /// Toggles the completion state of the specified item.
    /// - Parameter item: The item whose completion state should be toggled.
    /// - Note: Automatically persists the change to the data store.
    private func toggleItem(_ item: ItemRow) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            updateListItems()
        }
    }
    
    /// Deletes items at the specified index set.
    /// - Parameter offsets: The indices of the items to delete.
    /// - Note: Automatically persists the change to the data store.
    private func deleteItems(offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        updateListItems()
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar content will be added via .toolbar modifier
            // MARK: - Progress Bar
            /// Displays the completion progress of the list
            HStack(spacing: 0) {
                Spacer()
                /// Text indicating the number of purchased items
                Text("Purchased \(purchasedCount) of \(totalCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                /// Progress view displaying the completion percentage
                ProgressView(value: progress)
                    .tint(.green)
                    .frame(width: 180)
                Spacer()
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.caption)
                Spacer()
                
            }
            .padding(.top, 10)
            
            
            HStack(spacing: 10) {
                Spacer()
                TextField("Add Item:", text: $inputText)
                    .autocorrectionDisabled(false)
                    .textInputAutocapitalization(.sentences)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .focused($isInputFocused)
                    .onSubmit {
                        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            if items.contains(where: { $0.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }) {
                                duplicateItemName = trimmed
                                showDuplicateAlert = true
                            } else {
                                items.append(ItemRow(name: trimmed))
                                updateListItems()
                                inputText = ""
                                isInputFocused = true
                            }
                        }
                    }
                Spacer()
            }
            .padding(.top, 10)
            
            // MARK: - Empty State or Items List
            
            if items.isEmpty {
                VStack(spacing: 15) {
                    Spacer()
                    Image(systemName: "list.number.badge.ellipsis")
                        .font(.largeTitle)
                        .foregroundColor(.red.opacity(0.3))
                    VStack(spacing: 0) {
                        Text("No items yet")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .padding()
                        Text("Tap the text field above to add your first item")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // MARK: - Items List
                ScrollView {
                    VStack(spacing: 2) {
                        // Display items sorted alphabetically
                        ForEach(Array(items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }.enumerated()), id: \.element.id) { index, item in
                            HStack(spacing: 10) {
                                // MARK: - Item Checkbox
                                Button {
                                    toggleItem(item)
                                    isInputFocused = true
                                } label: {
                                    HStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 28, height: 28)
                                            Text("\(index + 1)")
                                                .font(.caption.bold())
                                                .foregroundColor(item.isCompleted ? .secondary : .primary)
                                                .strikethrough(item.isCompleted)
                                        }
                                        Text(item.name)
                                            .font(.body)
                                            .foregroundColor(item.isCompleted ? .secondary : .primary)
                                            .strikethrough(item.isCompleted)
                                        Spacer()
                                        if item.isCompleted {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                                
                                // MARK: - Delete Button
                                Button(action: {
                                    if let realIndex = items.firstIndex(where: { $0.id == item.id }) {
                                        items.remove(at: realIndex)
                                        updateListItems()
                                        isInputFocused = true
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(8)
                            .background(item.isCompleted ? Color.green.opacity(0.12) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                }
                .frame(maxHeight: .infinity)
            }
            
            Spacer()
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(alignment: .center, spacing: 2) {
                    Text(list.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text("\(list.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                //.padding(.leading, -16) // Adjust to align with back button
            }
        }
        // MARK: - Alert Modifiers
        
        /// Shows when user tries to add a duplicate item
        .alert("Duplicate Item", isPresented: $showDuplicateAlert) {
            Button("OK", role: .cancel) {
                inputText = ""
                isInputFocused = true
            }
        } message: {
            Text("An item named \"\(duplicateItemName)\" already exists in this list.")
        }
    }
    
}

// MARK: - Previews

#Preview("With Items") {
    // Create a sample list with various items
    let sampleList = MyList(
        name: "Grocery Shopping",
        items: [
            ItemRow(name: "Milk", isCompleted: false, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Bread", isCompleted: false, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Apples", isCompleted: false, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Chicken", isCompleted: true, createdAt: Date(), updatedAt: Date())
        ],
        isDeleted: false,
        createdAt: Date().addingTimeInterval(-86400 * 2), // 2 days ago
        updatedAt: Date()
    )
    
    // Set up the data store with the sample list
    let dataStore = DataStore()
    dataStore.lists = [sampleList]
    
    // Return the preview with navigation
    return NavigationStack {
        ListDetailView(list: .constant(sampleList))
            .environmentObject(dataStore)
    }
}

#Preview("Empty List") {
    // Create an empty list
    let emptyList = MyList(
        name: "Empty Shopping List",
        items: [],
        isDeleted: false,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    // Set up the data store with the empty list
    let dataStore = DataStore()
    dataStore.lists = [emptyList]
    
    // Return the preview with navigation
    return NavigationStack {
        ListDetailView(list: .constant(emptyList))
            .environmentObject(dataStore)
    }
}

#Preview("Completed List") {
    // Create a fully completed list
    let completedList = MyList(
        name: "Completed Shopping",
        items: [
            ItemRow(name: "Milk", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Bread", isCompleted: true, createdAt: Date(), updatedAt: Date())
        ],
        isDeleted: false,
        createdAt: Date().addingTimeInterval(-86400), // 1 day ago
        updatedAt: Date()
    )
    
    // Set up the data store with the completed list
    let dataStore = DataStore()
    dataStore.lists = [completedList]
    
    // Return the preview with navigation
    return NavigationStack {
        ListDetailView(list: .constant(completedList))
            .environmentObject(dataStore)
    }
}
