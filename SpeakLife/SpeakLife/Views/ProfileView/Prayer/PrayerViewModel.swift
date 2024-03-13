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
    let title: String//DeclarationCategory
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
                    self?.sectionData.append(SectionData(title: category.categoryTitle, items: prayers))
                }
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.sectionData.insert(SectionData(title: "God's Protection", items: [Prayer(prayerText: psalm91NLT, category: .godsprotection, isPremium: false)]), at: 0)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.sectionData.insert(SectionData(title: "Salvation Prayer", items: [Prayer(prayerText: salvationPrayer, category: .godsprotection, isPremium: false)]), at: 0)
        }
    }
}
let salvationPrayer = """

Lord Jesus

I repent of all my sins past, present, and future

Come into my heart and be my Lord and Savior!

Thank you for dying for my sins and welcoming me into your Kingdom

where I can live with you for eternity!




You are now born again ✝️🎊🥳
"""
let psalm91NLT = """
Psalm 91

 I live under the protection of the Most High, and I find rest in the shadow of the Almighty.
    
    This I declare about the Lord: He alone is my refuge, my place of safety; He is my God, and I trust Him.
    
    For He rescues me from every trap and protects me from deadly disease.
    
    He covers me with His feathers. Under His wings, I find refuge. His faithful promises are my armor and protection.
    
    I am not afraid of the terrors of the night, nor the arrow that flies in the day.
    
    I do not dread the disease that stalks in darkness, nor the disaster that strikes at midday.
    
    Though a thousand fall at my side, though ten thousand are dying around me, these evils will not touch me.
    
    I open my eyes, and I see how the wicked are punished.
    
    I have made the Lord my refuge; the Most High is my shelter.
    
    No evil will conquer me; no plague will come near my home.
    
    For He orders His angels to protect me wherever I go.
    
    They lift me up with their hands, so I won’t even hurt my foot on a stone.
    
    I will trample upon lions and cobras; I will crush fierce lions and serpents under my feet!
    
    The Lord says, 'I rescue those who love me. I protect those who trust in my name.
    
    When they call on me, I will answer; I will be with them in trouble. I will rescue and honor them.
    
    I will reward them with a long life and give them my salvation.'

"""
