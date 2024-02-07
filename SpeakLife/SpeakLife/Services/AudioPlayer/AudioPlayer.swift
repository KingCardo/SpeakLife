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
        self.audioFiles = files
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
}
