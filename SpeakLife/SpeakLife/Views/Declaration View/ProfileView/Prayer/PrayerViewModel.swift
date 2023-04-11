//
//  PrayerViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/10/23.
//

import Combine
import SwiftUI

protocol PrayerService {
    func fetchPrayers() async -> [Prayer]
}

final class PrayerServiceClient: PrayerService {
    
    func fetchPrayers() async -> [Prayer] {
        return [Prayer(prayerText: "Praise the Lord", category: .anxiety, isPremium: false),
                Prayer(prayerText: "Praise the Lord", category: .wealth, isPremium: true)
        ]
    }
}

struct SectionData: Identifiable {
    let id = UUID()
    let title: String
    let items: [Prayer]
    var isExpanded: Bool = false
}

final class PrayerViewModel: ObservableObject {
    
    @Published var sectionData: [SectionData] = []
    
    private var prayers: [Prayer] = [] {
        didSet {
            buildSectionData()
        }
    }
    
    private let service: PrayerService
    
    init(service: PrayerService = PrayerServiceClient()) {
        self.service = service
    }
    
    func fetchPrayers() async {
        let prayers = await service.fetchPrayers()
        self.prayers = prayers
    }
    
    private func buildSectionData()  {
       // var sectionData: [SectionData] = []
        
        
        DispatchQueue.main.async { [weak self] in
            self?.sectionData = [SectionData(title: "Fruits", items: [Prayer(prayerText: "Praise the Lord!", category: .wealth, isPremium: false),
                                                 Prayer(prayerText: "Praise the Lord!", category: .anxiety, isPremium: true)
                                                 
            ])
                           ]
        }
        
    }
}
