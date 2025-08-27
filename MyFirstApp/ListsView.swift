//
//  ListsView.swift
//  MyFirstApp
//
//  Displays a list of all active shopping lists
//  - Allows users to view, delete, and interact with their lists
//  - Integrates with DataStore for data management

import SwiftUI
import Foundation

// Import the shared SearchBar component

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
        let activeLists = dataStore.activeLists
        if searchText.isEmpty {
            return activeLists
        } else {
            return activeLists.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    @State private var showDeleteAlert = false
    @State private var listToDelete: MyList? = nil
    
    // MARK: - Body
    
    // MARK: - Helper Views
    
    private var searchBar: some View {
        SearchBar(text: $searchText)
            .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                
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
            
            if searchText.isEmpty {
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
            }
           
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateTitle: String {
        searchText.isEmpty ? "No Lists Available" : "No Matching Lists"
    }
    
    private var emptyStateMessage: String {
        searchText.isEmpty 
            ? "Tap the + button to create your first list"
            : "No lists found for \"\(searchText)\""
      
    }
    
    private func listRow(for list: MyList, at index: Int) -> some View {
        Group {
            if let listIndex = dataStore.lists.firstIndex(where: { $0.id == list.id }) {
                NavigationLink(destination: listDetailView(for: list, at: listIndex)) {
                    ListRowView(list: list, onDelete: {
                        listToDelete = list
                        showDeleteAlert = true
                    })
                }
            }
        }
    }
    
    private func listDetailView(for list: MyList, at index: Int) -> some View {
        // Find the index of the list in the data store to ensure we're working with the correct reference
        if let listIndex = dataStore.lists.firstIndex(where: { $0.id == list.id }) {
            return AnyView(
                ListDetailView(list: $dataStore.lists[listIndex])
                    .onAppear { isShowingListDetail = true }
                    .onDisappear {
                        isShowingListDetail = false
                        dataStore.save()
                    }
            )
        } else {
            // Fallback in case the list isn't found (shouldn't happen in normal operation)
            return AnyView(Text("List not found"))
        }
    }
    
    // MARK: - Main View
    
    /// Main view content
    var body: some View {
        List {
            //searchBar
            
            if filteredLists.isEmpty {
                emptyStateView
            } else {
                ForEach(Array(filteredLists.enumerated()), id: \.element.id) { index, list in
                    listRow(for: list, at: index)
                }
            }
        }
        // MARK: - Navigation & Modifiers
        .navigationTitle("Lists")
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

struct ListRowView: View {
    let list: MyList
    let onDelete: () -> Void
    
    private var purchasedCount: Int { list.items.filter { $0.isCompleted }.count }
    private var totalCount: Int { list.items.count }
    private var isActive: Bool { purchasedCount != totalCount && totalCount > 0 }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(list.name)
                    .font(.headline.bold())
                    .foregroundColor(.accentColor)
                Text(list.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                HStack(spacing: 6) {
                    if purchasedCount == totalCount && totalCount > 0 {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.accentColor)
                    }
                        
                    Text("\(purchasedCount) / \(totalCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if purchasedCount == totalCount && totalCount > 0 {
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                else if purchasedCount != totalCount && totalCount > 0 {
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        //.background(Color(.systemBackground))
        //.cornerRadius(8)
        //.contentShape(Rectangle())
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

// MARK: - Preview

#Preview {
    let dataStore = DataStore()
    dataStore.lists = [
        MyList(name: "Grocery List", items: [], createdAt: Date().addingTimeInterval(-86400 * 2)),
        MyList(name: "Work Tasks", items: [], createdAt: Date().addingTimeInterval(-86400)),
        MyList(name: "Home Improvement", items: [], createdAt: Date())
    ]
    
    return NavigationStack {
        ListsView(isShowingListDetail: .constant(false))
            .environmentObject(dataStore)
    }
}
