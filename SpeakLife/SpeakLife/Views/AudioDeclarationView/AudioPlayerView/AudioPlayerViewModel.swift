//
//  AudioPlayerViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/20/24.
//

import SwiftUI
import AVFoundation
import Combine
import MediaPlayer

final class AudioPlayerViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var playbackSpeed: Float = 1.0
    @Published var onRepeat = false
    @Published var currentTrack: String = ""
    @Published var subtitle: String = ""
    @Published var imageUrl: String = ""
    @Published var isBarVisible: Bool = false // Manage bar visibility

    private var queue: [URL] = []
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?  // Observer for track end
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest($currentTime, $duration)
            .sink { [weak self] currentTime, duration in
                if (currentTime + 0.05) >= duration {
                    self?.isPlaying = false
                    self?.player?.seek(to: CMTime.zero)
                }
            }
            .store(in: &cancellables)
        setupRemoteCommands()
    }
    
    func loadAudio(from url: URL, isSameItem: Bool) {
        if isPlaying, isSameItem { return }
        resetPlayer()
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
        
        player = AVPlayer(url: url)
        
        // Get the duration of the audio
        if let duration = player?.currentItem?.asset.duration {
            self.duration = CMTimeGetSeconds(duration)
        }
        
        print("Loading audio from URL: \(url)")
        print("Player duration: \(CMTimeGetSeconds(player?.currentItem?.duration ?? CMTime.zero))")
        
        // Add time observer for playback progress
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
            self.updateNowPlayingInfo()
        }
        
        // Add observer for when the audio finishes playing
        endObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            
            if self.onRepeat {
                self.player?.seek(to: CMTime.zero)
                self.player?.play()
            } else if !self.queue.isEmpty {
                // Get next URL from the queue and load it
                let nextURL = self.queue.removeFirst()
                self.loadAudio(from: nextURL, isSameItem: false)
            } else {
                self.isPlaying = false
                self.player?.seek(to: CMTime.zero)
            }
            updateNowPlayingInfo()
        }
        
        togglePlayPause()
        updateNowPlayingInfo()
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
            isPlaying = false
            AudioPlayerService.shared.playMusic()
        } else {
            AudioPlayerService.shared.pauseMusic()
            player.play()
            isPlaying = true
        }
        updateNowPlayingInfo()
        
    }
    
    func seek(to time: Double) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: targetTime)
    }
    
    func repeatTrack() {
        onRepeat.toggle()
    }
    
    func changePlaybackSpeed(to speed: Float) {
        playbackSpeed = speed
        player?.rate = speed
    }
    
    func resetPlayer() {
        // Remove time observer if exists
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        // Remove the end-of-track observer if it exists
        if let endObserver = endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
        player?.pause()
        player = nil
        currentTime = 0
    }
    
    func playNext(_ item: URL?) {
        guard let item = item else { return }
        // Inserts item at the beginning of the queue
        queue.insert(item, at: 0)
    }
    
    func addToQueue(_ item: URL?) {
        guard let item = item else { return }
        // Appends item to the end of the queue
        queue.append(item)
        print("\(item), added to queue")
    }
    
    private func updateNowPlayingInfo() {
        guard let player = player,
              let currentItem = player.currentItem else { return }

        let currentTime = CMTimeGetSeconds(player.currentTime())
        let duration = CMTimeGetSeconds(currentItem.asset.duration)
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: currentTrack,
            MPMediaItemPropertyArtist: subtitle,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        if imageUrl == "devotional" {
            if let image = UIImage(named: "appIconDisplay") { // or fetch async from imageUrl
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                info[MPMediaItemPropertyArtwork] = artwork
            }
        } else {
            if let image = UIImage(named: "heavenStairway") { // or fetch async from imageUrl
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                info[MPMediaItemPropertyArtwork] = artwork
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.player?.play()
            self?.isPlaying = true
            self?.updateNowPlayingInfo()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.player?.pause()
            self?.isPlaying = false
            self?.updateNowPlayingInfo()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let seekEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            self.seek(to: seekEvent.positionTime)
            return .success
        }
    }
    
    deinit {
        resetPlayer()
       // AudioPlayerService.shared.playMusic()
    }
}
