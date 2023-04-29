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
    
    @ObservedObject var viewModel: DeclarationViewModel
    @ObservedObject var themeViewModel: ThemeViewModel
    @State private var isPresentingView = false
    @State private var isPresentingThemeChooser = false
    @State private var isPresentingCategoryChooser = false
    @State private var isPresentingPremiumView = false
    
    
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
                    if appState.newCategoriesAdded {
                        Badge()
                    }
                }
            }.sheet(isPresented: $isPresentingCategoryChooser, onDismiss: {
                withAnimation {
                    self.isPresentingCategoryChooser = false
                    self.appState.newCategoriesAdded = false
                }
            }, content: {
                CategoryChooserView(viewModel: viewModel)
            })
            .frame(height: 48)
            .padding([.leading, .trailing], Constants.padding)
            .background(themeStore.selectedTheme.mode == .dark ? Constants.backgroundColor : Constants.backgroundColorLight)
            .cornerRadius(Constants.cornerRadius)
            
            Spacer()
            
            CapsuleImageButton(title: "paintbrush.fill") {
                chooseWallPaper()
                Selection.shared.selectionFeedback()
            }.sheet(isPresented: $isPresentingThemeChooser) {
                self.isPresentingThemeChooser = false
            } content: {
                ThemeChooserView(themesViewModel: themeViewModel)
            }
            
            if !subscriptionStore.isPremium {
                CapsuleImageButton(title: "crown.fill") {
                    premiumView()
                    Selection.shared.selectionFeedback()
                }.sheet(isPresented: $isPresentingPremiumView) {
                    self.isPresentingPremiumView = false
                    Analytics.logEvent(Event.tryPremiumAbandoned, parameters: nil)
                } content: {
                    PremiumView()
                }
            }
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isPresentingThemeChooser = false
            self.isPresentingPremiumView = false
            self.isPresentingCategoryChooser = false
        }
        .foregroundColor(.white)
    }
    
    
    // MARK: - Intent(s)
    
    private func chooseWallPaper() {
        self.isPresentingThemeChooser = true
        Analytics.logEvent(Event.themeChangerTapped, parameters: nil)
    }
    
    private func chooseCategory() {
        self.isPresentingCategoryChooser = true
    }
    
    private func premiumView()  {
        self.isPresentingPremiumView = true
        Analytics.logEvent(Event.tryPremiumTapped, parameters: nil)
    }
}


struct IntentsBarView_Previews: PreviewProvider {
    static var previews: some View {
        IntentsBarView(viewModel: DeclarationViewModel(apiService: APIClient()), themeViewModel: ThemeViewModel())
    }
}
