//
//  Devotional.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/10/23.
//

import Foundation

struct WelcomeDevotional: Decodable {
    let devotionals: [Devotional]
}

struct Devotional: Decodable, Identifiable {
    let date: Date
    let devotionalText: String
    let books: String
    
    var id: String {
        "\(date) + \(books)"
    }
}
