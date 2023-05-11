//
//  DevotionalViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/10/23.
//

import Foundation

final class DevotionalViewModel: ObservableObject {
    
    @Published var devotionalText = ""
    @Published var devotionalDate = ""
    @Published var devotionalBooks = ""
    @Published var title = ""
    
    var devotional: Devotional? {
        didSet {
            updateViewModel()
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
        }
        return
    }
}
