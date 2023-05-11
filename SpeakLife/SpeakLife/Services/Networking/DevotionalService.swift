//
//  DevotionalService.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/10/23.
//

import Foundation

protocol DevotionalService {
    func fetchDevotionForToday() async -> [Devotional]
}

final class DevotionalServiceClient: DevotionalService {
    
    func fetchDevotionForToday() async -> [Devotional] {
        
        guard
            let url = Bundle.main.url(forResource: "devotionals", withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
            return []
        }
        
        do {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let welcome = try decoder.decode(WelcomeDevotional.self, from: data)
            let devotionals = welcome.devotionals
            
           
            let todaysDate = Date()
            if let today = devotionals.first(where: { dateFormatter.string(from: $0.date) == dateFormatter.string(from: todaysDate) }) {
                return [today]
            } else {
                return []
            }
            
        } catch {
            print(error)
           return []
        }
    }
}
