//
//  ProfileView.swift
//  MyFirstApp
//
//  Created by Varun Patel on 8/26/25.
//
//  This file implements the user profile screen, which provides access to:
//  - User account information and preferences
//  - App settings and configurations
//  - Notifications management
//  - Storage usage and management
//  - App information and support options
//  - Contact and feedback functionality

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

/// A container that only enables scrolling if its content exceeds the available space.
struct ScrollableIfNeeded<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var contentHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0
    var body: some View {
        GeometryReader { containerProxy in
            ZStack {
                Color.clear
                content
                    .background(
                        GeometryReader { contentProxy in
                            Color.clear
                                .onAppear {
                                    contentHeight = contentProxy.size.height
                                    containerHeight = containerProxy.size.height
                                }
                                .onChange(of: contentProxy.size.height) { newValue in
                                    contentHeight = newValue
                                }
                        }
                    )
                    .frame(width: containerProxy.size.width)
            }
            .onAppear {
                containerHeight = containerProxy.size.height
            }
            .onChange(of: containerProxy.size.height) { newValue in
                containerHeight = newValue
            }
            .if(contentHeight > containerHeight) { view in
                ScrollView { view }
            }
        }
    }
}

private func appVersionString() -> String {
    return "v1.1.1 (1)" // Manually set to match documentation
}

#if DEBUG
let buildDateString: String = { () -> String in
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: Date())
}()
#else
let buildDateString: String = "2025-08-27 16:58:00" // Build date
#endif

// MARK: - MenuItem Model

/// Represents a menu item in the profile view.
/// - `id`: A unique identifier for the menu item.
/// - `title`: The display text for the menu item.
/// - `icon`: The SF Symbol name for the menu item's icon.
/// - `color`: The color associated with the menu item.
struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

// MARK: - AppFeature Model and List for About View

private struct AppFeature: Identifiable {
    var id = UUID()
    let icon: String
    let title: String
    let color: Color
}
private let featureList = [
    AppFeature(icon: "list.bullet", title: "Create unlimited lists for any purpose", color: .accentColor),
    AppFeature(icon: "checkmark.circle", title: "Add, check off, and remove individual items", color: .green),
    AppFeature(icon: "trash", title: "Soft-delete and restore lists from Trash", color: .orange),
    AppFeature(icon: "chart.bar", title: "Track completion progress for each list", color: .blue),
    AppFeature(icon: "chart.pie", title: "Organize with helpful stats and analytics", color: .purple)
]

// MARK: - ProfileView

/// A view that displays the user's profile and app settings.
///
/// This view serves as the central hub for user account management and app configuration.
/// It provides navigation to various settings and information screens.
struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataStore: DataStore
    // MARK: - State Properties
    
    @State private var selectedMenuItem: MenuItem?
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showVersionSheet = false
    
    private let userEmail = "vicky.patel@example.com"
    
    /// Menu items for the profile view
    private let menuItems: [MenuItem] = [
        MenuItem(title: "Storage & Privacy", icon: "externaldrive", color: .purple),
        MenuItem(title: "About", icon: "info.circle", color: .blue),
        MenuItem(title: "Contact", icon: "envelope", color: .green)
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.accentColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if isEditingName {
                                TextField("Your Name", text: $editedName, onCommit: saveName)
                                    .font(.headline)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: 200)
                            } else {
                                Text(dataStore.userName)
                                    .font(.headline)
                                    .onTapGesture {
                                        startEditingName()
                                    }
                            }
                            
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Account") {
                    NavigationLink(value: MenuItem(title: "User Account", icon: "person.circle", color: .blue)) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            Text("User Account")
                        }
                    }
                }
                
                Section("Support") {
                    ForEach(menuItems) { item in
                        NavigationLink(value: item) {
                            HStack(spacing: 12) {
                                Image(systemName: item.icon)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(item.color)
                                Text(item.title)
                            }
                        }
                    }
                }
                
                Section("Sign Out") {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                            Spacer()
                        }
                    }
                }
             
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarBackground(Color.purple.opacity(0.5), for: .navigationBar)
            .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) { signOut() }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Handle account deletion
                    // This would typically involve calling an API or service
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.")
            }
            .navigationDestination(for: MenuItem.self) { item in
                destinationView(for: item)
            }
            .sheet(isPresented: $showVersionSheet) {
                VersionInfoSheet()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func startEditingName() {
        editedName = dataStore.userName
        isEditingName = true
    }
    
    private func saveName() {
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            dataStore.updateUserName(trimmedName)
        }
        isEditingName = false
    }
    
    // MARK: - Navigation Destinations
    @ViewBuilder
    private func destinationView(for item: MenuItem) -> some View {
        switch item.title {
        case "User Account", "Account":
            accountView
        case "Storage & Privacy":
            storageView
        case "About":
            aboutView
        case "Contact":
            contactView
        default:
            EmptyView()
        }
    }
    
    // MARK: - Destination Views
    private var accountView: some View {
        Form {
            Section(header: Text("Profile")) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading) {
                        Text(dataStore.userName)
                            .font(.headline)
                        Text(userEmail)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("User Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarBackground(Color.purple.opacity(0.2), for: .navigationBar)
    }
    
    private var storageView: some View {
        StorageViewScreen()
            .environmentObject(dataStore)
    }
    
    private var aboutView: some View {
        ScrollableIfNeeded {
            VStack(alignment: .leading, spacing: 16) {
                Text("MyFirstApp helps you manage shopping and to-do lists efficiently, so you never forget anything important again.")
                    .font(.body)
                
                // Version information at the bottom
                VStack(spacing: 8) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    Button(action: { showVersionSheet = true }) {
                        HStack {
                            Text("Version")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(appVersionString())
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 20)
                Divider()
                
                Text("Core Features")
                    .font(.headline)
                    .padding(.top)
                    .padding(.bottom, 2)
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 1)
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(featureList) { feature in
                            HStack(alignment: .center, spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(feature.color.opacity(0.18))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: feature.icon)
                                        .foregroundColor(feature.color)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                Text(feature.title)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
                
                Divider()
                Text("MyFirstApp is designed to be simple, secure, and privacy-friendly. All your data stays on your device.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider().padding(.vertical, 4)
                
                Spacer(minLength: 10)
                
                // Developer Section pinned near the bottom
                VStack(alignment: .leading, spacing: 8) {
                    Text("Developer")
                        .font(.headline)
                        .padding(.bottom, 2)
                    HStack(spacing: 10) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.accentColor)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Varun Patel")
                                .font(.body)
                                .fontWeight(.semibold)
                            Text("iOS Engineer & Creator")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarBackground(Color.purple.opacity(0.2), for: .navigationBar)
    }
    
    struct StorageViewScreen: View {
        @EnvironmentObject private var dataStore: DataStore
        var body: some View {
            ScrollableIfNeeded {
                VStack(alignment: .leading, spacing: 24) {
                    // Privacy Statement
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("All your lists and items are securely stored **only on this device** using Apple's UserDefaults. ")
                            Text("Your data is never uploaded, tracked, or shared. You control your information at all times.")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    } icon: {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.accentColor)
                    }
                    Divider()
                    
                    // Data Usage Stats
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 28) {
                            VStack(alignment: .leading) {
                                Text("Lists")
                                    .font(.subheadline)
                                Text("\(dataStore.lists.count)")
                                    .font(.title3.bold())
                            }
                            VStack(alignment: .leading) {
                                let totalItems = dataStore.lists.map { $0.items.count }.reduce(0, +)
                                Text("Items")
                                    .font(.subheadline)
                                Text("\(totalItems)")
                                    .font(.title3.bold())
                            }
                        }
                        
                        // Storage estimate
                        let storageBytes: Int = {
                            if let data = try? JSONEncoder().encode(dataStore.lists) {
                                return data.count
                            } else {
                                return 0
                            }
                        }()
                        let storageMB = Double(storageBytes) / (1024 * 1024)
                        
                        StorageItemView(
                            icon: "externaldrive",
                            title: "App Data (est.)",
                            size: String(format: "%.2f MB", storageMB),
                            percentage: min(max(storageMB / 5.0, 0.02), 1.0) // Assume 5 MB max for progress demo
                        )
                    }
                    
                    Divider()
                    Text("You can erase all data by deleting the app or using the options in Settings.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Storage & Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarBackground(Color.purple.opacity(0.2), for: .navigationBar)
            
        }
    }
    
    private var contactView: some View {
        Form {
            Section("Contact") {
                ProfileInfoRow(icon: "envelope", title: "Email Support")
                ProfileInfoRow(icon: "link", title: "Website")
            }
        }
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarBackground(Color.purple.opacity(0.2), for: .navigationBar)
    }
    
    // MARK: - Sign Out
    private func signOut() {
        // Handle sign out
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
                .environmentObject(DataStore())
        }
    }
}

struct VersionInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Label {
                            Text("Version: \(appVersionString())")
                                .font(.body)
                        } icon: {
                            Image(systemName: "number")
                                .foregroundColor(.accentColor)
                        }
                        
                        Label {
                            Text("Build Date: \(buildDateString)")
                                .font(.body)
                        } icon: {
                            Image(systemName: "calendar")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Label {
                        Text("Built from GitHub \"main\" branch. This version matches the public repo.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                    }
                }
                
                Section {
                    Text("© \(Calendar.current.component(.year, from: Date())) MyFirstApp")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Version Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarBackground(Color.purple.opacity(0.2), for: .navigationBar)
            
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.accentColor)
            Text(title)
            Spacer()
        }
        .padding(.vertical, 3)
    }
}
