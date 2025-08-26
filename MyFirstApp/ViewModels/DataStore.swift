import Foundation
import SwiftUI
import Combine

// MARK: - Data Models

/// Represents an item in a shopping list
public struct ItemRow: Identifiable, Codable, Hashable {
    public var id = UUID()
    public var name: String
    public var isCompleted: Bool = false
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()
    
    public init(id: UUID = UUID(), name: String, isCompleted: Bool = false, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a shopping list containing multiple items
public struct MyList: Identifiable, Codable, Hashable {
    public var id = UUID()
    public var name: String
    public var items: [ItemRow] = []
    public var isDeleted: Bool = false
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()
    
    // Computed property to track list completion progress
    public var progress: Double {
        guard !items.isEmpty else { return 0 }
        let completedCount = items.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(items.count)
    }
    
    // Computed property to check if all items are completed
    public var isComplete: Bool {
        !items.isEmpty && items.allSatisfy { $0.isCompleted }
    }
    
    public init(id: UUID = UUID(), name: String, items: [ItemRow] = [], isDeleted: Bool = false, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.items = items
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Data Store

public class DataStore: ObservableObject {
    // Published property to trigger view updates when data changes
    @Published public var lists: [MyList] = []
    
    // UserDefaults key for persistence
    private let saveKey = "savedLists"
    
    public init() {
        load()
    }
    
    // Load data from UserDefaults
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([MyList].self, from: data) {
                lists = decoded
                return
            }
        }
        lists = []
    }
    
    // Save data to UserDefaults
    public func save() {
        if let encoded = try? JSONEncoder().encode(lists) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // MARK: - CRUD Operations
    
    func addList(_ list: MyList) {
        var newList = list
        newList.createdAt = Date()
        newList.updatedAt = Date()
        lists.append(newList)
        save()
    }
    
    func updateList(_ list: MyList) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            var updatedList = list
            updatedList.updatedAt = Date()
            lists[index] = updatedList
            save()
        }
    }
    
    func deleteList(at offsets: IndexSet) {
        // This method is now deprecated in favor of softDeleteList
        // We'll keep it for backward compatibility but mark it as deprecated
        lists.remove(atOffsets: offsets)
        save()
    }
    
    func deleteList(_ list: MyList) {
        // This method is now an alias for softDeleteList for backward compatibility
        // but we'll mark it as deprecated
        softDeleteList(list)
    }
    
    // MARK: - List Item Operations
    
    func addItem(_ item: ItemRow, to list: MyList) {
        guard let index = lists.firstIndex(where: { $0.id == list.id }) else { return }
        var updatedList = lists[index]
        var newItem = item
        newItem.createdAt = Date()
        newItem.updatedAt = Date()
        updatedList.items.append(newItem)
        updatedList.updatedAt = Date()
        lists[index] = updatedList
        save()
    }
    
    func updateItem(_ item: ItemRow, in list: MyList) {
        guard let listIndex = lists.firstIndex(where: { $0.id == list.id }) else { return }
        if let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id }) {
            var updatedList = lists[listIndex]
            var updatedItem = item
            updatedItem.updatedAt = Date()
            updatedList.items[itemIndex] = updatedItem
            updatedList.updatedAt = Date()
            lists[listIndex] = updatedList
            save()
        }
    }
    
    func deleteItem(_ item: ItemRow, from list: MyList) {
        guard let index = lists.firstIndex(where: { $0.id == list.id }) else { return }
        var updatedList = lists[index]
        updatedList.items.removeAll { $0.id == item.id }
        updatedList.updatedAt = Date()
        lists[index] = updatedList
        save()
    }
    
    // MARK: - Deleted Lists Management
    
    /// Returns all non-deleted lists
    var activeLists: [MyList] {
        lists.filter { !$0.isDeleted }
    }
    
    /// Returns all deleted lists
    var deletedLists: [MyList] {
        lists.filter { $0.isDeleted }
    }
    
    /// Soft deletes a list by marking it as deleted
    func softDeleteList(_ list: MyList) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            var updatedList = lists[index]
            updatedList.isDeleted = true
            updatedList.updatedAt = Date()
            updateList(updatedList)
        }
    }
    
    /// Restores a soft-deleted list by marking it as not deleted
    func restoreList(_ list: MyList) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            var updatedList = lists[index]
            updatedList.isDeleted = false
            updatedList.updatedAt = Date()
            updateList(updatedList)
        }
    }
    
    /// Permanently deletes a list from the data store
    func permanentDelete(_ list: MyList) {
        lists.removeAll { $0.id == list.id }
        save()
    }
    
    /// Permanently deletes all soft-deleted lists
    func emptyTrash() {
        lists.removeAll { $0.isDeleted }
        save()
    }
}

// MARK: - Data Models

// All data models are now defined at the top of the file for better organization

