//
//  DeletedView.swift
//  MyFirstApp
//
//  Displays all soft-deleted shopping lists
//  - Allows users to restore or permanently delete lists
//  - Integrates with DataStore for data management

import SwiftUI

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
    
    // MARK: - Body
    
    /// Main view content
    var body: some View {
        List {
            // Show empty state if no deleted lists exist
            if dataStore.deletedLists.isEmpty {
                Text("No Deleted items available")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                // Display each deleted list with restore/delete options
                ForEach(dataStore.deletedLists) { list in
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(list.name)
                                .font(.headline)
                                .strikethrough()
                            if let deletedAt = list.deletedAt {
                                Text("Deleted \(deletedAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        
                        Menu {
                            Button(role: .destructive) {
                                listToDelete = list
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete Permanently", systemImage: "trash")
                            }
                            
                            Button {
                                listToRestore = list
                            } label: {
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
        }
        // MARK: - Alert Modifiers
        
        /// Confirmation dialog for permanent deletion
        .alert("Delete Permanently", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let list = listToDelete {
                    withAnimation {
                        dataStore.permanentDelete(list)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to permanently delete this list? This action cannot be undone.")
        }
        .alert("Restore List?", isPresented: Binding<Bool>(get: { listToRestore != nil }, set: { if !$0 { listToRestore = nil } })) {
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
                Text("Are you sure you want to restore \"\(list.name)\" back to Lists section ?")
            } else {
                Text("")
            }
        }
        .navigationTitle("Deleted")
        // MARK: - Toolbar
        .toolbar {
            // Delete All button (if there are deleted lists)
            ToolbarItem(placement: .navigationBarTrailing) {
                if !dataStore.deletedLists.isEmpty {
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
                for list in dataStore.deletedLists {
                    dataStore.permanentDelete(list)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to permanently delete all deleted lists? This action cannot be undone.")
        }
    }
}

// MARK: - Preview

#Preview {
    let dataStore = DataStore()
    dataStore.deletedLists = [
        MyList(name: "Old Grocery List", created: Date().addingTimeInterval(-86400 * 7), isDeleted: true, deletedAt: Date().addingTimeInterval(-86400 * 2)),
        MyList(name: "Work Tasks (Old)", created: Date().addingTimeInterval(-86400 * 14), isDeleted: true, deletedAt: Date().addingTimeInterval(-86400 * 5))
    ]
    return DeletedView()
        .environmentObject(dataStore)
}
