//
//  ListsView.swift
//  MyFirstApp
//
//  Displays a list of all active shopping lists
//  - Allows users to view, delete, and interact with their lists
//  - Integrates with DataStore for data management

import SwiftUI

/// Displays a scrollable list of all active shopping lists
/// - Note: Integrates with DataStore for data management and supports swipe actions
struct ListsView: View {
    /// Reference to the shared data store for managing lists
    @EnvironmentObject private var dataStore: DataStore
    /// Binding to track if the list detail view is currently shown
    /// - Note: Used to control the visibility of the floating action button in parent view
    @Binding var isShowingListDetail: Bool
    
    /// The current search text
    @State private var searchText = ""
    
    /// The filtered lists based on search text
    private var filteredLists: [MyList] {
        if searchText.isEmpty {
            return dataStore.lists
        } else {
            return dataStore.lists.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    @State private var showDeleteAlert = false
    @State private var listToDelete: MyList? = nil
    
    // MARK: - Body
    
    /// Main view content
    var body: some View {
        List {
            // Show search bar
            SearchBar(text: $searchText)
                .padding(.horizontal)
            
            // Show empty state when no lists exist
            if filteredLists.isEmpty {
                VStack(alignment: .center, spacing: 10) {
                    Spacer()
                    Image(systemName: "list.bullet")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                    Text(searchText.isEmpty ? "No Lists Available" : "No Matching Lists")
                        .font(.headline)
                    Text(searchText.isEmpty ?
                         "Tap the + button to create your first list" :
                         "No lists found for \"\(searchText)\"")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Display each list item with swipe actions wrapped in NavigationLink
                ForEach(Array(filteredLists.enumerated()), id: \.element.id) { index, list in
                    if let listIndex = dataStore.lists.firstIndex(where: { $0.id == list.id }) {
                        NavigationLink(destination:
                            ListDetailView(list: $dataStore.lists[listIndex])
                                .onDisappear {
                                    // Save any changes when the view disappears
                                    dataStore.saveLists()
                                }
                        ) {
                            ListRowView(list: list, onDelete: {
                                listToDelete = list
                                showDeleteAlert = true
                            })
                        }
                    }
                }
            }
        }
        // MARK: - Navigation & Modifiers
        .navigationTitle("Lists")
        .alert("Delete List?", isPresented: $showDeleteAlert, presenting: listToDelete) { list in
            Button("Delete", role: .destructive) {
                withAnimation {
                    dataStore.deleteList(list)
                }
                listToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                listToDelete = nil
            }
        } message: { list in
            Text("Are you sure you want to delete \"\(list.name)\"? This action can be undone from the Deleted tab.")
        }
    }
}

struct ListRowView: View {
    let list: MyList
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(list.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(list.created.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .contentShape(Rectangle())
        // Swipe from right: Delete action (red, full swipe enabled)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        // Swipe from left: Additional actions (blue, no full swipe)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        
        }
        .animation(.easeInOut, value: isFocused)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    let dataStore = DataStore()
    dataStore.lists = [
        MyList(name: "Grocery List", created: Date().addingTimeInterval(-86400 * 2)),
        MyList(name: "Work Tasks", created: Date().addingTimeInterval(-86400)),
        MyList(name: "Home Improvement", created: Date())
    ]
    
    return NavigationStack {
        ListsView(isShowingListDetail: .constant(false))
            .environmentObject(dataStore)
    }
}

