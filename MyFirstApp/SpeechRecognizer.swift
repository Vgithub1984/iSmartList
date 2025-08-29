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

/// Observable object to manage speech recognition using Apple's Speech framework.
/// Handles permissions, manages audio session, and publishes results in real time.
@MainActor
class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isListening: Bool = false
    @Published var errorMessage: String? = nil
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    // MARK: - Permissions
    static func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    completion(authStatus == .authorized && allowed)
                }
            }
        }
    }
    
    // MARK: - Start/Stop Recognition
    func start() async {
        await Self.requestPermissions { [weak self] granted in
            guard granted else {
                self?.errorMessage = "Speech or mic permission denied."
                self?.isListening = false
                return
            }
            Task { await self?.beginRecognition() }
        }
    }
    
    func stop() {
        audioEngine?.stop()
        audioEngine = nil
        request?.endAudio()
        request = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }
    
    private func beginRecognition() async {
        self.transcript = ""
        self.errorMessage = nil
        self.isListening = true
        
        // Set up audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.errorMessage = "Audio session error: \(error.localizedDescription)"
            self.isListening = false
            return
        }
        
        // Start audio engine
        let engine = AVAudioEngine()
        let req = SFSpeechAudioBufferRecognitionRequest()
        guard let inputNode = engine.inputNode else {
            self.errorMessage = "No audio input available."
            self.isListening = false
            return
        }
        req.shouldReportPartialResults = true
        
        self.audioEngine = engine
        self.request = req
        
        recognitionTask = recognizer?.recognitionTask(with: req) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
                if result.isFinal {
                    self.isListening = false
                    self.stop()
                }
            }
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isListening = false
                self.stop()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            req.append(buffer)
        }
        
        engine.prepare()
        do {
            try engine.start()
        } catch {
            self.errorMessage = "Audio engine error: \(error.localizedDescription)"
            self.isListening = false
            self.stop()
        }
    }
}
