//
//  Prayer.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/10/23.
//

import Foundation

struct WelcomePrayers: Decodable {
    let prayers: [Prayer]
}

struct Prayer: Identifiable, Hashable, Decodable {
    
    let prayerText: String
    let category: DeclarationCategory
    let isPremium: Bool
    
    var id: UUID {
        UUID()
    }
}
