// Moved to Views/ directory as part of project restructuring.
//
//  DeletedView.swift
//  MyFirstApp
//
//  Displays all soft-deleted shopping lists
//  - Allows users to restore or permanently delete lists
//  - Integrates with DataStore for data management

import SwiftUI

// Using the shared SearchBar component from Views/SearchBar.swift

/// Displays a list of soft-deleted shopping lists with options to restore or permanently delete them
/// - Note: Integrates with DataStore for managing deleted lists
struct DeletedView: View {
    /// Reference to the shared data store for managing deleted lists
    @EnvironmentObject private var dataStore: DataStore
    /// Controls the visibility of the delete confirmation alert
    @State private var showingDeleteAlert = false
    /// Reference to the list being considered for permanent deletion
    @State private var listToDelete: MyList?
    
    @State private var showingDeleteAllDialog = false
    @State private var listToRestore: MyList? = nil
    
    @State private var searchText = ""
    
    private var filteredDeletedLists: [MyList] {
        let filtered: [MyList]
        if searchText.isEmpty {
            filtered = dataStore.deletedLists
        } else {
            filtered = dataStore.deletedLists.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return filtered.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    // Get the items directly from the list
    private func getItems(from list: MyList) -> [ItemRow] {
        return list.items
    }

    /// Builds a DeletedListRow for the given list
    private func buildDeletedListRow(for list: MyList) -> some View {
        let items = getItems(from: list)
        let totalCount = items.count
        let purchasedCount = items.filter { $0.isCompleted }.count
        return DeletedListRow(
            list: list,
            items: items,
            totalCount: totalCount,
            purchasedCount: purchasedCount,
            onDelete: {
                listToDelete = list
                showingDeleteAlert = true
            },
            onRestore: {
                listToRestore = list
            }
        )
    }
    
    // MARK: - Body
    
    /// Main view content
    var body: some View {
        List {
            /*SearchBar(text: $searchText)
                .padding(.horizontal)
             */
            
            // Show empty state if no filtered deleted lists exist
            if filteredDeletedLists.isEmpty {
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "trash")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("No Deleted Lists")
                                .font(.headline)
                            
                            Text("Deleted lists will appear here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Display each deleted list with restore/delete options
                ForEach(filteredDeletedLists) { list in
                    buildDeletedListRow(for: list)
                }
            }
        }
        // MARK: - Alert Modifiers
        
        /// Confirmation dialog for permanent deletion
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
        .alert("Restore List?", isPresented: Binding<Bool>(get: { listToRestore != nil }, set: { if !$0 { listToRestore = nil } })) {
            Button("Restore", role: .none) {
                if var list = listToRestore {
                    withAnimation {
                        // Restore the list by marking it as not deleted
                        list.isDeleted = false
                        list.updatedAt = Date()
                        dataStore.updateList(list)
                    }
                    listToRestore = nil
                }
            }
            Button("Cancel", role: .cancel) {
                listToRestore = nil
            }
        } message: {
            if let list = listToRestore {
                Text("Are you sure you want to restore \"\(list.name)\" back to Lists section ?")
            } else {
                Text("")
            }
        }
        .navigationTitle("Deleted")
        // MARK: - Toolbar
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
        .confirmationDialog("Delete All Deleted Lists?", isPresented: $showingDeleteAllDialog, titleVisibility: .visible) {
            Button("Delete All", role: .destructive) {
                // Permanently delete all deleted lists
                let deletedLists = dataStore.lists.filter { $0.isDeleted }
                for list in deletedLists {
                    dataStore.permanentDelete(list)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to permanently delete all deleted lists? This action cannot be undone.")
        }
    }
}

private struct DeletedListRow: View {
    let list: MyList
    let items: [ItemRow]
    let totalCount: Int
    let purchasedCount: Int
    let onDelete: () -> Void
    let onRestore: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(list.name)
                    .font(.headline)
                    .strikethrough()
                Text("Deleted \(list.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "cart.fill")
                    .foregroundColor(totalCount > 0 && purchasedCount == totalCount ? .green : .secondary)
                Text("\(purchasedCount) of \(totalCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Menu {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete Permanently", systemImage: "trash")
                }
                Button(action: onRestore) {
                    Label("Restore", systemImage: "arrow.uturn.backward")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Preview

#Preview {
    let dataStore = DataStore()
    // Add some sample deleted lists for preview
    let deletedList = MyList(
        name: "Old Grocery List",
        items: [
            ItemRow(name: "Milk", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date())
        ],
        isDeleted: true,
        createdAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
        updatedAt: Date().addingTimeInterval(-86400 * 2)  // 2 days ago
    )
    dataStore.lists = [deletedList]
    
    return NavigationStack {
        DeletedView()
    }
    .environmentObject(dataStore)
}
