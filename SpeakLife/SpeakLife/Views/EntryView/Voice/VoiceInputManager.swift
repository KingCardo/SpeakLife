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
    @Published var transcriptionConfidence: Float = 0.0
    @Published var alternativeTranscriptions: [String] = []
    
    // MARK: - Configuration
    private let maxRecordingDuration: TimeInterval = 300 // 5 minutes
    private var recordingTimer: Timer?
    private var audioLevelTimer: Timer?
    private var retryCount = 0
    private let maxRetries = 3
    private var lastTranscriptionTime: Date?
    
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
        
        // If already listening or engine is running, stop first
        if isListening || audioEngine.isRunning || recognitionTask != nil {
            stopListening()
            // Wait longer for cleanup to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.performStartListening()
            }
            return
        }
        
        // Check if we're in a transitional state
        if voiceInputState == .processing || voiceInputState == .transcribing {
            // Wait for current operation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startListening()
            }
            return
        }
        
        performStartListening()
    }
    
    private func performStartListening() {
        do {
            print("🎤 Voice Input: Starting new session...")
            
            // Reset audio engine to clean state
            if audioEngine.isRunning {
                print("🎤 Voice Input: Stopping running engine")
                audioEngine.stop()
                audioEngine.reset()
            }
            
            print("🎤 Voice Input: Setting up audio session")
            try setupAudioSession()
            
            print("🎤 Voice Input: Starting speech recognition")
            try startSpeechRecognition()
            
            print("🎤 Voice Input: Starting audio level monitoring")
            startAudioLevelMonitoring()
            
            voiceInputState = .listening
            isListening = true
            errorMessage = nil
            
            // Auto-stop after max duration
            recordingTimer = Timer.scheduledTimer(withTimeInterval: maxRecordingDuration, repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in
                    print("🎤 Voice Input: Max duration reached, stopping")
                    self?.stopListening()
                }
            }
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            print("🎤 Voice Input: Successfully started listening")
            
        } catch {
            print("🎤 Voice Input Error: \(error)")
            handleError(error)
        }
    }
    
    func stopListening() {
        guard isListening else { return }
        
        // Set state first to prevent new operations
        isListening = false
        
        // Stop recognition immediately but gracefully
        recognitionRequest?.endAudio()
        
        // Clean up timers immediately
        recordingTimer?.invalidate()
        recordingTimer = nil
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        
        // Stop audio engine immediately with proper cleanup
        if audioEngine.isRunning {
            // Remove the tap first to avoid crashes
            let inputNode = audioEngine.inputNode
            inputNode.removeTap(onBus: 0)
            
            // Stop the engine
            audioEngine.stop()
        }
        
        // Wait a brief moment for final results, then do final cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Cancel recognition task
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
            self.recognitionRequest = nil
            
            // Reset audio engine for next use
            self.audioEngine.reset()
            
            // Deactivate audio session
            do {
                try self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("Error deactivating audio session: \(error)")
            }
            
            // Update final state
            self.voiceInputState = self.transcribedText.isEmpty ? .idle : .completed
            self.audioLevels.removeAll()
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
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
    
    func finalizePendingTranscription() {
        // Force finalization of any pending transcription - useful when switching between voice and manual input
        if !transcribedText.isEmpty && voiceInputState == .transcribing {
            voiceInputState = .completed
            
            // Give one final enhancement pass
            transcribedText = enhanceTranscription(transcribedText)
        }
    }
    
    // MARK: - Private Implementation
    private func setupAudioSession() throws {
        // Always deactivate first to ensure clean state
        do {
            if audioSession.category != .playAndRecord {
                try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            }
        } catch {
            print("🎤 Voice Input: Warning - Could not deactivate audio session: \(error)")
        }
        
        // Enhanced audio session for better voice recognition
        try audioSession.setCategory(
            .playAndRecord,
            mode: .measurement, // Better quality than .spokenAudio for recognition
            options: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers]
        )
        
        // Configure for optimal voice recording quality
        try audioSession.setPreferredSampleRate(48000) // Higher sample rate for better clarity
        try audioSession.setPreferredIOBufferDuration(0.005) // Lower latency
        
        // Enable audio processing for noise reduction
        if #available(iOS 15.0, *) {
            try audioSession.setSupportsMultichannelContent(true)
        }
        
        // Activate with proper error handling
        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("🎤 Voice Input: Error activating audio session: \(error)")
            // Try once more with basic settings
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        }
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
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.contextualStrings = getContextualStrings() // Add religious context
        
        if #available(iOS 16.0, *) {
            recognitionRequest.addsPunctuation = true
            recognitionRequest.requiresOnDeviceRecognition = false // Use cloud for better accuracy
            
            // Additional accuracy improvements
            recognitionRequest.taskHint = .dictation // Optimize for dictation vs search
        }
        
        if #available(iOS 17.0, *) {
            // Use the most accurate recognition mode available
            recognitionRequest.requiresOnDeviceRecognition = false
            recognitionRequest.contextualStrings = getExtendedContextualStrings()
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if let result = result {
                    let bestTranscription = result.bestTranscription
                    let newText = bestTranscription.formattedString
                    
                    // Calculate confidence score
                    var totalConfidence: Float = 0
                    var segmentCount = 0
                    
                    for segment in bestTranscription.segments {
                        totalConfidence += segment.confidence
                        segmentCount += 1
                    }
                    
                    if segmentCount > 0 {
                        self.transcriptionConfidence = totalConfidence / Float(segmentCount)
                    }
                    
                    // Collect alternative transcriptions for manual correction
                    self.alternativeTranscriptions = result.transcriptions
                        .prefix(3)
                        .map { $0.formattedString }
                        .filter { $0 != newText }
                    
                    // Always update text for live transcription, but prioritize final results
                    if result.isFinal {
                        // Final result - always use it regardless of confidence
                        self.transcribedText = self.enhanceTranscription(newText)
                        self.lastTranscriptionTime = Date()
                        self.retryCount = 0
                        self.voiceInputState = .completed
                    } else if newText != self.transcribedText {
                        // Partial result - update if confidence is reasonable or if it's significantly longer
                        let significantlyLonger = newText.count > self.transcribedText.count + 5
                        
                        if self.transcriptionConfidence > 0.3 || significantlyLonger || self.retryCount >= self.maxRetries {
                            self.transcribedText = self.enhanceTranscription(newText)
                            self.lastTranscriptionTime = Date()
                            self.retryCount = 0
                            self.voiceInputState = .transcribing
                        } else if self.transcriptionConfidence <= 0.3 && self.retryCount < self.maxRetries {
                            // Low confidence - might retry
                            self.retryCount += 1
                        }
                    }
                }
                
                if let error = error {
                    self.handleError(error)
                }
            }
        }
        
        // Setup audio input with optimized settings
        let inputNode = audioEngine.inputNode
        
        // Request higher quality audio format
        let recordingFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 48000, // Higher sample rate
            channels: 1,
            interleaved: false
        ) ?? inputNode.outputFormat(forBus: 0)
        
        // Configure input node for better voice capture
        if let inputFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 48000,
            channels: 1,
            interleaved: false
        ) {
            do {
                try inputNode.setVoiceProcessingEnabled(true) // Enable voice processing
            } catch {
                print("Voice processing not available: \(error)")
            }
        }
        
        // Remove any existing tap before installing new one
        inputNode.removeTap(onBus: 0)
        
        // Use larger buffer size for better accuracy
        inputNode.installTap(onBus: 0, bufferSize: 8192, format: recordingFormat) { [weak self] buffer, _ in
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
    
    private func getContextualStrings() -> [String] {
        // Common religious phrases and terms to help recognition
        return [
            "In Jesus name", "Amen", "Hallelujah", "Praise God",
            "Thank you Lord", "Holy Spirit", "God is good",
            "By His stripes", "Blood of Jesus", "Word of God",
            "I declare", "I believe", "I receive", "I am blessed",
            "Kingdom of God", "Glory to God", "Grace and mercy",
            "Faith over fear", "God's promises", "Spiritual warfare",
            "Prayer warrior", "Testimony", "Breakthrough", "Deliverance"
        ]
    }
    
    private func getExtendedContextualStrings() -> [String] {
        // Extended vocabulary for iOS 17+
        let basic = getContextualStrings()
        let extended = [
            "I speak life", "Prophetic word", "Divine purpose",
            "Godly wisdom", "Heavenly Father", "Christ Jesus",
            "Born again", "Saved by grace", "Walking in faith",
            "Armor of God", "Fruit of the Spirit", "Gift of tongues",
            "Laying on hands", "Fasting and prayer", "Worship and praise",
            "Tithes and offerings", "Mission field", "Great commission"
        ]
        return basic + extended
    }
    
    private func enhanceTranscription(_ text: String) -> String {
        var enhanced = text
        
        // Capitalize spiritual terms with better pattern matching
        let spiritualTerms = [
            "god", "jesus", "christ", "lord", "father", "holy spirit",
            "bible", "scripture", "prayer", "amen", "hallelujah", "praise",
            "blessing", "faith", "grace", "mercy", "salvation", "heaven",
            "gospel", "psalm", "proverbs", "corinthians", "genesis",
            "exodus", "revelation", "matthew", "john", "romans"
        ]
        
        // More sophisticated replacement that handles compound terms
        for term in spiritualTerms {
            let pattern = "\\b\(term)\\b"
            let replacement = term.components(separatedBy: " ")
                .map { $0.capitalized }
                .joined(separator: " ")
            
            enhanced = enhanced.replacingOccurrences(
                of: pattern,
                with: replacement,
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        // Fix common transcription errors
        let corrections = [
            ("i m", "I'm"),
            ("i ve", "I've"),
            ("i ll", "I'll"),
            ("gods", "God's"),
            ("jesus s", "Jesus's"),
            ("isnt", "isn't"),
            ("dont", "don't"),
            ("wont", "won't"),
            ("cant", "can't")
        ]
        
        for (wrong, right) in corrections {
            enhanced = enhanced.replacingOccurrences(
                of: "\\b\(wrong)\\b",
                with: right,
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        // Ensure first letter of sentences is capitalized
        enhanced = enhanced.replacingOccurrences(
            of: "(^|\\. )([a-z])",
            with: "$1$2",
            options: .regularExpression,
            range: nil
        )
        
        return enhanced
    }
    
    private func handleError(_ error: Error) {
        // Check if we should retry
        if retryCount < maxRetries && shouldRetryError(error) {
            retryCount += 1
            errorMessage = "Retrying... (\(retryCount)/\(maxRetries))"
            
            // Wait a moment then retry
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.startListening()
            }
        } else {
            // Stop and show error
            stopListening()
            voiceInputState = .error
            
            errorMessage = getReadableErrorMessage(for: error)
            retryCount = 0
            
            print("❌ Voice input error: \(error)")
        }
    }
    
    private func shouldRetryError(_ error: Error) -> Bool {
        // Retry on temporary network or audio issues
        if let nsError = error as NSError? {
            let retryableCodes = [1, 203, 204, 205] // Audio/network temporary failures
            return retryableCodes.contains(nsError.code)
        }
        return false
    }
    
    private func getReadableErrorMessage(for error: Error) -> String {
        if let nsError = error as NSError? {
            switch nsError.code {
            case 201:
                return "Please check your internet connection"
            case 203, 204, 205:
                return "Audio input error. Please try again"
            case 1700:
                return "Speech recognition is temporarily unavailable"
            default:
                return "Voice input error. Please try again"
            }
        }
        return error.localizedDescription
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
