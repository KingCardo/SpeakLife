//
//  AppConfig.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 2/10/25.
//

import Firebase
import SwiftUI
import FirebaseRemoteConfig

class AppConfigViewModel: ObservableObject {
    @Published var showDevotionalSubscription = false
    @Published var showOneTimeSubscription = false
    
    @Published var yearlySubscription = ""
    @Published var discountSubscription = ""

    private var remoteConfig = RemoteConfig.remoteConfig()

    init() {
        fetchRemoteConfig()
    }
    
    func fetchRemoteConfig() {
        
        remoteConfig.fetchAndActivate { [weak self] status, error in
            guard let self = self else { return }
            if let error = error {
                print("Remote Config fetch failed: \(error.localizedDescription)")
                return
            }
            
            self.updateConfigValues()
        }
    }

    private func updateConfigValues() {
        showDevotionalSubscription = remoteConfig["showDevotionalSubscription"].boolValue
        showOneTimeSubscription = remoteConfig["showOneTimeSubscription"].boolValue
//        yearlySubscription = remoteConfig["currentPremiumID"].stringValue ?? "SpeakLife1YR29"
//        discountSubscription = remoteConfig["discountID"].stringValue ?? "SpeakLife1YR19"

    }
}
