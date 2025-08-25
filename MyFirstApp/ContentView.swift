//
//  ContentView.swift
//  MyFirstApp
//
//  Created by Varun Patel on 8/24/25.
//

import SwiftUI
import SwiftData
import Combine

/// Represents a single list in the application
/// - Note: Conforms to `Identifiable` for SwiftUI list views and `Codable` for persistence
struct MyList: Identifiable, Codable, Hashable {
    /// Unique identifier for the list
    var id: UUID
    /// Display name of the list
    var name: String
    /// Creation timestamp of the list
    var created: Date
    /// Flag indicating if the list has been soft-deleted
    var isDeleted: Bool
    /// Timestamp when the list was soft-deleted (nil if not deleted)
    var deletedAt: Date?
    /// Serialized data containing the list's items (stored as JSON)
    var itemsData: Data?
    
    /// Coding keys for Codable conformance
    private enum CodingKeys: String, CodingKey {
        case id, name, created, isDeleted, deletedAt, itemsData
    }
    
    /// Initializes a new list with the specified parameters
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - name: The display name of the list
    ///   - created: Creation date (defaults to current date)
    ///   - isDeleted: Whether the list is marked as deleted (defaults to false)
    ///   - deletedAt: When the list was deleted (defaults to nil)
    ///   - itemsData: Serialized items data (defaults to nil)
    init(id: UUID = UUID(),
         name: String,
         created: Date = Date(),
         isDeleted: Bool = false,
         deletedAt: Date? = nil,
         itemsData: Data? = nil) {
        self.id = id
        self.name = name
        self.created = created
        self.isDeleted = isDeleted
        self.deletedAt = deletedAt
        self.itemsData = itemsData
    }
    
    // Required for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Required for Equatable conformance (part of Hashable)
    static func == (lhs: MyList, rhs: MyList) -> Bool {
        lhs.id == rhs.id
    }
}

/// Manages the application's data including lists and deleted lists
/// - Note: Uses `@MainActor` to ensure UI updates happen on the main thread
@MainActor
class DataStore: ObservableObject {
    /// Array of active (non-deleted) lists
    @Published var lists: [MyList] = []
    /// Array of soft-deleted lists
    @Published var deletedLists: [MyList] = []
    
    /// Initializes the DataStore and loads savedp data
    init() {
        loadLists()
    }
    
    /// Adds a new list with the given name
    /// - Parameter name: The name of the new list
    func addList(name: String) {
        let newList = MyList(name: name, created: Date())
        lists.append(newList)
        saveLists()
    }
    
    /// Soft-deletes a list by moving it to the deletedLists array
    /// - Parameter list: The list to be soft-deleted
    func deleteList(_ list: MyList) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            var deletedList = lists[index]
            deletedList.isDeleted = true
            deletedList.deletedAt = Date()
            lists.remove(at: index)
            deletedLists.append(deletedList)
            saveLists()
        }
    }
    
    /// Restores a soft-deleted list by moving it back to the active lists
    /// - Parameter list: The list to be restored
    func restoreList(_ list: MyList) {
        if let index = deletedLists.firstIndex(where: { $0.id == list.id }) {
            var restoredList = deletedLists[index]
            restoredList.isDeleted = false
            restoredList.deletedAt = nil
            deletedLists.remove(at: index)
            lists.append(restoredList)
            saveLists()
        }
    }
    
    /// Permanently deletes a list from the deleted lists
    /// - Parameter list: The list to be permanently deleted
    func permanentDelete(_ list: MyList) {
        if let index = deletedLists.firstIndex(where: { $0.id == list.id }) {
            deletedLists.remove(at: index)
            saveLists()
        }
    }
    
    /// Saves both active and deleted lists to UserDefaults
    /// - Note: Uses JSONEncoder to serialize the lists and stores them in UserDefaults
    func saveLists() {
        do {
            let activeData = try JSONEncoder().encode(lists)
            let deletedData = try JSONEncoder().encode(deletedLists)
            UserDefaults.standard.set(activeData, forKey: "activeLists")
            UserDefaults.standard.set(deletedData, forKey: "deletedLists")
        } catch {
            print("Error saving lists: \(error.localizedDescription)")
        }
    }
    
    /// Loads both active and deleted lists from UserDefaults
    private func loadLists() {
        // Load active lists
        if let savedActiveData = UserDefaults.standard.data(forKey: "activeLists") {
            do {
                lists = try JSONDecoder().decode([MyList].self, from: savedActiveData)
                // Ensure no deleted lists are in the active lists
                lists.removeAll(where: { $0.isDeleted })
            } catch {
                print("Error loading active lists: \(error.localizedDescription)")
            }
        }
        
        // Load deleted lists
        if let savedDeletedData = UserDefaults.standard.data(forKey: "deletedLists") {
            do {
                deletedLists = try JSONDecoder().decode([MyList].self, from: savedDeletedData)
                // Ensure all deleted lists have the correct isDeleted flag
                for i in deletedLists.indices {
                    deletedLists[i].isDeleted = true
                }
            } catch {
                print("Error loading deleted lists: \(error.localizedDescription)")
            }
        }
    }
}

/// Main application view containing the tab-based navigation
/// - Note: Manages the overall app structure including tabs and floating action button
struct ContentView: View {
    /// The shared data store for managing all app data
    @EnvironmentObject private var dataStore: DataStore
    /// Currently selected tab index (0: Lists, 1: Deleted, 2: Stats, 3: Profile)
    @State private var selectedTab: Int = 0
    /// Controls visibility of the floating action button when in list detail view
    @State private var isShowingListDetail = false
    @State private var showingDeleteAllDialog = false
    @State private var showingListsDeleteAllDialog = false
    
    // MARK: - Body
    
    /// Main app content with tab view and floating action button
    var body: some View {
        // Main container with tab view and floating action button
        ZStack(alignment: .bottomTrailing) {
            // Floating action button for adding new lists
            if selectedTab == 0 && !isShowingListDetail {
                VStack(spacing: 0) {
                    Spacer()
                    
                    // The + button
                    Button(action: {
                        dataStore.addList(name: "List #\(dataStore.lists.count + 1)")
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.black)
                            .frame(width: 56, height: 56)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .padding(.trailing, 45)
                            .padding(.bottom, 55) // Position above the tab bar
                    }
                    
                    Spacer()
                        .frame(height: 8)
                }
                .transition(.scale)
                .zIndex(1) // Ensure it's above the tab bar
            }
            // MARK: - Tab View
            
            /// Main tab-based navigation
            TabView(selection: $selectedTab) {
                NavigationStack {
                    ListsView(isShowingListDetail: $isShowingListDetail)
                        .onChange(of: selectedTab) { _ in
                            isShowingListDetail = false
                        }
                        .toolbar {
                            // Delete All button (if there are lists)
                            ToolbarItem(placement: .navigationBarTrailing) {
                                if !dataStore.lists.isEmpty {
                                    Button(role: .destructive) {
                                        showingListsDeleteAllDialog = true
                                    } label: {
                                        Text("Delete All")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .confirmationDialog("Delete All Lists?", isPresented: $showingListsDeleteAllDialog, titleVisibility: .visible) {
                            Button("Delete All", role: .destructive) {
                                let moved = dataStore.lists.map { list -> MyList in
                                    var l = list
                                    l.isDeleted = true
                                    l.deletedAt = Date()
                                    return l
                                }
                                dataStore.deletedLists.append(contentsOf: moved)
                                dataStore.lists.removeAll()
                                dataStore.saveLists()
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Are you sure you want to move all your lists to Deleted? This can be undone from the Deleted tab.")
                        }
                }
                .tabItem {
                    Label {
                        Text("Lists")
                            .foregroundStyle(selectedTab == 0 ? .primary : .secondary)
                            .fontWeight(selectedTab == 0 ? .bold : .regular)
                    } icon: {
                        Image(systemName: "list.bullet")
                            .foregroundStyle(selectedTab == 0 ? .primary : .secondary)
                            .fontWeight(selectedTab == 0 ? .bold : .regular)
                    }
                }
                .tag(0)
                .badge(dataStore.lists.count)
                
                // MARK: - Deleted Tab
                
                NavigationStack {
                    DeletedView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                if !dataStore.lists.isEmpty {
                                    Button(role: .destructive) {
                                        showingDeleteAllDialog = true
                                    } label: {
                                        Text("Delete All")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .confirmationDialog("Delete All Lists?", isPresented: $showingDeleteAllDialog, titleVisibility: .visible) {
                            Button("Delete All", role: .destructive) {
                                let moved = dataStore.lists.map { list -> MyList in
                                    var l = list
                                    l.isDeleted = true
                                    l.deletedAt = Date()
                                    return l
                                }
                                dataStore.deletedLists.append(contentsOf: moved)
                                dataStore.lists.removeAll()
                                dataStore.saveLists()
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Are you sure you want to move all your lists to Deleted? This can be undone from the Deleted tab.")
                        }
                }
                .tabItem {
                    Label {
                        Text("Deleted")
                            .foregroundStyle(selectedTab == 1 ? .primary : .secondary)
                            .fontWeight(selectedTab == 1 ? .bold : .regular)
                    } icon: {
                        Image(systemName: "trash")
                            .foregroundStyle(selectedTab == 1 ? .primary : .secondary)
                            .fontWeight(selectedTab == 1 ? .bold : .regular)
                    }
                }
                .tag(1)
                .badge(dataStore.deletedLists.count)
                
                // MARK: - Stats Tab
                
                /// Displays the statistics view
                NavigationStack {
                    Text("Stats View")
                        .font(.title)
                }
                .tabItem {
                    /// Label for the Stats tab
                    Label {
                        Text("Stats")
                            .foregroundStyle(selectedTab == 2 ? .primary : .secondary)
                            .fontWeight(selectedTab == 2 ? .bold : .regular)
                    } icon: {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundStyle(selectedTab == 2 ? .primary : .secondary)
                            .fontWeight(selectedTab == 2 ? .bold : .regular)
                    }
                }
                .tag(2)
                
                // MARK: - Profile Tab
                
                /// Displays the profile view
                NavigationStack {
                    Text("Profile View")
                        .font(.title)
                }
                .tabItem {
                    /// Label for the Profile tab
                    Label {
                        Text("Profile")
                            .foregroundStyle(selectedTab == 3 ? .primary : .secondary)
                            .fontWeight(selectedTab == 3 ? .bold : .regular)
                    } icon: {
                        Image(systemName: "person.crop.circle")
                            .foregroundStyle(selectedTab == 3 ? .primary : .secondary)
                            .fontWeight(selectedTab == 3 ? .bold : .regular)
                    }
                }
                .tag(3)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(DataStore())
}
