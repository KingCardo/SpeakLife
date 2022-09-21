//
//  SpeakLifeApp.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 7/20/22.
//

import SwiftUI

@main
struct SpeakLifeApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var appState = AppState()
    @StateObject var declarationStore = DeclarationViewModel(apiService: APIClient())
    @StateObject var themeStore = ThemeViewModel()
    @StateObject var storeManager = StoreManager.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
                .environmentObject(declarationStore)
                .environmentObject(themeStore)
                .environmentObject(storeManager)
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .active:
                appDelegate.appState = appState
                appDelegate.declarationStore = declarationStore
                updatePremiumAppState()
                appstatePremiumUpdate()
            case .inactive:
                break
            case .background:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func appstatePremiumUpdate() {
        appDelegate.updateAppState = {
            updatePremiumAppState()
        }
    }
    
    private func updatePremiumAppState() {
        let yearly = storeManager.isPurchased(with: InAppId.revampYearlyId)
        let lifetime = storeManager.isPurchased(with: InAppId.revampLifetime)
        let monthly = storeManager.isPurchased(with: InAppId.revampMonthlyId)
        appState.isPremium = yearly || lifetime || monthly
    }
}
