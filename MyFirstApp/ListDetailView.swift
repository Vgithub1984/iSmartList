//
//  ListDetailView.swift
//  MyFirstApp
//
//  Displays the details of a shopping list including all items
//  - Allows adding, marking, and removing items
//  - Shows completion progress
//  - Integrates with DataStore for data persistence

import SwiftUI
import UIKit
import Combine

/// Displays and manages the contents of a single shopping list
/// - Note: Handles all CRUD operations for list items and integrates with DataStore
struct ListDetailView: View {
    /// Reference to the shared data store for managing list data
    @EnvironmentObject private var dataStore: DataStore
    /// Binding to the current list being viewed/edited
    @Binding var list: MyList
    /// Environment value to dismiss the current view
    @Environment(\.dismiss) private var dismiss
    /// Text input for adding new items
    @State private var inputText: String = ""
    /// Array of items in the current list
    @State private var items: [ItemRow] = []
    /// Controls the focus state of the text input field
    @FocusState private var isInputFocused: Bool
    /// Controls the visibility of the duplicate item alert
    @State private var showDuplicateAlert = false
    /// Name of the duplicate item to show in the alert
    @State private var duplicateItemName = ""
    
    /// Number of completed items in the list
    private var purchasedCount: Int { items.filter { $0.isCompleted }.count }
    /// Total number of items in the list
    private var totalCount: Int { items.count }
    /// Progress value (0.0 to 1.0) representing completion percentage
    private var progress: Double { totalCount == 0 ? 0.0 : Double(purchasedCount) / Double(totalCount) }
    
    /// Initializes the view with required dependencies
    /// - Parameters:
    ///   - list: Binding to the list being viewed/edited
    init(list: Binding<MyList>) {
        self._list = list
        // Initialize items from the list's items array
        self._items = State(initialValue: list.wrappedValue.items)
    }
    
    /// Called when the view appears to ensure we have the latest data
    private func onAppear() {
        // Update items from the data store
        if let index = dataStore.lists.firstIndex(where: { $0.id == list.id }) {
            self.items = dataStore.lists[index].items
        }
    }
    
    /// Updates the items in the current list
    private func updateListItems() {
        guard let index = dataStore.lists.firstIndex(where: { $0.id == list.id }) else { return }
        var updatedList = dataStore.lists[index]
        updatedList.items = items
        updatedList.updatedAt = Date()
        dataStore.updateList(updatedList)
        // Update the local list binding
        list = updatedList
    }
    
    /// Adds a new item to the list if it doesn't already exist
    /// - Parameter name: The name of the item to add
    private func addItem(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Check for duplicate items (case insensitive)
        if items.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            duplicateItemName = trimmedName
            showDuplicateAlert = true
            return
        }
        
        withAnimation {
            let newItem = ItemRow(name: trimmedName)
            items.append(newItem)
            updateListItems()
            inputText = ""
            isInputFocused = true
        }
    }
    
    /// Toggles the completion state of an item
    private func toggleItem(_ item: ItemRow) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            updateListItems()
        }
    }
    
    /// Deletes items at the specified offsets
    private func deleteItems(offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        updateListItems()
    }
    
    // MARK: - Body
    
    /// Main view content
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

// MARK: - Preview

#Preview {
    let sampleList = MyList(
        name: "Sample List",
        items: [
            ItemRow(name: "Milk", isCompleted: false, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Bread", isCompleted: false, createdAt: Date(), updatedAt: Date())
        ],
        isDeleted: false,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    let dataStore = DataStore()
    dataStore.lists = [sampleList]
    
    return NavigationStack {
        ListDetailView(list: .constant(sampleList))
            .environmentObject(dataStore)
    }
}
