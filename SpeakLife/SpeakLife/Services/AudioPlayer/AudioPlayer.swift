//
//  AudioPlayer.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 1/20/24.
//

import AVFoundation
import UIKit

class AudioPlayerService: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerService()
    private var audioPlayer: AVAudioPlayer?
    private var audioFiles: [MusicResources] = []
    private var currentFileIndex = 0
    private var isPausedInBackground = false
    var isPlaying = false
    
    var currentArtist: String?
    var currentTitle: String?
    
    private override init() {
           super.init()
           NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
        
        // Don't activate audio session on init - only when actually playing
        // This prevents audio session conflicts
    }

       deinit {
           NotificationCenter.default.removeObserver(self)
       }
    
    
    @objc private func appDidEnterBackground() {
            if audioPlayer?.isPlaying == true {
                DispatchQueue.main.async { [weak self] in
                    self?.audioPlayer?.pause()
                    self?.isPlaying = false
                }
                isPausedInBackground = true
            }
        }

        @objc private func appWillEnterForeground() {
            // Don't automatically resume playback when returning to foreground
            // User must explicitly press play
            isPausedInBackground = false
        }


    func playSound(files: [MusicResources]) {
        // Setup audio session only when actually playing
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        self.audioFiles = files.shuffled()
        self.currentFileIndex = 0
        let type = audioFiles[currentFileIndex].type
        currentArtist = audioFiles[currentFileIndex].artist
        currentTitle = audioFiles[currentFileIndex].name
        playFile(type: type)
    }

    private func playFile(type: String) {
        guard !audioFiles.isEmpty else { return }
        let name = audioFiles[currentFileIndex].name
        print("Playing file: \(name)") // Debugging log
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.delegate = self
                DispatchQueue.main.async { [weak self] in
                    self?.audioPlayer?.prepareToPlay()
                    self?.audioPlayer?.play()
                }
                isPlaying = true
            } catch {
                print("Unable to locate audio file: \(name).\(type)")
            }
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag && isPlaying {  // Only continue if we're actively playing
            currentFileIndex = (currentFileIndex + 1) % audioFiles.count
            print("Moving to next file: \(audioFiles[currentFileIndex])") // Debugging log
            playFile(type: "mp3") // Assuming all files are mp3
        } else {
            // Stop playback if we're not actively playing
            isPlaying = false
        }
    }
    
    func pauseMusic() {
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.pause()
        }
        isPlaying = false
    }
    
    func stopMusic() {
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.stop()
            self?.audioPlayer = nil
        }
        isPlaying = false
        isPausedInBackground = false
        audioFiles = []
        
        // Deactivate audio session when stopping
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    func playMusic() {
        // Only play if we have audio files loaded
        guard !audioFiles.isEmpty else { return }
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.play()
        }
        isPlaying = true
    }
    
    

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        if type == .began {
            // Audio session was interrupted
            audioPlayer?.pause()
            isPlaying = false
        } else if type == .ended {
            // Interruption ended - don't automatically resume
            // User must explicitly press play to resume
            // This prevents unwanted audio playback
        }
    }
}
