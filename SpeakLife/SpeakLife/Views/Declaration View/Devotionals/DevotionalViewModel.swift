//
//  DevotionalViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/10/23.
//

import SwiftUI

final class DevotionalViewModel: ObservableObject {
    
    @AppStorage ("devotionalDictionary") var devotionalDictionaryData = Data()
    
    @Published var devotionalText = ""
    @Published var devotionalDate = ""
    @Published var devotionalBooks = ""
    @Published var title = ""
    @Published var hasError = false
    let errorString = "Upgrade to the latest version for Today's Devotional."
    private let freeCount = 5
    
    var devotional: Devotional? {
        didSet {
            updateViewModel()
        }
    }
    
    var devotionalDictionary: [DateComponents: Bool] {
        get {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([DateComponents: Bool].self, from: devotionalDictionaryData) {
                return decoded
            } else {
                return [:]  // Return an empty dictionary as a default value
            }
        }
        
        set  {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                devotionalDictionaryData = encoded
            }
        }
    }
    
    var devotionalsLeft: Int {
        if !devotionalLimitReached {
            return freeCount - devotionalDictionary.count
        }
        return 0
    }
    
    var devotionalLimitReached: Bool {
        devotionalDictionary.count > 5
    }
    
    private func setDevotionalDictionary() {
        let date = Date()

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        // means we added the date user looked at devotional already
        if let _ = devotionalDictionary[components] {
            
        } else {
            devotionalDictionary[components] = true
        }
        
    }
    
    private let service: DevotionalService
    
    init(service: DevotionalService = DevotionalServiceClient()) {
        self.service = service
    }
    
    private func updateViewModel() {
        guard let devotional = devotional else { return }
        devotionalText = devotional.devotionalText
        devotionalDate = devotional.date.toSimpleDate()
        devotionalBooks = devotional.books
        title = devotional.title
    }
    
    func fetchDevotional() async {
        if let devotional = await service.fetchDevotionForToday().first {
            DispatchQueue.main.async { [weak self] in
                self?.devotional = devotional
            }
            setDevotionalDictionary()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.hasError = true
            }
        }
        return
    }
}
