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
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
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
            if isPausedInBackground {
                DispatchQueue.main.async { [weak self] in
                    self?.audioPlayer?.play()
                    self?.isPlaying = true
                }
                isPausedInBackground = false
            }
        }


    func playSound(files: [MusicResources]) {
        self.audioFiles = files.shuffled()
        self.currentFileIndex = 0
        let type = audioFiles[currentFileIndex].type
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
        if flag {
            currentFileIndex = (currentFileIndex + 1) % audioFiles.count
            print("Moving to next file: \(audioFiles[currentFileIndex])") // Debugging log
            playFile(type: "mp3") // Assuming all files are mp3
        }
    }
    
    func pauseMusic() {
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.pause()
        }
        isPlaying = false
    }
    
    func playMusic() {
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
        } else if type == .ended {
            // Interruption ended
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    audioPlayer?.play()
                }
            }
        }
    }
}
