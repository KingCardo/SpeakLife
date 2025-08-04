//
//  VoiceInputManager.swift
//  SpeakLife
//
//  Voice input and speech-to-text functionality for journal and affirmation entries
//

import Foundation
import Speech
import AVFoundation
import SwiftUI

enum VoiceInputState: CaseIterable {
    case idle           // Microphone button ready
    case listening      // Actively recording
    case processing     // Converting speech to text
    case transcribing   // Real-time text display
    case paused         // Temporarily stopped
    case completed      // Finished recording
    case error          // Error occurred
}

@MainActor
class VoiceInputManager: NSObject, ObservableObject {
    // MARK: - Speech Recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // MARK: - Audio Recording
    private let audioEngine = AVAudioEngine()
    private var audioSession = AVAudioSession.sharedInstance()
    
    // MARK: - Published State
    @Published var transcribedText: String = ""
    @Published var isListening: Bool = false
    @Published var voiceInputState: VoiceInputState = .idle
    @Published var audioLevels: [Float] = []
    @Published var hasPermissions: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Configuration
    private let maxRecordingDuration: TimeInterval = 300 // 5 minutes
    private var recordingTimer: Timer?
    private var audioLevelTimer: Timer?
    
    override init() {
        super.init()
        checkInitialPermissions()
    }
    
    deinit {
     //   cleanup()
    }
    
    private nonisolated func cleanup() {
        // Use detached task to handle all MainActor-isolated cleanup
        Task.detached { @MainActor [weak self] in
            guard let self = self else { return }
            
            // Stop audio engine safely
            if self.audioEngine.isRunning {
                self.audioEngine.stop()
            }
            
            // Stop recognition safely
            self.recognitionRequest?.endAudio()
            self.recognitionRequest = nil
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
            
            // Clean up timers safely
            self.recordingTimer?.invalidate()
            self.recordingTimer = nil
            self.audioLevelTimer?.invalidate()
            self.audioLevelTimer = nil
        }
    }
    
    // MARK: - Permission Management
    private func checkInitialPermissions() {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        let micStatus = audioSession.recordPermission
        
        hasPermissions = speechStatus == .authorized && micStatus == .granted
    }
    
    func requestPermissions() async -> Bool {
        // Request speech recognition permission
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        
        // Request microphone permission
        let micStatus = await withCheckedContinuation { continuation in
            audioSession.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        
        let permissionsGranted = speechStatus && micStatus
        await MainActor.run {
            hasPermissions = permissionsGranted
        }
        return permissionsGranted
    }
    
    // MARK: - Voice Input Control
    func startListening() {
        guard hasPermissions else {
            errorMessage = "Microphone and speech recognition permissions are required"
            voiceInputState = .error
            return
        }
        
        // Clean up any previous session first - always do this
        if isListening || audioEngine.isRunning {
            stopListening()
            // Wait a moment for cleanup to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.performStartListening()
            }
            return
        }
        
        performStartListening()
    }
    
    private func performStartListening() {
        do {
            try setupAudioSession()
            try startSpeechRecognition()
            startAudioLevelMonitoring()
            
            voiceInputState = .listening
            isListening = true
            errorMessage = nil
            
            // Auto-stop after max duration
            recordingTimer = Timer.scheduledTimer(withTimeInterval: maxRecordingDuration, repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.stopListening()
                }
            }
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
        } catch {
            handleError(error)
        }
    }
    
    func stopListening() {
        guard isListening else { return }
        
        // Stop recognition first to prevent new audio data
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        // Stop audio engine safely with proper cleanup
        if audioEngine.isRunning {
            // Remove the tap first to avoid crashes
            let inputNode = audioEngine.inputNode
            inputNode.removeTap(onBus: 0)
            
            // Stop the engine
            audioEngine.stop()
            
            // Reset the engine for next session
            audioEngine.reset()
        }
        
        // Clean up recognition objects
        recognitionRequest = nil
        recognitionTask = nil
        
        // Clean up timers safely
        recordingTimer?.invalidate()
        recordingTimer = nil
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        
        // Deactivate audio session to allow other apps to use audio
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error deactivating audio session: \(error)")
        }
        
        // Update state
        voiceInputState = transcribedText.isEmpty ? .idle : .completed
        isListening = false
        audioLevels.removeAll()
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func pauseListening() {
        guard isListening else { return }
        
        audioEngine.pause()
        voiceInputState = .paused
        audioLevelTimer?.invalidate()
    }
    
    func resumeListening() {
        guard voiceInputState == .paused else { return }
        
        do {
            try audioEngine.start()
            startAudioLevelMonitoring()
            voiceInputState = .listening
        } catch {
            handleError(error)
        }
    }
    
    func clearTranscription() {
        transcribedText = ""
        voiceInputState = .idle
        errorMessage = nil
    }
    
    // MARK: - Private Implementation
    private func setupAudioSession() throws {
        // Deactivate first if already active to avoid conflicts
        if audioSession.isOtherAudioPlaying == false {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        
        // Enhanced audio session for better voice recognition
        try audioSession.setCategory(
            .playAndRecord,
            mode: .spokenAudio, // Optimized for speech
            options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP]
        )
        
        // Activate with proper error handling
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func startSpeechRecognition() throws {
        // Cancel any previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceInputError.recognitionRequestFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Enhanced configuration for better accuracy
        if #available(iOS 16.0, *) {
            recognitionRequest.addsPunctuation = true
            recognitionRequest.requiresOnDeviceRecognition = false // Use cloud for better accuracy
            
            // Additional accuracy improvements
            recognitionRequest.taskHint = .dictation // Optimize for dictation vs search
        }
        
        if #available(iOS 17.0, *) {
            // Use the most accurate recognition mode available
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if let result = result {
                    let newText = result.bestTranscription.formattedString
                    
                    // Only update if text actually changed to prevent duplicates
                    if newText != self.transcribedText {
                        self.transcribedText = self.enhanceTranscription(newText)
                    }
                    
                    // Update state based on final result
                    if result.isFinal {
                        self.voiceInputState = .completed
                    } else {
                        self.voiceInputState = .transcribing
                    }
                }
                
                if let error = error {
                    self.handleError(error)
                }
            }
        }
        
        // Setup audio input with optimized settings
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Use larger buffer size for better accuracy (was 1024)
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func startAudioLevelMonitoring() {
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateAudioLevels()
            }
        }
    }
    
    private func updateAudioLevels() {
        guard audioEngine.isRunning else { return }
        
        // Simulate audio levels for UI (real implementation would extract from audio buffer)
        let randomLevel = Float.random(in: 0.1...0.8)
        audioLevels.append(randomLevel)
        
        // Keep only recent levels for visualization
        if audioLevels.count > 50 {
            audioLevels.removeFirst()
        }
    }
    
    private func enhanceTranscription(_ text: String) -> String {
        var enhanced = text
        
        // Capitalize spiritual terms
        let spiritualTerms = [
            "god", "jesus", "christ", "lord", "father", "holy spirit",
            "bible", "scripture", "prayer", "amen", "hallelujah", "praise",
            "blessing", "faith", "grace", "mercy", "salvation", "heaven"
        ]
        
        for term in spiritualTerms {
            let pattern = "\\b\(term)\\b"
            enhanced = enhanced.replacingOccurrences(
                of: pattern,
                with: term.capitalized,
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        return enhanced
    }
    
    private func handleError(_ error: Error) {
        stopListening()
        voiceInputState = .error
        
        errorMessage = "Voice input error: \(error.localizedDescription)"
        
        print("❌ Voice input error: \(error)")
    }
}

// MARK: - Voice Input Errors
enum VoiceInputError: LocalizedError {
    case recognitionRequestFailed
    case audioEngineStartFailed
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .recognitionRequestFailed:
            return "Failed to create speech recognition request"
        case .audioEngineStartFailed:
            return "Failed to start audio engine"
        case .permissionDenied:
            return "Microphone or speech recognition permission denied"
        }
    }
}

// MARK: - Convenience Extensions
extension VoiceInputManager {
    var canStartListening: Bool {
        hasPermissions && !isListening && voiceInputState != .processing
    }
    
    var isActivelyRecording: Bool {
        voiceInputState == .listening || voiceInputState == .transcribing
    }
    
    var hasContent: Bool {
        !transcribedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
