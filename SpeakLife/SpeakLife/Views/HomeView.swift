//
//  HomeView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 12/17/22.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var themeStore: ThemeViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var devotionalViewModel: DevotionalViewModel
    @Binding var isShowingLanding: Bool
    
    var body: some View {
        Group {
            if isShowingLanding {
                LandingView()
            } else if appState.isOnboarded {
                TabView {
                    DeclarationView(viewModel: _declarationStore, themeViewModel: _themeStore)
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
                    
                    
                    CreateYourOwnView()
                        .tabItem {
                            Image(systemName: "plus.bubble.fill")
                                .renderingMode(.original)
                            Text("Yours")
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
            } else {
                OnboardingView()
            }
        }
    }
}
