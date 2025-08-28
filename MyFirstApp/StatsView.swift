//
//  StatsView.swift
//  MyFirstApp
//
//  Created by Varun Patel on 8/26/25.
//
//  This file contains the statistics view that displays various metrics
//  and analytics about the user's lists and tasks.

import SwiftUI

/// A view that displays statistics and analytics about the user's lists and tasks.
///
/// This view shows various metrics including completion rates, task counts, and recent activity.
/// It automatically updates when the underlying data changes.
struct StatsView: View {
    // MARK: - Environment
    
    /// The shared data store containing all lists and items.
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Computed Properties
    
    /// The total number of active (non-deleted) lists.
    private var totalLists: Int {
        dataStore.totalListsCount
    }
    
    /// The total number of completed tasks across all lists.
    private var completedTasks: Int {
        dataStore.lists.flatMap { $0.items }.filter { $0.isCompleted }.count
    }
    
    /// The total number of tasks (both completed and pending) across all lists.
    private var totalTasks: Int {
        dataStore.lists.flatMap { $0.items }.count
    }
    
    /// The completion rate of all tasks as a value between 0.0 and 1.0.
    /// Returns 0 if there are no tasks.
    private var completionRate: Double {
        totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0
    }
    
    /// The most recently updated list, or nil if no lists exist.
    private var mostRecentList: MyList? {
        dataStore.lists.filter { !$0.isDeleted }.max(by: { $0.updatedAt < $1.updatedAt })
    }
    
    /// The list with the most items and its item count, or nil if no lists exist.
    /// - Returns: A tuple containing the most active list and its item count.
    private var mostActiveList: (MyList, Int)? {
        let activeLists = dataStore.lists
            .filter { !$0.isDeleted }
            .map { ($0, $0.items.count) }
            .max(by: { $0.1 < $1.1 })
        return activeLists
    }
    
    /// The total number of lists including deleted ones.
    private var totalListsInclusive: Int {
        dataStore.lists.count
    }
    
    /// The number of zero item lists (not deleted).
    private var zeroItemLists: Int {
        dataStore.zeroItemListsCount
    }
    
    /// The number of active lists (not deleted) with >0 items and not all items purchased.
    private var activeLists: Int {
        dataStore.activeListsCount
    }
    
    /// The number of completed lists (not deleted) with >0 items and all items purchased.
    private var completedLists: Int {
        dataStore.completedListsCount
    }
    
    /// The number of deleted lists.
    private var deletedLists: Int {
        dataStore.deletedListsCount
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                    
                    // MARK: - Total Lists Section
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .center, spacing: 8) {
                            HStack(spacing: 10) {
                                Spacer()
                                Text("\(totalListsInclusive) Total Lists")
                                    .font(.title2.bold())
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    
                    
                    // MARK: - Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        StatCard(
                            title: "Zero Item Lists",
                            value: "\(zeroItemLists)",
                            icon: "list.number.badge.ellipsis",
                            color: .gray
                        )
                        
                        StatCard(
                            title: "Active Lists",
                            value: "\(activeLists)",
                            icon: "cart.fill",
                            color: .accentColor
                        )
                        
                        StatCard(
                            title: "Completed Lists",
                            value: "\(completedLists)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Deleted Lists",
                            value: "\(deletedLists)",
                            icon: "trash",
                            color: .red
                        )
                        
                        
                    }
                    .padding(.horizontal)
                    
                    
                    // MARK: - Total Lists Section
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .center, spacing: 8) {
                            HStack {
                                Text("\(completedTasks) of \(totalTasks) Items Purchased in total.")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int(completionRate * 100))%")
                                    .font(.title3.bold())
                                    .foregroundColor(.accentColor)
                            }
                            ProgressView(value: completionRate)
                                .tint(.accentColor)
                                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    
                  
                    Spacer()
                    
                    // MARK: - Recent Activity
                    if let recentList = mostRecentList {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recently Updated")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recentList.name)
                                        .font(.headline)
                                    
                                    if !recentList.items.isEmpty {
                                        Text("\(recentList.items.filter { $0.isCompleted }.count) of \(recentList.items.count) completed")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("Updated \(recentList.updatedAt.formatted(.relative(presentation: .named)))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Empty State
                    if dataStore.lists.isEmpty {
                        ContentUnavailableView(
                            "No Data Yet",
                            systemImage: "chart.bar.xaxis",
                            description: Text("Create your first list to see statistics")
                        )
                        .padding(.top, 40)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                // Refresh data if needed
            }
        }
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarBackground(Color.toolbarColor(for: colorScheme), for: .navigationBar)
    }
}

// MARK: - StatCard View

/// A reusable card component for displaying a single statistic with an icon.
///
/// This view presents a statistic in a visually appealing card with an icon,
/// value, and optional subtitle. It's used throughout the StatsView to display
/// various metrics in a consistent way.
private struct StatCard: View {
    // MARK: - Properties
    
    /// The title or label for the statistic (e.g., "Total Lists").
    let title: String
    
    /// The main value to display (e.g., "5" or "75%").
    let value: String
    
    /// An optional subtitle providing additional context.
    var subtitle: String? = nil
    
    /// The SF Symbol name for the icon.
    let icon: String
    
    /// The tint color for the icon and other accent elements.
    let color: Color
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .imageScale(.large)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Previews

#Preview("With Data") {
    let dataStore = DataStore()
    
    // Sample data for preview
    let sampleList1 = MyList(
        name: "Grocery List",
        items: [
            ItemRow(name: "Milk", isCompleted: true),
            ItemRow(name: "Eggs", isCompleted: true),
            ItemRow(name: "Bread", isCompleted: false)
        ],
        isDeleted: false,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    let sampleList2 = MyList(
        name: "Work Tasks",
        items: [
            ItemRow(name: "Finish report", isCompleted: true),
            ItemRow(name: "Team meeting", isCompleted: false),
            ItemRow(name: "Review PRs", isCompleted: false),
            ItemRow(name: "Update project plan", isCompleted: true)
        ],
        isDeleted: false,
        createdAt: Date().addingTimeInterval(-86400),
        updatedAt: Date().addingTimeInterval(-3600)
    )
    
    dataStore.lists = [sampleList1, sampleList2]
    
    return NavigationStack {
        StatsView()
            .environmentObject(dataStore)
    }
}

#Preview("Empty State") {
    NavigationStack {
        StatsView()
            .environmentObject(DataStore())
    }
}

