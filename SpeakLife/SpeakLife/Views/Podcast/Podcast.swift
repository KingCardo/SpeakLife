//
//  Podcast.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/25/23.
//

import Foundation

struct Podcast: Decodable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let url: String // URL of the podcast episode
}
