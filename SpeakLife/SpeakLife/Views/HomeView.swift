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
    
    
    var body: some View {
        if appState.isOnboarded {
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
                
                CreateYourOwnView()
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                            .renderingMode(.original)
                        Text("Yours")
                    }
                
                NavigationStack {
                    LazyView(PrayerView())
                }
                    .tabItem {
                        if #available(iOS 17, *) {
                            Image(systemName: "hands.and.sparkles.fill")
                                .renderingMode(.original)
                        } else {
                            Image(systemName: "hands.clap.fill")
                                .renderingMode(.original)
                        }
                        Text("Prayers")
                    }
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                            .renderingMode(.original)
                        Text("Settings")
                    }
            }
            .accentColor(Constants.DAMidBlue)
        } else {
            OnboardingView()
        }
    }
}
