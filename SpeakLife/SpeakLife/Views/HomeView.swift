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
                        Text("Home")
                    }
                
                DevotionalView(viewModel:devotionalViewModel)
                    .tabItem {
                        Image(systemName: "book.pages.fill")
                        Text("Devotionals")
                    }
                
                CreateYourOwnView()
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Yours")
                    }
                
                NavigationStack {
                    LazyView(PrayerView())
                }
                
              //  NavigationView(LocalizedStringKey("Prayers"), destination: LazyView(PrayerView()))
              //  PrayerView()
                    .tabItem {
                        Image(systemName: "hands.and.sparkles.fill")
                        Text("Prayers")
                    }
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Settings")
                    }
            }
            .accentColor(Constants.DAMidBlue)
        } else {
            OnboardingView()
        }
    }
}
