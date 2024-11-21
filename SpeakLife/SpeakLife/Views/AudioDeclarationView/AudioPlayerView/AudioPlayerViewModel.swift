//
//  AudioPlayerViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/20/24.
//

import SwiftUI
import AVFoundation

class AudioPlayerViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var playbackSpeed: Float = 1.0
    //@Published var downloadProgress: [UUID: Double] = [:]
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    func loadAudio(from url: URL) {
        resetPlayer()
        AudioPlayerService.shared.pauseMusic()
        player = AVPlayer(url: url)
        
        // Get the duration of the audio
        if let duration = player?.currentItem?.asset.duration {
            self.duration = CMTimeGetSeconds(duration)
        }
        
        print("Loading audio from URL: \(url) RWRW")
        print("Player duration: \(CMTimeGetSeconds(player?.currentItem?.duration ?? CMTime.zero)) RWRW")
        
        // Add time observer for playback progress
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
            if let duration = self.player?.currentItem?.duration {
                self.duration = CMTimeGetSeconds(duration)
            }
        }
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        
        isPlaying.toggle()
    }
    
    func seek(to time: Double) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: targetTime)
    }
    
    func changePlaybackSpeed(to speed: Float) {
        playbackSpeed = speed
        player?.rate = speed
    }
    func resetPlayer() {
        // Clean up any previous AVPlayer
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        player?.pause()
        player = nil
    }
    
    deinit {
        AudioPlayerService.shared.playMusic()
        // Remove time observer when deinitialized
        resetPlayer()
    }
}
