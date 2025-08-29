//
//  ProfileView.swift
//  MyFirstApp
//
//  Created by Varun Patel on 8/26/25.
//

import SwiftUI

// MARK: - Helpers

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

private func appVersionString() -> String {
    "v1.2.0 (2025.08.29.1106)"
}

#if DEBUG
let buildDateString: String = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: Date())
}()
#else
let buildDateString: String = "2025-08-29 11:06:38"
#endif

// MARK: - Model

struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

private struct AppFeature: Identifiable {
    let id = UUID()
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

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false

    private let userEmail = "vicky.patel@example.com"

    private let menuItems: [MenuItem] = [
        MenuItem(title: "User Account", icon: "person.circle", color: .blue),
        MenuItem(title: "Storage & Privacy", icon: "externaldrive", color: .purple),
        MenuItem(title: "Settings", icon: "gearshape", color: .gray),
        MenuItem(title: "About", icon: "info.circle", color: .blue),
        MenuItem(title: "Contact", icon: "envelope", color: .green)
    ]

    var body: some View {
        NavigationStack {
            Form {
                profileSection
                accountSection
                supportSection
                signOutSection
            }
            .formStyle(.grouped)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
                        .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive, action: signOut)
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Account deletion logic here
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.")
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "User Account": AccountView().environmentObject(dataStore)
                case "Storage & Privacy": StorageViewScreen().environmentObject(dataStore)
                case "Settings": SettingsViewScreen().environmentObject(dataStore)
                case "About": AboutView()
                case "Contact": ContactView()
                default: EmptyView()
                }
            }
        }
    }

    // MARK: - Sections

    private var profileSection: some View {
        Section("Profile") {
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.accentColor)
                    .accessibility(hidden: true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(dataStore.userName)
                        .font(.title3.weight(.semibold))
                        .accessibilityLabel("User name: \(dataStore.userName)")
                    Text(userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Email: \(userEmail)")
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }

    private var accountSection: some View {
        Section("Account") {
            NavigationLink(value: menuItems[0].title) {
                Label(menuItems[0].title, systemImage: menuItems[0].icon)
                    .foregroundColor(menuItems[0].color)
                    .font(.callout.weight(.medium))
            }
        }
    }

    private var supportSection: some View {
        Section("Support") {
            ForEach(menuItems.dropFirst(1)) { item in
                NavigationLink(value: item.title) {
                    Label(item.title, systemImage: item.icon)
                        .foregroundColor(item.color)
                        .font(.callout.weight(.medium))
                }
            }
        }
    }

    private var signOutSection: some View {
        Section {
            Button(role: .destructive) {
                showLogoutAlert = true
            } label: {
                HStack {
                    Spacer()
                    Text("Sign Out")
                        .font(.callout.weight(.semibold))
                    Spacer()
                }
            }
            .accessibilityHint("Sign out of your account")
        }
    }

    // MARK: - Actions

    private func signOut() {
        // Implement sign-out logic
    }
}

// MARK: - AccountView

private struct AccountView: View {
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showDeleteAccountAlert = false
    private let userEmail = "vicky.patel@example.com"

    var body: some View {
        Form {
            Section {
                HStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundColor(.accentColor)
                        .accessibility(hidden: true)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(dataStore.userName)
                            .font(.title2.weight(.semibold))
                        Text(userEmail)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            Section {
                Button(role: .destructive) {
                    showDeleteAccountAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete Account")
                            .font(.callout.weight(.semibold))
                        Spacer()
                    }
                }
                .accessibilityHint("Delete your account and all data")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("User Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                // Account deletion logic here
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.")
        }
    }
}

// MARK: - StorageViewScreen

private struct StorageViewScreen: View {
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showDeleteAllDataAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Storage & Privacy")
                    .font(.largeTitle.weight(.bold))
                    .accessibilityAddTraits(.isHeader)

                Label {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("All your lists and items are securely stored **only on this device** using Apple's UserDefaults.")
                        Text("Your data is never uploaded, tracked, or shared. You control your information at all times.")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                } icon: {
                    Image(systemName: "lock.shield")
                        .foregroundColor(.accentColor)
                        .font(.title3)
                }
                .accessibilityElement(children: .combine)

                Divider()

                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 48) {
                        VStack(alignment: .leading) {
                            Text("Lists")
                                .font(.subheadline.weight(.medium))
                            Text("\(dataStore.lists.count)")
                                .font(.title3.weight(.bold))
                        }
                        VStack(alignment: .leading) {
                            let totalItems = dataStore.lists.reduce(0) { $0 + $1.items.count }
                            Text("Items")
                                .font(.subheadline.weight(.medium))
                            Text("\(totalItems)")
                                .font(.title3.weight(.bold))
                        }
                    }

                    let storageBytes: Int = {
                        if let data = try? JSONEncoder().encode(dataStore.lists) {
                            return data.count
                        }
                        return 0
                    }()
                    let storageMB = Double(storageBytes) / (1024 * 1024)

                    StorageItemView(
                        icon: "externaldrive",
                        title: "App Data (est.)",
                        size: String(format: "%.2f MB", storageMB),
                        percentage: min(max(storageMB / 5.0, 0.02), 1.0)
                    )
                }

                Divider()

                Text("You can Erase All Data by using button below. This action cannot be undone.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                    .padding(.top, 20)

                Section {
                    Button(role: .destructive) {
                        showDeleteAllDataAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete All Data")
                                .font(.callout.weight(.semibold))
                            Spacer()
                        }
                    }
                    .accessibilityHint("Delete all lists, items, and user data from this device")
                }

                Spacer(minLength: 0)
            }
            .padding()
        }
        .navigationTitle("Storage & Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete All Data", isPresented: $showDeleteAllDataAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                dataStore.lists.removeAll()
                dataStore.save()
            }
        } message: {
            Text("Are you sure you want to delete all your lists and items? This cannot be undone. All your data will be erased from this device.")
        }
    }
}

// MARK: - AboutView

private struct AboutView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var showVersionSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("About: MyFirstApp")
                    .font(.largeTitle.weight(.bold))
                    .accessibilityAddTraits(.isHeader)

                Text("MyFirstApp helps you manage shopping and to-do lists efficiently, so you never forget anything important again.")
                    .font(.body)

                VStack(spacing: 8) {
                    Divider()
                        .padding(.vertical, 8)

                    Button {
                        showVersionSheet = true
                    } label: {
                        HStack {
                            Text("Version")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(appVersionString())
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Show App Version Information, current version \(appVersionString())")
                }
                .padding(.top, 20)

                Divider()

                Text("Core Features")
                    .font(.headline)
                    .padding(.vertical, 2)

                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 1)
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(featureList) { feature in
                            HStack(spacing: 14) {
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

                Divider()
                    .padding(.vertical, 4)

                Spacer(minLength: 10)

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
                                .font(.body.weight(.semibold))
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
        .sheet(isPresented: $showVersionSheet) {
            VersionInfoSheet()
        }
    }
}

// MARK: - ContactView

private struct ContactView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Form {
            Section("Contact") {
                Text("We value your feedback and questions! Our team aims to respond to all email support requests within 1–2 business days. If your message is urgent, please include 'URGENT' in the subject line. Thank you for helping us improve MyFirstApp.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 14)
                
                ProfileInfoRow(icon: "envelope", title: "Email Support")
                ProfileInfoRow(icon: "link", title: "Website")
            }
            Section(footer: VStack(alignment: .leading, spacing: 4) {
                Divider()
                Text("Developer")
                    .font(.headline)
                    .padding(.top, 2)
                HStack(spacing: 10) {
                    Image(systemName: "person.circle")
                        .foregroundColor(.accentColor)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Varun Patel")
                            .font(.body.weight(.semibold))
                        Text("iOS Engineer & Creator")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Email: vicky.patel@example.com")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 2)
            }) { EmptyView() }
        }
        .formStyle(.grouped)
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

private struct ProfileInfoRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .font(.body)
            Text(title)
                .font(.callout)
            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - SettingsViewScreen

private struct SettingsViewScreen: View {
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Form {
            Section(header: Text("Settings")) {
                Label("App Preferences", systemImage: "slider.horizontal.3")
                Label("Notifications", systemImage: "bell")
                Label("Appearance", systemImage: "paintbrush")
            }
            Section(footer: Text("More settings coming soon...").foregroundColor(.secondary)) {
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
     
    }
}

// MARK: - VersionInfoSheet

struct VersionInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

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
                        .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(DataStore())
    }
}

