//
//  IntentsBarView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/2/22.
//

import SwiftUI
import FirebaseAnalytics

struct IntentsBarView: View {
    
    // MARK: - Properties
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeStore: ThemeViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    @ObservedObject var viewModel: DeclarationViewModel
    @ObservedObject var themeViewModel: ThemeViewModel
    @State private var isPresentingView = false
    @State private var isPresentingThemeChooser = false
    @State private var isPresentingCategoryChooser = false
    @State private var isPresentingPremiumView = false
    @State private var isPresentingProfileView = false
    @State private var showEntryView = false
    
    
    var body: some View {
        HStack(spacing: 8) {
            Button {
                chooseCategory()
                Selection.shared.selectionFeedback()
            } label: {
                HStack {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.callout)
                    Text(viewModel.selectedCategory.categoryTitle)
                        .font(.callout)
                    if appState.newCategoriesAddedv4 {
                        Badge()
                    }
                }
            }.sheet(isPresented: $isPresentingCategoryChooser, onDismiss: {
                withAnimation {
                    self.isPresentingCategoryChooser = false
                    self.appState.newCategoriesAddedv4 = false
                    if appState.onBoardingTest {
                        timerViewModel.loadRemainingTime()
                        timerViewModel.startTimer()
                    }
                }
            }, content: {
                CategoryChooserView(viewModel: viewModel)
            })
            .frame(height: 48)
            .padding([.leading, .trailing], Constants.padding)
            .background(themeStore.selectedTheme.mode == .dark ? Constants.backgroundColor : Constants.backgroundColorLight)
            .cornerRadius(Constants.cornerRadius)
            
            
            Spacer()
            HStack(spacing: 8) {
                CapsuleImageButton(title: "paintbrush.fill") {
                    chooseWallPaper()
                    Selection.shared.selectionFeedback()
                }.sheet(isPresented: $isPresentingThemeChooser) {
                    self.isPresentingThemeChooser = false
                    if appState.onBoardingTest {
                        timerViewModel.loadRemainingTime()
                        timerViewModel.startTimer()
                    }
                } content: {
                    ThemeChooserView(themesViewModel: themeViewModel)
                }
                
                if appState.onBoardingTest {
                    CapsuleImageButton(title: "person.crop.circle") {
                        profileButtonTapped()
                        Selection.shared.selectionFeedback()
                    }.sheet(isPresented: $isPresentingProfileView, onDismiss: {
                        self.isPresentingProfileView = false
                        timerViewModel.loadRemainingTime()
                        timerViewModel.startTimer()
                    }, content: {
                        ProfileView()
                    })
                    //.foregroundColor(.white)
                  //  ProfileBarButton(viewModel: ProfileBarButtonViewModel())
                }
            }
            
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isPresentingThemeChooser = false
            self.isPresentingPremiumView = false
            self.isPresentingCategoryChooser = false
            self.showEntryView = false
            self.isPresentingProfileView = false
        }
        .foregroundColor(.white)
    }
    
    
    // MARK: - Intent(s)
    
    private func chooseWallPaper() {
        timerViewModel.saveRemainingTime()
        self.isPresentingThemeChooser = true
        Analytics.logEvent(Event.themeChangerTapped, parameters: nil)
    }
    
    private func profileButtonTapped() {
        timerViewModel.saveRemainingTime()
        self.isPresentingProfileView = true
    }
    
    private func chooseCategory() {
        timerViewModel.saveRemainingTime()
        self.isPresentingCategoryChooser = true
    }
    
    private func premiumView()  {
        self.isPresentingPremiumView = true
        Analytics.logEvent(Event.tryPremiumTapped, parameters: nil)
    }
}
