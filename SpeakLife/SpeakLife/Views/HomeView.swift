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
    
    
    var body: some View {
        if appState.isOnboarded {
            DeclarationView(viewModel: _declarationStore, themeViewModel: _themeStore)
            .id(appState.rootViewId)
        } else {
            OnboardingView()
        }
    }
}
