//
//  PrayerViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/10/23.
//

import Combine
import SwiftUI


struct SectionData: Identifiable {
    let id = UUID()
    let title: DeclarationCategory
    let items: [Prayer]
    var isExpanded: Bool = false
}

final class PrayerViewModel: ObservableObject {
    
    @Published var sectionData: [SectionData] = []
    
    @Published var hasError = false
    
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
        guard prayers.isEmpty else { return }
        let prayers = await service.fetchPrayers()
        self.prayers = prayers
    }
    
    private func buildSectionData()  {
        guard !prayers.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.hasError = true
            }
            return
        }
    
        for category in DeclarationCategory.allCases {
            let prayers = prayers.filter { $0.category == category }
            DispatchQueue.main.async { [weak self] in
                if !prayers.isEmpty {
                    self?.sectionData.append(SectionData(title: category, items: prayers))
                }
            }
        }
    }
}
