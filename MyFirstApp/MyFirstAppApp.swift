//
//  MyFirstAppApp.swift
//  MyFirstApp
//
//  Created by Varun Patel on 8/24/25.
//

import SwiftUI

/// The main entry point for the iSmartList application.
/// This file defines the app's structure and initializes core components.
@main
struct MyFirstAppApp: App {
    // MARK: - Properties
    
    /// The central data store for the application, managing all list and item data.
    /// Uses @StateObject to ensure the data persists for the app's entire lifecycle.
    @StateObject private var dataStore = DataStore()
    
    // MARK: - App Body
    
    var body: some Scene {
        WindowGroup {
            // The root view of the application
            ContentView()
                // Inject the data store into the environment for access throughout the app
                .environmentObject(dataStore)
        }
    }
}
