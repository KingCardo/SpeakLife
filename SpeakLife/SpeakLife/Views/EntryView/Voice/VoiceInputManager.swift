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
                    
                    // Only update if text actually changed and confidence is reasonable
                    if newText != self.transcribedText && (self.transcriptionConfidence > 0.5 || self.retryCount >= self.maxRetries) {
                        self.transcribedText = self.enhanceTranscription(newText)
                        self.lastTranscriptionTime = Date()
                        self.retryCount = 0
                    } else if self.transcriptionConfidence <= 0.5 && self.retryCount < self.maxRetries {
                        // Low confidence - might retry
                        self.retryCount += 1
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
