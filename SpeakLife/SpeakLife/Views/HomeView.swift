//
//  HomeView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 12/17/22.
//

import SwiftUI
import FacebookCore
let resources: [MusicResources] = [.somethinggreater, .mindful, .romanticPiano, .peacefulplace, .returntosurface, .sethpiano, .washed, .rainstorm, .everpresent]

struct MusicResources {
    let name: String
    let artist: String
    let type: String
   
    
    static let somethinggreater = MusicResources(name: "somethinggreater", artist: "Caleb Fincher", type: "mp3")
    static let mindful = MusicResources(name: "mindful", artist: "Zimpzon", type: "mp3")
    static let romanticPiano = MusicResources(name: "romanticpiano", artist: "", type: "mp3")
    static let peacefulplace = MusicResources(name: "peacefulplace", artist: "", type: "mp3")
    static let returntosurface = MusicResources(name: "returntosurface", artist: "", type: "mp3")
    static let sethpiano = MusicResources(name: "sethpiano", artist: "", type: "mp3")
    static let washed = MusicResources(name: "washed", artist: "Brock Hewitt", type: "mp3")
    static let rainstorm = MusicResources(name: "rainstorm", artist: "Brock Hewitt", type: "mp3")
    static let everpresent = MusicResources(name: "everpresent", artist: "Brock Hewitt", type: "mp3")
}

struct HomeView: View {
    
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var themeStore: ThemeViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var devotionalViewModel: DevotionalViewModel
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var viewModel: FacebookTrackingViewModel
    @Binding var isShowingLanding: Bool
   
    @State var showGiftView = false
    @State private var isPresented = false
    
    private let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"

    let data = [true, false]
    var body: some View {
        Group {
            if isShowingLanding {
                LandingView()
            } else if appState.isOnboarded {
                homeView
                    .onAppear() {
                        if appState.firstOpen {
                            appState.firstOpen = false
                        }
                    }
            } else {
                OnboardingView()
                    .onAppear {
                        viewModel.requestPermission()
                }
            }
        }
    }
    
    @ViewBuilder
    var homeView: some View {
            TabView {
                declarationView
                audioView
                devotionalView
                createYourOwnView
                profileView
                
            }
            .hideTabBar(if: appState.showScreenshotLabel)
            .sheet(isPresented: $isPresented) {
                WhatsNewBottomSheet(isPresented: $isPresented, version: currentVersion)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
//            .sheet(isPresented: $appState.needEmail) {
//                EmailBottomSheet(isPresented: $appState.needEmail)
//                    .presentationDetents([.medium])
//                                   .presentationDragIndicator(.visible)
//            }
            .accentColor(Constants.DAMidBlue)
            .onAppear {
                checkForNewVersion()
                UIScrollView.appearance().isScrollEnabled = true
            }
            .environment(\.colorScheme, .dark)
    }
    
    var declarationView: some View {
        DeclarationView()
            .id(appState.rootViewId)
            .tabItem {
                Image(systemName: "house.fill")
                    .renderingMode(.original)
                
            }
    }
    
    var audioView: some View {
        AudioDeclarationView()
            .tabItem {
                if #available(iOS 17, *) {
                    Image(systemName: "waveform")
                        .renderingMode(.original)
                } else {
                    Image(systemName: "waveform")
                        .renderingMode(.original)
                }
            }
            .edgesIgnoringSafeArea(.all)
    }
    
    var devotionalView: some View {
        DevotionalView(viewModel:devotionalViewModel)
            .tabItem {
                if #available(iOS 17, *) {
                    Image(systemName: "book.pages.fill")
                        .renderingMode(.original)
                } else {
                    Image(systemName: "book.fill")
                        .renderingMode(.original)
                }
            }
    }
    
    var createYourOwnView: some View {
        CreateYourOwnView()
            .tabItem {
                Image(systemName: "plus.bubble.fill")
                    .renderingMode(.original)
            }
    }
    
    var profileView: some View {
        ProfileView()
            .tabItem {
                Image(systemName: "line.3.horizontal")
                    .renderingMode(.original)
            }
    }
    
    func presentGiftView() {
        if appState.showGiftViewCount <= 5 {
            showGiftView.toggle()
            appState.showGiftViewCount += 1
        }
    }
    
    private func checkForNewVersion() {
        let lastVersion = UserDefaults.standard.string(forKey: "lastVersion") ?? "0.0.0"
        if lastVersion != currentVersion {
            isPresented = true
            UserDefaults.standard.set(currentVersion, forKey: "lastVersion")
       }
        if currentVersion == "3.0.42" {
            declarationStore.cleanUpSelectedCategories { selectedCategories in
                let categoryString = selectedCategories.map { $0.name }.joined(separator: ",")
                appState.selectedNotificationCategories = categoryString
                declarationStore.save(selectedCategories)
            }
        }
    }
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
    
    func requestPermission() {
        
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            TrackingManager.shared.requestTrackingPermission { status in
                switch status {
                case .notDetermined:
                    Settings.shared.isAdvertiserIDCollectionEnabled = false
                case .restricted:
                    Settings.shared.isAdvertiserIDCollectionEnabled = false
                case .denied:
                    Settings.shared.isAdvertiserIDCollectionEnabled = false
                case .authorized:
                    Settings.shared.isAdvertiserIDCollectionEnabled = true
                @unknown default: break
                }
            }
        }
    }
}
