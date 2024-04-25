//
//  HomeView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 12/17/22.
//

import SwiftUI
import FacebookCore

let resources: [MusicResources] = [.romanticPiano, .peacefulplace, .returntosurface, .sethpiano, .washed, .rainstorm, .everpresent]

struct MusicResources {
    let name: String
    let type: String
    
    static let romanticPiano = MusicResources(name: "romanticpiano", type: "mp3")
    static let peacefulplace = MusicResources(name: "peacefulplace", type: "mp3")
    static let returntosurface = MusicResources(name: "returntosurface", type: "mp3")
    static let sethpiano = MusicResources(name: "sethpiano", type: "mp3")
    static let washed = MusicResources(name: "washed", type: "mp3")
    static let rainstorm = MusicResources(name: "rainstorm", type: "mp3")
    static let everpresent = MusicResources(name: "everpresent", type: "mp3")
}

struct HomeView: View {
    
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var themeStore: ThemeViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var devotionalViewModel: DevotionalViewModel
    @EnvironmentObject var timerViewModel: TimerViewModel
    @Binding var isShowingLanding: Bool
    @StateObject private var viewModel = FacebookTrackingViewModel()

    
    var body: some View {
        Group {
            if isShowingLanding {
                LandingView()
            } else if appState.isOnboarded {
                homeView
            } else {
                OnboardingView()
            }
        }
    }
    
    @ViewBuilder
    var homeView: some View {
        if appState.onBoardingTest {
            DeclarationView()
                .id(appState.rootViewId)
                .onAppear {
                    viewModel.requestPermission()
                    UIScrollView.appearance().isScrollEnabled = true
                    if declarationStore.backgroundMusicEnabled && !AudioPlayerService.shared.isPlaying {
                        AudioPlayerService.shared.playSound(files: resources)
                    }
                }
                .environment(\.colorScheme, .dark)
        } else {
            TabView {
                DeclarationView()
                    .id(appState.rootViewId)
                    .tabItem {
                        Image(systemName: "house.fill")
                            .renderingMode(.original)
                        Text("Home")
                    }
                
                DevotionalView(viewModel:devotionalViewModel)
                    .tabItem {
                        if #available(iOS 17, *) {
                            Image(systemName: "book.pages.fill")
                                .renderingMode(.original)
                        } else {
                            Image(systemName: "book.fill")
                                .renderingMode(.original)
                        }
                        Text("Devotionals")
                    }
                
                CreateYourOwnView()
                    .tabItem {
                        Image(systemName: "plus.bubble.fill")
                            .renderingMode(.original)
                        Text("Yours")
                    }
                
                WarriorView()
                    .tabItem {
                        if #available(iOS 17, *) {
                            Image(systemName: "bolt.shield.fill")
                                .renderingMode(.original)
                        } else {
                            Image(systemName: "bolt.shield")
                                .renderingMode(.original)
                        }
                        Text("Prayers")
                    }
               
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "line.3.horizontal")
                            .renderingMode(.original)
                        Text("More")
                    }
            }
            .hideTabBar(if: appState.showScreenshotLabel)
            .accentColor(Constants.DAMidBlue)
            .onAppear {
                viewModel.requestPermission()
                UIScrollView.appearance().isScrollEnabled = true
                if declarationStore.backgroundMusicEnabled && !AudioPlayerService.shared.isPlaying {
                    AudioPlayerService.shared.playSound(files: resources)
                }
            }
            .environment(\.colorScheme, .dark)
        }
    }
    
//    func requestReview() {
//        declarationStore.requestReview.toggle()
//        appState.helpUsGrowCount += 1
//    }
}


import AppTrackingTransparency
import AdSupport

class TrackingManager {
    static let shared = TrackingManager()

    func requestTrackingPermission(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
}

class FacebookTrackingViewModel: ObservableObject {
    @Published var trackingStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    
    func requestPermission() {
        
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            TrackingManager.shared.requestTrackingPermission { status in
                switch status {
                case .notDetermined: Settings.shared.isAdvertiserTrackingEnabled = false
                    Settings.shared.isAdvertiserIDCollectionEnabled = false
                case .restricted: Settings.shared.isAdvertiserTrackingEnabled = false
                    Settings.shared.isAdvertiserIDCollectionEnabled = false
                case .denied: Settings.shared.isAdvertiserTrackingEnabled = false
                    Settings.shared.isAdvertiserIDCollectionEnabled = false
                case .authorized: Settings.shared.isAdvertiserTrackingEnabled = true
                    Settings.shared.isAdvertiserIDCollectionEnabled = true
                @unknown default: break
                }
            }
        }
    }
}
