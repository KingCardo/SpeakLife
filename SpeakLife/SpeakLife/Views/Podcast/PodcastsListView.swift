//
//  PodcastsListView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/25/23.
//

import SwiftUI


struct PodcastsListView: View {
    @StateObject var podcastService = PodcastService()

    var body: some View {
        NavigationView {
            List(podcastService.podcasts) { podcast in
                NavigationLink(destination: PodcastDetailView(podcastService: podcastService ,podcast: podcast)) {
                    Text(podcast.title)
                }
            }
            .navigationBarTitle("Listen")
        }
        .onAppear {
            self.podcastService.fetchPodcasts()
        }
    }
}

struct PodcastDetailView: View {
    @ObservedObject var podcastService: PodcastService
    let podcast: Podcast

    var body: some View {
        VStack {
            Text(podcast.title).font(.headline)
            Text(podcast.description).font(.body)
            Button("Play") {
                playPodcast(urlString: podcast.url)
            }
        }
    }
    
    func playPodcast(urlString: String) {
        podcastService.playPodcast(urlString: urlString)
    }
}
