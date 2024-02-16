//
//  DevotionalService.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/10/23.
//

import Foundation

protocol DevotionalService {
    func fetchDevotionForToday() async -> [Devotional]
    func fetchAllDevotionals() async -> [Devotional]
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
            print(devotionals.count, "RWRW")
            
           
            let todaysDate = Date()
            let calendar = Calendar.current
            let todaysComponents = calendar.dateComponents([.year, .month, .day], from: todaysDate)
            
                let month = todaysComponents.month
                let day = todaysComponents.day
            
            if let today = devotionals.first(where: {
                let devotionalComponents = calendar.dateComponents([.month, .day], from: $0.date)
                let devotionalMonth = devotionalComponents.month
                let devotionalDay = devotionalComponents.day
                return (devotionalMonth, devotionalDay) == (month, day)}) {
                return [today]
            } else {
                return []
            }
            
        } catch {
            print(error, "RWRW")
           return []
        }
    }
    
    func fetchAllDevotionals() async -> [Devotional] {
        guard
            let url = Bundle.main.url(forResource: "devotionals", withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
            print("RWRW file not found")
            return []
        }
        
        do {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let welcome = try decoder.decode(WelcomeDevotional.self, from: data)
            let devotionals = welcome.devotionals
           
            return devotionals
            
        } catch {
            print(error.localizedDescription, "RWRW")
           return []
        }
        
    }
}
