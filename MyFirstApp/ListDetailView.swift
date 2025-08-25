//
//  ListDetailView.swift
//  MyFirstApp
//
//  Displays the details of a shopping list including all items
//  - Allows adding, marking, and removing items
//  - Shows completion progress
//  - Integrates with DataStore for data persistence

import SwiftUI

/// Represents a single item in a shopping list
/// - Note: Conforms to `Identifiable`, `Hashable`, and `Codable` for SwiftUI and persistence
struct ItemRow: Identifiable, Hashable, Codable {
    /// Unique identifier for the item
    var id = UUID()
    /// Display name of the item
    var name: String
    /// Indicates if the item has been marked as completed
    var marked: Bool = false
    
    /// Initializes a new item with the specified parameters
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - name: Display name of the item
    ///   - marked: Completion status (defaults to false)
    init(id: UUID = UUID(), name: String, marked: Bool = false) {
        self.id = id
        self.name = name
        self.marked = marked
    }
    
    // Required for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Required for Equatable conformance (part of Hashable)
    static func == (lhs: ItemRow, rhs: ItemRow) -> Bool {
        lhs.id == rhs.id
    }
}

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
    private var purchasedCount: Int { items.filter { $0.marked }.count }
    /// Total number of items in the list
    private var totalCount: Int { items.count }
    /// Progress value (0.0 to 1.0) representing completion percentage
    private var progress: Double { totalCount == 0 ? 0.0 : Double(purchasedCount) / Double(totalCount) }
    
    /// Initializes the view with required dependencies
    /// - Parameters:
    ///   - list: Binding to the list being viewed/edited
    init(list: Binding<MyList>) {
        self._list = list
        
        // Load items from the list if they exist
        if let itemsData = list.wrappedValue.itemsData,
           let decodedItems = try? JSONDecoder().decode([ItemRow].self, from: itemsData) {
            self._items = State(initialValue: decodedItems)
        }
    }
    
    /// Saves the current items to the data store
    /// - Note: Encodes items to JSON and updates the parent list
    private func saveItems() {
        do {
            let encoded = try JSONEncoder().encode(items)
            if let index = dataStore.lists.firstIndex(where: { $0.id == list.id }) {
                dataStore.lists[index].itemsData = encoded
                // Update the local list reference
                list = dataStore.lists[index]
                // Save to persistent storage
                dataStore.saveLists()
            }
        } catch {
            print("Error saving items: \(error.localizedDescription)")
        }
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
            saveItems()
            inputText = ""
            isInputFocused = true
        }
    }
    
    /// Toggles the completion state of an item
    /// - Parameter item: The item to toggle
    private func toggleItem(_ item: ItemRow) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation {
                items[index].marked.toggle()
                saveItems()
            }
        }
    }
    
    /// Deletes an item from the list
    /// - Parameter item: The item to delete
    private func deleteItem(_ item: ItemRow) {
        withAnimation {
            items.removeAll { $0.id == item.id }
            saveItems()
        }
    }
    
    // MARK: - Body
    
    /// Main view content
    var body: some View {
        VStack(spacing: 0) {
            // Dismiss keyboard on drag
            Color.clear
                .frame(height: 0)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            VStack(spacing: 0) {
                // List header with back button and title
                HStack {
                    Spacer()
                    // MARK: - Back Button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                    
                    // MARK: - List Title
                    Spacer()
                    VStack(spacing: 2) {
                        Text(list.name)
                            .font(.headline)
                            .lineLimit(1)
                        Text(list.created.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Invisible view with same width as back button for balance
                    Color.clear
                        .frame(width: 50, height: 1)
                }
                
            }
            .frame(height: 55)
            .background(.green.opacity(0.4))
  
            // MARK: - Progress Bar
            /// Displays the completion progress of the list
            HStack(spacing: 5) {
                Spacer()
                /// Text indicating the number of purchased items
                Text("Purchased \(purchasedCount) of \(totalCount) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                /// Progress view displaying the completion percentage
                ProgressView(value: progress)
                    .tint(.green)
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
                                saveItems()
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
                VStack(spacing: 0) {
                    Spacer()
                    Text("No items yet")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding()
                    Text("Tap the text field above to add your first item")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
                                            .foregroundColor(item.marked ? .secondary : .primary)
                                            .strikethrough(item.marked)
                                    }
                                    Text(item.name)
                                        .font(.body)
                                        .foregroundColor(item.marked ? .secondary : .primary)
                                        .strikethrough(item.marked)
                                    Spacer()
                                    if item.marked {
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
                                    saveItems()
                                    isInputFocused = true
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                        .background(item.marked ? Color.green.opacity(0.12) : Color.clear)
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
        // MARK: - Alert Modifiers
        
        /// Shows when user tries to add a duplicate item
        .alert("Duplicate Item", isPresented: $showDuplicateAlert) {
            Button("OK", role: .cancel) {
                inputText = ""
                isInputFocused = true
            }
        } message: {
            Text("\"\(duplicateItemName)\" is already in your list and will not be added.")
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview

#Preview {
    let dataStore = DataStore()
    var list = MyList(name: "Grocery List", created: Date())
    let items = [
        ItemRow(name: "Milk"),
        ItemRow(name: "Eggs", marked: true),
        ItemRow(name: "Bread")
    ]
    if let encoded = try? JSONEncoder().encode(items) {
        list.itemsData = encoded
    }
    return ListDetailView(list: .constant(list))
        .environmentObject(dataStore)
        .preferredColorScheme(.dark)
}
