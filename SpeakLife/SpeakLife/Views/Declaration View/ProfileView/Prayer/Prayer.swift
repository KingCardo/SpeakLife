//
//  Prayer.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/10/23.
//

import Foundation

struct Prayer: Identifiable, Hashable {
    
    let prayerText: String
    private(set) var isFavorite = false
    let category: DeclarationCategory
    let isPremium: Bool
    let id = UUID()
}
