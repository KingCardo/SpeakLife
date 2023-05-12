//
//  SpeakLifeApp.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 7/20/22.
//

import SwiftUI
import Combine

@main
struct SpeakLifeApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var appState = AppState()
    @StateObject var declarationStore = DeclarationViewModel(apiService: APIClient())
    @StateObject var themeStore = ThemeViewModel()
    @StateObject var subscriptionStore = SubscriptionStore()
   // @StateObject var timeTracker = TimeTrackerViewModel()
    
    private let fourDaysInSeconds: Double = 345600
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
                .environmentObject(declarationStore)
                .environmentObject(themeStore)
                .environmentObject(subscriptionStore)
            //    .environmentObject(timeTracker)
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .active:
                DispatchQueue.global().async {
                appDelegate.appState = appState
                appDelegate.declarationStore = declarationStore
               
                if appState.lastNotificationSetDate < appState.lastNotificationSetDate.addingTimeInterval(fourDaysInSeconds), appState.notificationEnabled {
                   
                        NotificationManager.shared.registerNotifications(count: appState.notificationCount, startTime: appState.startTimeIndex, endTime: appState.endTimeIndex)
                        DispatchQueue.main.async {
                            appState.lastNotificationSetDate = Date()
                        }
                        
                    }
                }
            case .inactive:
                break
            case .background:
                break
//                DispatchQueue.global().async {
//                    timeTracker.calculateElapsedTime()
//                }
            @unknown default:
                break
            }
        }
    }
}
