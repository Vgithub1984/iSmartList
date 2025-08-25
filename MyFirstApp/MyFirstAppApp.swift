//
//  MyFirstAppApp.swift
//  MyFirstApp
//
//  Created by Varun Patel on 8/24/25.
//

import SwiftUI

@main
struct MyFirstAppApp: App {
    // Initialize the DataStore as a StateObject to ensure it persists for the app's lifetime
    @StateObject private var dataStore = DataStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore) // Make DataStore available throughout the app
        }
    }
}
