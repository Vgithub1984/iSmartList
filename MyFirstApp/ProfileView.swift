import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

struct ProfileView: View {
    @State private var userName: String = "John Doe"
    @State private var userEmail: String = "john.doe@example.com"
    @EnvironmentObject private var dataStore: DataStore
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var showLogoutAlert = false
    
    private let menuItems: [(item: MenuItem, color: Color)] = [
        (MenuItem(title: "Account", icon: "person.circle"), .blue),
        (MenuItem(title: "Settings", icon: "gearshape"), .green),
        (MenuItem(title: "Notifications", icon: "bell"), .orange),
        (MenuItem(title: "Storage", icon: "externaldrive"), .purple),
        (MenuItem(title: "About Me", icon: "info.circle"), .pink),
        (MenuItem(title: "Contact Us", icon: "envelope"), .teal)
    ]
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func menuItemDestination(for item: MenuItem) -> some View {
        switch item.title {
        case "Account":
            Form {
                Section(header: Text("Profile Information")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(userName)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(userEmail)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Member Since")
                        Spacer()
                        Text("January 2025")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                    Toggle(isOn: $notificationsEnabled) {
                        VStack(alignment: .leading) {
                            Text("Notifications")
                            Text("Receive app notifications")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Account")
            
        case "Settings":
            Form {
                Section(header: Text("Display")) {
                    NavigationLink(destination: Text("Theme Settings")) {
                        Text("Theme")
                    }
                    NavigationLink(destination: Text("Font Settings")) {
                        Text("Font Size")
                    }
                }
                
                Section(header: Text("Data")) {
                    NavigationLink(destination: Text("Export Data")) {
                        Text("Export Lists")
                    }
                    NavigationLink(destination: Text("Import Data")) {
                        Text("Import Lists")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        // Reset settings
                    } label: {
                        Text("Reset to Defaults")
                    }
                }
            }
            .navigationTitle("Settings")
            
        case "Notifications":
            Form {
                Toggle("Push Notifications", isOn: $notificationsEnabled)
                
                if notificationsEnabled {
                    Section(header: Text("Notification Types")) {
                        Toggle("New List Created", isOn: .constant(true))
                        Toggle("List Reminders", isOn: .constant(true))
                        Toggle("App Updates", isOn: .constant(true))
                        Toggle("Promotions", isOn: .constant(false))
                    }
                    
                    Section(header: Text("Notification Sound")) {
                        Picker("Sound", selection: .constant("Default")) {
                            Text("Default").tag("Default")
                            Text("Chime").tag("Chime")
                            Text("Note").tag("Note")
                            Text("Bell").tag("Bell")
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            
        case "Storage":
            VStack(spacing: 20) {
                // Storage usage visualization
                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: 0.35) // 35% used
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.accentColor)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.easeInOut, value: 0.35)
                    
                    VStack {
                        Text("1.2")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("GB used")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 180, height: 180)
                .padding(.top, 30)
                
                VStack(spacing: 15) {
                    StorageItemView(icon: "list.bullet", title: "Shopping Lists", size: "850 MB", percentage: 0.7)
                    StorageItemView(icon: "photo", title: "Images", size: "250 MB", percentage: 0.2)
                    StorageItemView(icon: "doc.text", title: "Documents", size: "100 MB", percentage: 0.1)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    // Clear cache
                }) {
                    Text("Clear Cache")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Storage")
            
        case "About Me":
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "app.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                        .padding(.top, 30)
                    
                    Text("iSmartList")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(icon: "doc.text", title: "Terms of Service")
                        InfoRow(icon: "hand.raised", title: "Privacy Policy")
                        InfoRow(icon: "questionmark.circle", title: "Help & Support")
                        InfoRow(icon: "star", title: "Rate This App")
                        InfoRow(icon: "arrow.uturn.left", title: "Version History")
                    }
                    .padding(.top, 20)
                    
                    Text("© 2025 iSmartList. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                }
                .padding()
            }
            .navigationTitle("About")
            
        case "Contact Us":
            Form {
                Section(header: Text("Get in Touch")) {
                    Link(destination: URL(string: "mailto:support@ismartlist.app")!) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            Text("Email Us")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Link(destination: URL(string: "https://twitter.com/ismartlist")!) {
                        HStack {
                            Image(systemName: "bubble.left")
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            Text("Twitter")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                Section(header: Text("Feedback")) {
                    NavigationLink(destination: Text("Feedback Form")) {
                        Text("Send Feedback")
                    }
                    
                    NavigationLink(destination: Text("Report an Issue")) {
                        Text("Report a Problem")
                    }
                }
                
                Section(header: Text("Follow Us")) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.accentColor)
                            .frame(width: 30)
                        Link("Visit Our Website", destination: URL(string: "https://ismartlist.app")!)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Contact Us")
            
        default:
            Text("Coming Soon")
                .navigationTitle(item.title)
        }
    }
    
    var body: some View {
        List {
            // Profile Section
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentColor)
                        .padding(.top, 8)
                    
                    Text(userName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color(.systemBackground))
                .padding(.vertical, 8)
            }
            
            // Stats Section
            Section("STATISTICS") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(dataStore.lists.count)")
                            .font(.headline)
                        Text("Active Lists")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(dataStore.deletedLists.count)")
                            .font(.headline)
                        Text("Deleted")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)
            }
            
            // Menu Section
            Section("PREFERENCES") {
                ForEach(menuItems, id: \.item.id) { menuItem in
                    NavigationLink(destination: menuItemDestination(for: menuItem.item)) {
                        HStack(spacing: 12) {
                            Image(systemName: menuItem.item.icon)
                                .frame(width: 24, height: 24)
                                .foregroundColor(menuItem.color)
                            
                            Text(menuItem.item.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            
            // Sign Out Button
            Section {
                Button(role: .destructive) {
                    // Handle sign out
                } label: {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.red)
                }
            }
            .listRowBackground(Color(.systemBackground))
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Profile")
    }
}

// MARK: - Helper Views

struct StorageItemView: View {
    let icon: String
    let title: String
    let size: String
    let percentage: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                
                Spacer()
                
                Text(size)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 4)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(percentage) * geometry.size.width, geometry.size.width), height: 4)
                        .foregroundColor(.accentColor)
                        .animation(.linear, value: percentage)
                }
                .cornerRadius(2)
            }
            .frame(height: 4)
        }
        .padding(.vertical, 6)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(DataStore())
    }
}
