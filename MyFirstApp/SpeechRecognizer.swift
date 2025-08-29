//
//  SpeechRecognizer.swift
//  MyFirstApp
//
//  Created for the voice item add feature.
//
//  A simple ObservableObject wrapper for Apple’s Speech framework.
//  Handles permissions, start/stop, and publishing live transcriptions.

import Foundation
import Speech
import AVFoundation
import Combine
import UIKit

/// Observable object to manage speech recognition using Apple's Speech framework.
/// Handles permissions, manages audio session, and publishes results in real time.
@MainActor
class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isListening: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isFinal: Bool = false
    @Published var isProcessing: Bool = false
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    private var pauseTimer: Timer?
    
    // MARK: - Publishers
    var isFinalPublisher: AnyPublisher<Bool, Never> { $isFinal.eraseToAnyPublisher() }
    var errorMessagePublisher: AnyPublisher<String?, Never> { $errorMessage.eraseToAnyPublisher() }
    
    // MARK: - Permissions
    /*
     static func requestPermissions(completion: @escaping (Bool) -> Void) {
     SFSpeechRecognizer.requestAuthorization { authStatus in
     AVAudioSession.sharedInstance().requestRecordPermission { allowed in
     DispatchQueue.main.async {
     completion(authStatus == .authorized && allowed)
     }
     }
     }
     }
     */
    
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            var speechAuthorized = false
            var micAuthorized = false
            
            SFSpeechRecognizer.requestAuthorization { speechStatus in
                speechAuthorized = (speechStatus == .authorized)
                print("[SpeechRecognizer] Speech permission: \(speechAuthorized)")
                AVAudioSession.sharedInstance().requestRecordPermission { micAllowed in
                    micAuthorized = micAllowed
                    print("[SpeechRecognizer] Mic permission: \(micAuthorized)")
                    DispatchQueue.main.async {
                        continuation.resume(returning: speechAuthorized && micAuthorized)
                    }
                }
            }
        }
    }
    
    // MARK: - Start/Stop Recognition
    func start() async {
        print("[SpeechRecognizer] start() called")
        let granted = await requestAuthorization()
        print("[SpeechRecognizer] Microphone/listening granted: \(granted)")
        guard granted else {
            errorMessage = "Speech or mic permission denied."
            isListening = false
            return
        }
        await beginRecognition()
    }
    
    func stop() {
        print("[SpeechRecognizer] stop() called")
        pauseTimer?.invalidate()
        pauseTimer = nil
        
        request?.endAudio()
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        // Cancel the current recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Reset audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error deactivating audio session: \(error)")
        }
        
        // Update state
        DispatchQueue.main.async {
            self.isListening = false
            self.isFinal = true
            self.isProcessing = false
            self.audioEngine = nil
            self.request = nil
        }
    }
    
    private func beginRecognition() async {
        print("[SpeechRecognizer] beginRecognition() called")
        pauseTimer?.invalidate()
        pauseTimer = nil
        
        self.transcript = ""
        self.errorMessage = nil
        self.isFinal = false
        self.isListening = true
        self.isProcessing = true
        
        // Set up audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.errorMessage = "Audio session error: \(error.localizedDescription)"
            self.isListening = false
            self.isProcessing = false
            return
        }
        
        // Start audio engine
        let engine = AVAudioEngine()
        let req = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = engine.inputNode
        req.shouldReportPartialResults = true
        req.taskHint = .dictation
        req.requiresOnDeviceRecognition = true
        
        self.audioEngine = engine
        self.request = req
        
        // Configure the recognition task
        recognitionTask = recognizer?.recognitionTask(with: req) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let newTranscript = result.bestTranscription.formattedString
                print("[SpeechRecognizer] Recognition result: \(newTranscript), isFinal: \(result.isFinal)")
                print("[SpeechRecognizer] Setting transcript: \(newTranscript)")
                DispatchQueue.main.async {
                    self.transcript = newTranscript
                    if result.isFinal {
                        self.processFinalResultAndContinue()
                        return
                    }
                    self.isFinal = false
                    // Reset the pause timer on each transcript update
                    self.pauseTimer?.invalidate()
                    self.pauseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                        guard let self = self else { return }
                        print("[SpeechRecognizer] No speech change for 1.0 seconds. Forcing isFinal = true.")
                        self.processFinalResultAndContinue()
                    }
                    print("[SpeechRecognizer] Pause timer reset.")
                    print("[SpeechRecognizer] Silence timer set to 1.0 second.")
                }
            }
            
            if let error = error {
                print("[SpeechRecognizer] Recognition error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isListening = false
                    self.isProcessing = false
                    self.stop()
                }
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.request?.append(buffer)
        }
        
        // Start the audio engine
        engine.prepare()
        do {
            try engine.start()
            print("[SpeechRecognizer] Audio engine started")
            DispatchQueue.main.async {
                self.isProcessing = false
            }
        } catch {
            print("[SpeechRecognizer] Audio engine error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Audio engine error: \(error.localizedDescription)"
                self.isListening = false
                self.isProcessing = false
                self.stop()
            }
        }
    }
    
    // MARK: - New helper methods for continuous recognition
    
    private func processFinalResultAndContinue() {
        // Check if the transcript is empty or only whitespace
        if transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("[SpeechRecognizer] Skipping empty result, restarting recognition.")
        } else {
            print("[SpeechRecognizer] Item added, vibrating and restarting recognition.")
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            print("[SpeechRecognizer] Haptic feedback: .light impact occurred after item added.")
        }
        
        print("[SpeechRecognizer] Finalizing current phrase and continuing recognition.")
        self.isFinal = true
        self.pauseTimer?.invalidate()
        self.pauseTimer = nil
        
        // Only restart if still listening (not manually stopped)
        if self.isListening {
            print("[SpeechRecognizer] Stopping for phrase reset.")
            self.stop()
            print("[SpeechRecognizer] Scheduling restart of recognition for continuous listening after 0.5 seconds.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task {
                    await self.start()
                }
            }
        } else {
            print("[SpeechRecognizer] Not restarting recognition because isListening is false (manually stopped).")
        }
    }
}

