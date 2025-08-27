//
//  ContentView.swift
//  MyFirstApp
//
//  Created by Varun Patel on 8/24/25.
//

// Model and DataStore have been moved to Models/MyList.swift and ViewModels/DataStore.swift respectively.

import SwiftUI
import SwiftData

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
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
    @State private var showingNewListDialog = false
    @State private var newListName = ""
    @State private var showingListsDeleteAllDialog = false
    @FocusState private var isTextFieldFocused: Bool
    
    // MARK: - Body
    
    // MARK: - Helper Views
    
    private var addButton: some View {
        Button(action: {
            newListName = ""
            showingNewListDialog = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(.black)
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Circle())
        .frame(width: 56, height: 56)
        .padding(.trailing, 45)
        .padding(.bottom, 70)
        .transition(.scale)
        .zIndex(1) // Ensure it's above the tab bar
    }
    
    
    private var listsTab: some View {
        NavigationStack {
            ListsView(isShowingListDetail: $isShowingListDetail)
                .onChange(of: selectedTab) { _ in
                    isShowingListDetail = false
                }
                .toolbar(selectedTab == 0 && isShowingListDetail ? .hidden : .visible, for: .tabBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if !dataStore.lists.filter({ !$0.isDeleted }).isEmpty {
                            Button(role: .destructive) {
                                showingListsDeleteAllDialog = true
                            } label: {
                                Text("Delete All")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .confirmationDialog("Delete All Lists?", 
                                 isPresented: $showingListsDeleteAllDialog, 
                                 titleVisibility: .visible) {
                    Button("Delete All", role: .destructive) {
                        deleteAllLists()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to move all your lists to Deleted? This can be undone from the Deleted tab.")
                }
        }
    }
    
    private func deleteAllLists() {
        for var list in dataStore.lists {
            list.isDeleted = true
            list.updatedAt = Date()
            dataStore.updateList(list)
        }
    }
    
    private var deletedTab: some View {
        NavigationStack {
            DeletedView()
        }
    }
    
    private var statsTab: some View {
        NavigationStack {
            Text("Stats View")
                .font(.title)
        }
    }
    
    private var profileTab: some View {
        NavigationStack {
            ProfileView()
        }
    }
    
    private func tabLabel(title: String, systemImage: String, tag: Int) -> some View {
        Label {
            Text(title)
                .foregroundStyle(selectedTab == tag ? .primary : .secondary)
                .fontWeight(selectedTab == tag ? .bold : .regular)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(selectedTab == tag ? .primary : .secondary)
                .fontWeight(selectedTab == tag ? .bold : .regular)
        }
    }
    
    private var newListAlert: some View {
        ZStack {
            // Blurred background that dismisses the alert when tapped
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        showingNewListDialog = false
                    }
                }
            
            VStack(spacing: 20) {
                Text("Create New List")
                    .font(.headline)
                    .padding(.top)
                
                TextField("Enter List Name", text: $newListName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .focused($isTextFieldFocused)
                    .onAppear {
                        // Focus the text field when the alert appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isTextFieldFocused = true
                        }
                    }
                
                HStack(spacing: 20) {
                    Button("Cancel") {
                        withAnimation {
                            showingNewListDialog = false
                        }
                    }
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    Button("Create") {
                        if !newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let newList = MyList(name: newListName.trimmingCharacters(in: .whitespacesAndNewlines))
                            dataStore.addList(newList)
                            newListName = ""
                        }
                        withAnimation {
                            showingNewListDialog = false
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(width: 300)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 10)
            .transition(.scale)
            .zIndex(1) // Ensure it's above the tab bar
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Main View
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main content
            TabView(selection: $selectedTab) {
                listsTab
                    .tabItem { tabLabel(title: "Lists", systemImage: "list.bullet", tag: 0) }
                    .tag(0)
                    .badge(dataStore.lists.filter { !$0.isDeleted }.count)
                
                deletedTab
                    .tabItem { tabLabel(title: "Deleted", systemImage: "trash", tag: 1) }
                    .tag(1)
                    .badge(dataStore.lists.filter { $0.isDeleted }.count)
                
                statsTab
                    .tabItem { tabLabel(title: "Stats", systemImage: "chart.bar.xaxis", tag: 2) }
                    .tag(2)
                
                profileTab
                    .tabItem { tabLabel(title: "Profile", systemImage: "person.crop.circle", tag: 3) }
                    .tag(3)
            }
            
            // Floating action button
            if selectedTab == 0 && !isShowingListDetail {
                addButton
            }
            
            // Custom alert overlay
            if showingNewListDialog {
                newListAlert
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}


// MARK: - Preview

#Preview {
    let dataStore = DataStore()
    // Add some sample data for preview
    let sampleList = MyList(
        name: "Grocery List",
        items: [
            ItemRow(name: "Milk", isCompleted: false, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date())
        ],
        isDeleted: false,
        createdAt: Date(),
        updatedAt: Date()
    )
    dataStore.lists = [sampleList]
    
    return ContentView()
        .environmentObject(dataStore)
}

