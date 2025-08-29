//
//  ListDetailView.swift
//  MyFirstApp
//
//  This file implements the detailed view for a single shopping list.
//  It provides a complete interface for managing list items and tracking progress.
//
//  Key Features:
//  - Displays all items in a scrollable list
//  - Tracks and visualizes completion progress
//  - Supports adding, editing, and removing items
//  - Prevents duplicate items
//  - Auto-saves changes to DataStore
//  - Responsive design for all device sizes

import SwiftUI
import Combine
import Speech
import UIKit

/// Displays and manages the contents of a single shopping list with full CRUD operations.
///
/// This view provides a detailed interface for interacting with a shopping list, including:
/// - Viewing all items with their completion status
/// - Adding new items with duplicate prevention
/// - Toggling item completion
/// - Deleting items
/// - Tracking overall list completion progress
///
/// - Note: Automatically persists changes to the shared `DataStore` for data persistence.
struct ListDetailView: View {
    // MARK: - Environment
    
    /// The shared data store containing all lists and their items.
    /// Automatically updates the view when the data changes.
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar showing completion status
            progressBarView
            
            // Main content area
            if list.items.isEmpty {
                emptyStateView
            } else {
                itemsListView
            }
            
            // Input area
            inputRowView
            
            // Show transcript when listening
            if speechRecognizer.isListening {
                transcriptView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            Group {
                if showAlert {
                    VStack(spacing: 12) {
                        Image(systemName: alertIcon)
                            .font(.system(size: 28))
                            .foregroundColor(alertColor)
                            .shadow(color: Color.primary.opacity(0.1), radius: 2, x: 0, y: 1)
                        Text(alertMessage)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(24)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                        }
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground).opacity(0.9))
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .frame(maxWidth: 300)
                    .onTapGesture {
                        withAnimation {
                            showAlert = false
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primary.opacity(showAlert ? 0.1 : 0))
            .edgesIgnoringSafeArea(.all)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showAlert)
            .onTapGesture {
                withAnimation {
                    showAlert = false
                }
            },
            alignment: .center
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(list.name)
                        .font(.headline)
                    Text(list.updatedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            // Removed onWordFinalized closure as per instructions
        }
    }
    
    // MARK: - Properties
    
    /// Binding to the current list being viewed/edited.
    /// Updates both locally and in the data store when modified.
    @Binding var list: MyList
    
    /// Environment value to dismiss the current view when needed.
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    /// The current text input for adding new items.
    @State private var inputText: String = ""
    
    /// Controls the keyboard focus state of the text input field.
    @FocusState private var isInputFocused: Bool
    
    /// Speech recognizer object managing speech-to-text input.
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    /// Tracks whether the user has attempted to start speech recognition
    @State private var userAttemptedSpeech = false
    
    /// Stores the name of the last added item to display in the popup
    @State private var lastAddedItemName = ""
    
    /// Tracks the last processed segment index of the speech transcript for incremental processing
    @State private var lastProcessedSegmentIndex: Int = -1
    
    /// Stores the last full transcript to detect new words only
    @State private var lastTranscript: String = ""
    
    @State private var isProcessingSpeech: Bool = false
    @State private var isListening: Bool = false
    @State private var lastItemAddedTime: Date = .distantPast
    @State private var lastTranscriptUpdate: Date = .distantPast
    @State private var isProcessingFinal: Bool = false
    
    /// Controls the visibility of the duplicate alert popup
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertIcon = ""
    @State private var alertColor = Color.blue
    @State private var duplicateItemName = ""
    @State private var micPulse: Bool = false
    
    /// Tracks whether the last duplicate was from manual input (text field) or speech
    @State private var lastDuplicateWasManual = false
    
    // MARK: - Autocorrect Mapping
    
    /// Dictionary for autocorrecting common misrecognized words.
    private let autocorrectMapping: [String: String] = [
        "tooth paste": "Toothpaste",
        "toothpaste": "Toothpaste",
        "tooth pastes": "Toothpaste",
        "toothpastes": "Toothpaste",
        "toothpast": "Toothpaste",
        "lotion": "Lotion",
        "shampoo": "Shampoo",
        "soap": "Soap",
        "egg": "Eggs",
        "eggs": "Eggs"
    ]
    
    // MARK: - Computed Properties
    
    /// The number of completed items in the list.
    private var purchasedCount: Int { list.items.filter { $0.isCompleted }.count }
    
    /// The total number of items in the list.
    private var totalCount: Int { list.items.count }
    
    /// The completion progress of the list, ranging from 0.0 to 1.0.
    /// Returns 0.0 if the list is empty.
    private var progress: Double {
        totalCount == 0 ? 0.0 : Double(purchasedCount) / Double(totalCount)
    }
    
    // MARK: - Initialization
    
    /// Creates a new instance of the list detail view.
    /// - Parameter list: A binding to the `MyList` object to be displayed and edited.
    init(list: Binding<MyList>) {
        self._list = list
    }
    
    // MARK: - Private Methods

    /// Normalize input by lowercasing, trimming whitespace and removing common punctuation.
    /// This helps achieve consistent matching against mapping keys.
    /// - Parameter input: Raw input string
    /// - Returns: Normalized string
    private func normalize(_ input: String) -> String {
        let lowercased = input.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // Remove common punctuation characters
        let punctuationChars = CharacterSet(charactersIn: ".,!?:;")
        let cleaned = lowercased.components(separatedBy: punctuationChars).joined()
        return cleaned
    }
    
    /// Calculate Levenshtein distance between two strings.
    /// Simple implementation for fuzzy matching.
    /// - Parameters:
    ///   - lhs: First string
    ///   - rhs: Second string
    /// - Returns: Int distance
    private func levenshteinDistance(_ lhs: String, _ rhs: String) -> Int {
        let lhsChars = Array(lhs)
        let rhsChars = Array(rhs)
        let lhsCount = lhsChars.count
        let rhsCount = rhsChars.count
        
        var dist = Array(repeating: Array(repeating: 0, count: rhsCount + 1), count: lhsCount + 1)
        
        for i in 0...lhsCount { dist[i][0] = i }
        for j in 0...rhsCount { dist[0][j] = j }
        
        for i in 1...lhsCount {
            for j in 1...rhsCount {
                if lhsChars[i - 1] == rhsChars[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }
        return dist[lhsCount][rhsCount]
    }
    
    /// Find fuzzy match from mapping keys using Levenshtein distance.
    /// Returns the mapped value for closest match if distance is below threshold.
    /// - Parameter input: Normalized input string
    /// - Returns: Optional corrected string
    private func fuzzyMatch(_ input: String) -> String? {
        let maxDistance = 2
        var closestMatch: (key: String, distance: Int)? = nil
        
        for key in autocorrectMapping.keys {
            let distance = levenshteinDistance(input, key)
            if distance <= maxDistance {
                if closestMatch == nil || distance < closestMatch!.distance {
                    closestMatch = (key, distance)
                }
            }
        }
        if let match = closestMatch {
            return autocorrectMapping[match.key]
        }
        return nil
    }
    
    /// Attempt partial/contains matching for multi-word inputs.
    /// If any key from mapping is fully contained within the input string, return its mapped value.
    /// - Parameter normalizedInput: normalized input string
    /// - Returns: Optional corrected string
    private func partialContainsMatch(_ normalizedInput: String) -> String? {
        for key in autocorrectMapping.keys {
            if normalizedInput.contains(key) {
                return autocorrectMapping[key]
            }
        }
        return nil
    }
    
    /// Attempt plural/singular form matching by adding/removing trailing 's'.
    /// Checks both singular and plural forms in mapping keys.
    /// - Parameter normalizedInput: normalized input string
    /// - Returns: Optional corrected string
    private func pluralSingularMatch(_ normalizedInput: String) -> String? {
        if normalizedInput.hasSuffix("s") {
            // Try singular form by removing trailing 's'
            let singular = String(normalizedInput.dropLast())
            if let corrected = autocorrectMapping[singular] {
                return corrected
            }
        } else {
            // Try plural form by adding trailing 's'
            let plural = normalizedInput + "s"
            if let corrected = autocorrectMapping[plural] {
                return corrected
            }
        }
        return nil
    }
    
    /// Returns the autocorrected and capitalized version of a given string.
    /// Applies normalization, pluralization checks, partial matching, and fuzzy matching.
    /// If all fail, attempts autocorrection using UITextChecker.
    /// If no correction found, returns capitalized raw input.
    /// - Parameter rawName: The raw input string.
    /// - Returns: The autocorrected and capitalized string.
    private func autocorrectedItemName(for rawName: String) -> String {
        // Normalize input
        let normalized = normalize(rawName)
        
        #if DEBUG
        print("[DEBUG] Raw input: '\(rawName)', normalized: '\(normalized)'")
        #endif
        
        // 1. Exact mapping match
        if let directMapping = autocorrectMapping[normalized] {
            #if DEBUG
            print("[DEBUG] Exact mapping found: '\(directMapping)'")
            #endif
            return directMapping
        }
        
        // 2. Plural/Singular form matching
        if let pluralSingular = pluralSingularMatch(normalized) {
            #if DEBUG
            print("[DEBUG] Plural/Singular mapping found: '\(pluralSingular)'")
            #endif
            return pluralSingular
        }
        
        // 3. Partial/contains matching for multi-word input
        if normalized.split(separator: " ").count > 1 {
            if let partialMatch = partialContainsMatch(normalized) {
                #if DEBUG
                print("[DEBUG] Partial/contains mapping found: '\(partialMatch)'")
                #endif
                return partialMatch
            }
        }
        
        // 4. Fuzzy matching using Levenshtein distance
        if let fuzzy = fuzzyMatch(normalized) {
            #if DEBUG
            print("[DEBUG] Fuzzy mapping found: '\(fuzzy)'")
            #endif
            return fuzzy
        }
        
        // 5. Attempt autocorrection using UITextChecker
        let checker = UITextChecker()
        let nsString = rawName as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let misspelledRange = checker.rangeOfMisspelledWord(in: rawName, range: range, startingAt: 0, wrap: false, language: "en_US")
        
        if misspelledRange.location != NSNotFound,
           let guesses = checker.guesses(forWordRange: misspelledRange, in: rawName, language: "en_US"),
           let firstGuess = guesses.first {
            // Return autocorrected guess with capitalized first letter
            let corrected = firstGuess.prefix(1).uppercased() + firstGuess.dropFirst()
            #if DEBUG
            print("[DEBUG] UITextChecker autocorrection found: '\(corrected)'")
            #endif
            return corrected
        }
        
        #if DEBUG
        print("[DEBUG] No mapping or autocorrect found for: '\(rawName)'. Returning capitalized raw input.")
        #endif
        
        // Capitalize first letter of raw input as fallback
        return rawName.prefix(1).uppercased() + rawName.dropFirst()
    }
    
    /// Placeholder function for adding user learned new autocorrect mappings.
    /// Can be extended in future to allow users to teach corrections which persist.
    /// - Parameters:
    ///   - rawName: Raw user input
    ///   - correctedName: User provided correction
    private func learnNewAutocorrectMapping(rawName: String, correctedName: String) {
        // Implementation pending: store mapping persistently (e.g., UserDefaults or CoreData)
        // For now, just a placeholder to show where such functionality would go.
        // Example:
        // autocorrectMapping[normalize(rawName)] = correctedName
    }
    
    /// Adds a new item to the list if it doesn't already exist.
    /// - Parameters:
    ///   - name: The name of the item to add.
    ///   - fromSpeech: Indicates if the item is from speech input. Defaults to `false`.
    /// - Returns: Bool indicating whether the item was successfully added.
    /// - Note:
    ///   - Performs case-insensitive duplicate checking and shows an alert if a duplicate is found.
    ///   - For speech input, uses the trimmed and capitalized name directly without autocorrect,
    ///     and appends " (v)" suffix if not already present.
    ///   - For manual input, uses autocorrected and capitalized name as before.
    private func addItem(name: String, fromSpeech: Bool = false) -> Bool {
        let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        
        // Rate limiting: Prevent adding items too quickly in succession
        let now = Date()
        guard now.timeIntervalSince(lastItemAddedTime) > 0.3 else {
            return false
        }
        lastItemAddedTime = now
        
        let itemNameToStore: String
        
        if fromSpeech {
            // For speech input, use the trimmed and capitalized name without autocorrect or suffix
            var baseName = trimmedName.prefix(1).uppercased() + trimmedName.dropFirst()
            if !baseName.hasSuffix(" (v)") {
                baseName += " (v)"
            }
            itemNameToStore = baseName
        } else {
            // For manual input, apply autocorrect and capitalization with robust correction logic
            itemNameToStore = autocorrectedItemName(for: trimmedName)
        }
        
        // Function to strip " (v)" suffix for comparison
        func stripVSuffix(_ str: String) -> String {
            if str.hasSuffix(" (v)") {
                return String(str.dropLast(4))
            }
            return str
        }
        
        let normalizedNewName = stripVSuffix(itemNameToStore).lowercased()
        
        // Check for duplicate items (case insensitive comparison) ignoring suffix " (v)"
        if list.items.contains(where: { stripVSuffix($0.name).lowercased() == normalizedNewName }) {
            // Show native iOS style alert for duplicate items
            alertMessage = "\"\(itemNameToStore)\" is already in your list"
            alertIcon = "x.circle.fill"
            alertColor = .red
            showAlert = true
            lastDuplicateWasManual = !fromSpeech
            
            // Auto-dismiss after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showAlert = false
                if lastDuplicateWasManual {
                    inputText = ""
                    lastDuplicateWasManual = false
                }
            }
            return false
        }
        
        // Add the new item via dataStore with animation
        withAnimation {
            var newItem = ItemRow(name: itemNameToStore)
            newItem.createdAt = now
            newItem.updatedAt = now
            dataStore.addItem(newItem, to: list)
            // Clear input only on manual input
            if !fromSpeech {
                inputText = ""
            }
            // Show success alert for added item
            lastAddedItemName = itemNameToStore
            alertMessage = "\(itemNameToStore) has been added"
            alertIcon = "checkmark.circle.fill"
            alertColor = Color.green
            showAlert = true
            // Auto-dismiss after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showAlert = false
                }
            }
        }
        
        // Haptic feedback for successful addition
        if fromSpeech {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
        return true
    }
    
    private func toggleItem(_ item: ItemRow) {
        // Toggle completion state of specified item
        let toggledItem = ItemRow(
            id: item.id,
            name: item.name,
            isCompleted: !item.isCompleted,
            createdAt: item.createdAt,
            updatedAt: Date()
        )
        dataStore.updateItem(toggledItem, in: list)
    }
    
    private func deleteItems(offsets: IndexSet) {
        // Delete items at specified index set
        let itemsToDelete = offsets.compactMap { index -> ItemRow? in
            if index < list.items.count {
                return list.items[index]
            }
            return nil
        }
        for item in itemsToDelete {
            dataStore.deleteItem(item, from: list)
        }
    }
    
    /// Handles the finalized transcript from speech recognition.
    /// Instead of splitting the transcript by commas or separators,
    /// this adds the entire trimmed transcript as a single item.
    private func handleFinalTranscript() {
        guard !isProcessingFinal else { return }
        isProcessingFinal = true
        
        let trimmed = speechRecognizer.transcript.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            // For silence or empty input, just reset state silently without UI feedback
            isProcessingFinal = false
            // Clear transcript as well
            speechRecognizer.transcript = ""
            lastTranscript = ""
            lastProcessedSegmentIndex = -1
            return 
        }
        
        // Add the entire final transcript as a single item (capitalized + " (v)" appended)
        let firstChar = String(trimmed.prefix(1)).capitalized
        let itemToAdd = firstChar + String(trimmed.dropFirst())
        let added = addItem(name: itemToAdd, fromSpeech: true)
        
        // Show feedback if item was added
        if added || !lastAddedItemName.isEmpty {
            // Removed overlay feedback; using alert now handled in addItem
        }
        
        // Reset state
        lastTranscript = ""
        lastProcessedSegmentIndex = -1
        
        // Clear last added item name after feedback
        lastAddedItemName = ""
        
        // Clear the transcript to prepare for next speech input
        speechRecognizer.transcript = ""
        isProcessingFinal = false
    }
    
    private func speechRecognitionDidFinish(final: Bool) {
        // Handle changes when speech recognizer's 'isFinal' property updates
        if final {
            handleFinalTranscript()
            // Reset transcript to be ready for next input
            speechRecognizer.transcript = ""
        }
    }
    
    private func speechRecognitionDidFail() {
        // Removed error alert; no blocking UI on error
    }
    
    // MARK: - Subviews
    
    private var progressBarView: some View {
        // Progress bar view for list completion
        HStack(spacing: 0) {
            Spacer()
            Text("Purchased \(purchasedCount) of \(totalCount)")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            ProgressView(value: progress)
                .tint(.green)
                .frame(width: 180)
            Spacer()
            Text("\(Int((progress * 100).rounded()))%")
                .font(.caption)
            Spacer()
        }
        .padding(.top, 10)
    }
    
    private var inputRowView: some View {
        // Input field and microphone button
        VStack(spacing: 2) {
            HStack(spacing: 10) {
                Spacer()
                TextField("Add Item OR use microphone for voice inputs...", text: $inputText)
                    .autocorrectionDisabled(false)
                    .textInputAutocapitalization(.sentences)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .focused($isInputFocused)
                    .onSubmit {
                        let trimmed = inputText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let _ = addItem(name: trimmed)
                    }
                speechButton
                Spacer()
            }
            
            if speechRecognizer.isListening {
                Text("Microphone is on. Pause between items to add them automatically.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
        }
        .padding(.top, 10)
    }
    
    private var transcriptView: some View {
        // Live transcript view shown during dictation
        VStack(alignment: .leading, spacing: 4) {
            Text("Actively Listening...")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(speechRecognizer.transcript)
                .font(.caption)
                .foregroundColor(.primary)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal)
        .transition(.opacity.combined(with: .move(edge: .top)))
        // Removed .onReceive(speechRecognizer.isFinalPublisher) to avoid duplicate triggers
    }
    
    private var emptyStateView: some View {
        // Empty list state view
        VStack(spacing: 15) {
            Spacer()
            Image(systemName: "list.number.badge.ellipsis")
                .font(.largeTitle)
                .foregroundColor(.red.opacity(0.3))
            VStack(spacing: 0) {
                Text("No items yet")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding()
                Text("Tap the text field above to add your first item")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var itemsListView: some View {
        // The main list of items
        ScrollView {
            VStack(spacing: 2) {
     
                let sortedItems = list.items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 10) {
                        Button {
                            toggleItem(item)
                        } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 28, height: 28)
                                    Text("\(index + 1)")
                                        .font(.caption.bold())
                                        .foregroundColor(item.isCompleted ? .secondary : .primary)
                                        .strikethrough(item.isCompleted)
                                }
                                // Display the item name exactly as stored (including " (v)" if from speech)
                                Text(item.name)
                                    .font(.body)
                                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                                    .strikethrough(item.isCompleted)
                                Spacer()
                                if item.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        Button(action: {
                            dataStore.deleteItem(item, from: list)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(item.isCompleted ? Color.green.opacity(0.12) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(.horizontal)
            .padding(.top, 30)
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Speech Button
    
    private var speechButton: some View {
        ZStack {
            if speechRecognizer.isListening || micPulse {
                Circle()
                    .fill(speechRecognizer.isListening ? Color.blue.opacity(0.3) : Color.clear)
                    .frame(width: micPulse ? 64 : 50, height: micPulse ? 64 : 50)
                    .scaleEffect(micPulse ? 1.2 : 1.0)
                    .opacity(micPulse ? 0.5 : 0.2)
                    .animation(.easeOut(duration: 0.4), value: micPulse)
            }
            
            Button(action: toggleSpeechRecognition) {
                Image(systemName: speechRecognizer.isListening ? "waveform" : "mic.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(speechRecognizer.isListening ? .white : .white)
                    .frame(width: 44, height: 44)
                    .background(speechRecognizer.isListening ? Color.red : Color.blue)
                    .clipShape(Circle())
                    .shadow(color: speechRecognizer.isListening ? .red.opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(speechRecognizer.isListening ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: speechRecognizer.isListening)
        }
        .padding(4)
        // Removed incremental processing: do not add items as transcript updates
        // Items are added only when transcript is finalized via handleFinalTranscript()
        // Hence, no processing in onChange of transcript
        
        // We keep this onChange to update lastTranscript for display & tracking only
        .onChange(of: speechRecognizer.transcript) { _, newValue in
            // Just update lastTranscript for display, no item adding
            lastTranscript = newValue
            
            if speechRecognizer.isListening && !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                micPulse = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { micPulse = false }
            }
        }
        .onChange(of: speechRecognizer.isFinal) { _, newValue in
            if newValue {
                // Using only this to handle final transcript processing and reset transcript
                handleFinalTranscript()
                speechRecognizer.transcript = ""
            }
        }
        .onChange(of: speechRecognizer.errorMessage) { _, newValue in
            if newValue != nil {
                speechRecognitionDidFail()
            }
        }
    }
    
    private func toggleSpeechRecognition() {
        if speechRecognizer.isListening {
            stopSpeechRecognition()
        } else {
            startSpeechRecognition()
        }
    }
    
    private func startSpeechRecognition() {
        // Reset state for new recognition session
        lastTranscript = ""
        lastProcessedSegmentIndex = -1
        userAttemptedSpeech = true
        isListening = true
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        Task {
            await speechRecognizer.start()
        }
    }
    
    private func stopSpeechRecognition() {
        speechRecognizer.stop()
        userAttemptedSpeech = false
        isListening = false
        
        // Process any remaining text in the input field (manual input)
        if !inputText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            processTextInput(inputText)
            inputText = ""
        }
    }
    
    /// We completely removed incremental processing of speech transcript here.
    /// Items are only added on finalized transcript to avoid duplication and partial additions.
    private func processSpeechTranscript(_ transcript: String) {
        // Intentionally left empty due to updated logic:
        // Items are added only on finalized transcript.
    }
    
    private func processTextInput(_ text: String) {
        // Skip if already processing or empty input
        guard !isProcessingSpeech, !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isProcessingSpeech = true
        
        // Process on a background thread to keep UI responsive
        DispatchQueue.global(qos: .userInitiated).async {
            let potentialItems = self.splitIntoSeparateItems(text)
            var processedCount = 0
            
            // Process each item with a small delay between them
            for item in potentialItems {
                // Skip empty items
                guard !item.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                    continue
                }
                
                // Process on main thread since it updates UI
                DispatchQueue.main.async {
                    _ = self.addItem(name: item, fromSpeech: true)
                }
                
                // Add a small delay between processing items for better UX
                if processedCount < potentialItems.count - 1 {
                    Thread.sleep(forTimeInterval: 0.3)
                }
                processedCount += 1
            }
            
            DispatchQueue.main.async {
                self.isProcessingSpeech = false
            }
        }
    }
    
    private func splitIntoSeparateItems(_ text: String) -> [String] {
        // Split by common separators (comma, period, newline, etc.)
        // Removed replacingOccurrences(of: " and ", with: ",") to avoid corrupting legitimate words like "soda"
        let separators = CharacterSet(charactersIn: ",.\n\r")
        let components = text.components(separatedBy: separators)
        
        // Process each component
        return components.map { component in
            // Clean up the component
            var cleaned = component
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            // Capitalize first letter
            if !cleaned.isEmpty {
                let firstChar = String(cleaned.prefix(1)).capitalized
                cleaned = firstChar + String(cleaned.dropFirst())
            }
            
            return cleaned
        }
        .filter { !$0.isEmpty } // Remove any empty strings
    }
}
  
// MARK: - Previews

#Preview("With Items") {
    // Create a sample list with various items
    let sampleList = MyList(
        name: "Grocery Shopping",
        items: [
            ItemRow(name: "Milk", isCompleted: false, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Bread", isCompleted: false, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Apples", isCompleted: false, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Chicken", isCompleted: true, createdAt: Date(), updatedAt: Date())
        ],
        isDeleted: false,
        createdAt: Date().addingTimeInterval(-86400 * 2), // 2 days ago
        updatedAt: Date()
    )
    
    // Set up the data store with the sample list
    let dataStore = DataStore()
    dataStore.lists = [sampleList]
    
    // Return the preview with navigation
    return NavigationStack {
        ListDetailView(list: .constant(sampleList))
            .environmentObject(dataStore)
    }
}

#Preview("Empty List") {
    // Create an empty list
    let emptyList = MyList(
        name: "Empty Shopping List",
        items: [],
        isDeleted: false,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    // Set up the data store with the empty list
    let dataStore = DataStore()
    dataStore.lists = [emptyList]
    
    // Return the preview with navigation
    return NavigationStack {
        ListDetailView(list: .constant(emptyList))
            .environmentObject(dataStore)
    }
}

#Preview("Completed List") {
    // Create a fully completed list
    let completedList = MyList(
        name: "Completed Shopping",
        items: [
            ItemRow(name: "Milk", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Eggs", isCompleted: true, createdAt: Date(), updatedAt: Date()),
            ItemRow(name: "Bread", isCompleted: true, createdAt: Date(), updatedAt: Date())
        ],
        isDeleted: false,
        createdAt: Date().addingTimeInterval(-86400), // 1 day ago
        updatedAt: Date()
    )
    
    // Set up the data store with the completed list
    let dataStore = DataStore()
    dataStore.lists = [completedList]
    
    // Return the preview with navigation
    return NavigationStack {
        ListDetailView(list: .constant(completedList))
            .environmentObject(dataStore)
    }
}

