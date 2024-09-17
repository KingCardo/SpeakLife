//
//  PodcastService.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/25/23.
//

import SwiftUI
import AVFoundation

struct Artist: Identifiable {
    let id = UUID()
    let url: String
    let name: String
}


final class PodcastService: ObservableObject {
    
    @Published var podcasts = [Podcast]()
    
    var player: AVPlayer?

    func playPodcast(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        player = AVPlayer(url: url)
        player?.play()
    }

    func fetchPodcasts() {
        guard let url = URL(string: "https://podcasts.apple.com/us/podcast/joel-osteen-podcast/id137254859") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Podcast].self, from: data) {
                    DispatchQueue.main.async {
                        self.podcasts = decodedResponse
                    }
                    return
                }
            }
            // TOD): error handle show alert
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
}
