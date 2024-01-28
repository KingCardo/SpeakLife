//
//  OnboardingView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/7/22.
//

import SwiftUI
import FirebaseAnalytics


struct OnboardingView: View  {
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: DeclarationViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var selection: Tab = .personalization
    @State var showLastChanceAlert = false
    @State var isDonePersonalization = false
    @StateObject var improvementViewModel = ImprovementViewModel()
    
    @ViewBuilder
    func loadingView(geometry: GeometryProxy) -> some View {
        if isDonePersonalization {
            
        } else {
            PersonalizationLoadingView(size: geometry.size, callBack: advance)
                .tag(Tab.loading)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selection) {
                PersonalizationScene(size: geometry.size, callBack: advance)
                    .tag(Tab.personalization)
                
                NameScene(size:  geometry.size, callBack: advance)
                    .tag(Tab.name)
                
                HabitScene(size: geometry.size, callBack: advance)
                    .tag(Tab.habit)
                
                ImprovementScene(size: geometry.size, callBack: advance, viewModel: improvementViewModel)
                    .tag(Tab.improvement)
                
                IntroScene(size: geometry.size, callBack: advance)
                    .tag(Tab.intro)
                
//                BenefitScene(size: geometry.size, tips: onboardingTips) {
//                    advance()
//                }.tag(Tab.benefits)
                
                
                NotificationOnboarding(size: geometry.size) {
                    advance()
                }
                .tag(Tab.notification)
                
//                UseCaseScene(size: geometry.size) {
//                    advance()
//                }.tag(Tab.useCase)
                
               
                
                WidgetScene(size: geometry.size) {
                    advance()
                }
                .tag(Tab.widgets)
                
                loadingView(geometry: geometry)
                    .tag(Tab.loading)
                
                
                subscriptionScene(size: geometry.size)
                    .tag(Tab.subscription)
                
              
                //                categoryScene()
                //                    .tag(Tab.category)
                
                
                
//                discountScene(size: geometry.size)
//                    .tag(Tab.discount)
                
            }
            .ignoresSafeArea()
            .tabViewStyle(.page(indexDisplayMode: .never))
            .font(.headline)
        }
        .preferredColorScheme(.light)
        .alert(isPresented: $showLastChanceAlert) {
            Alert(
                           title: Text("Last chance to save 50%"),
                           message: Text("Are you sure you want to pass?"),
                           primaryButton: .default(Text("Yes I'm sure")) {
                               dismissOnboarding()
                           },
                           secondaryButton: .cancel(Text("Cancel")) {
                               
                           }
                       )
        }
        
        .onAppear {
            setupAppearance()
            Analytics.logEvent(Event.freshInstall, parameters: nil)
        }
    }
    
    private var foregroundColor: Color {
        colorScheme == .dark ? .white : Constants.DEABlack
    }
    
    // MARK: - Private Views
    
    
    private func categoryScene() -> some View {
        Text("category")
    }
    
    private func subscriptionScene(size: CGSize) -> some View  {
        
        ZStack {
            SubscriptionView(size: size) {
                advance()
            }
            
            VStack  {
                HStack  {
                    Button(action:  advance) {
                        Text("CANCEL",  comment: "Cancel text for label")
                            .font(.callout)
                            .frame(height: 35)
                            .foregroundColor(.black)
                        
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
        }
    }
    
    private func discountScene(size: CGSize) -> some View  {
        
        ZStack {
            DiscountSubscriptionView(size: size) {
                advance()
            }
            
            VStack  {
                HStack  {
                    Button(action:  showAlertIfNeededAndDismissOnboarding) {
                        Text("CANCEL",  comment: "Cancel text for label")
                            .font(.callout)
                            .frame(height: 35)
                            .foregroundColor(.black)
                        
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
        }
    }
    
    func showAlertIfNeededAndDismissOnboarding() {
        if !subscriptionStore.isPremium {
            showLastChanceAlert = true
        } else {
            dismissOnboarding()
        }
    }
    
    // MARK: - Private methods
    
    private func advance() {
        withAnimation {
            switch selection {
            case .personalization:
                selection = .name
                Analytics.logEvent("WelcomeScreenDone", parameters: nil)
            case .name:
                selection = .habit
                Analytics.logEvent("NameScreenDone", parameters: nil)
            case .habit:
                selection = .improvement
                Analytics.logEvent("HabitScreenDone", parameters: nil)
            case .improvement:
                appState.selectedNotificationCategories = improvementViewModel.selectedCategories
                selection = .intro
                Analytics.logEvent("ImprovementScreenDone", parameters: nil)
            case .intro:
                selection = .notification
                Analytics.logEvent("IntroScreenDone", parameters: nil)
            case .benefits:
                selection = .notification
                Analytics.logEvent("BenefitScreenDone", parameters: nil)
            case .notification:
                askNotificationPermission()
                Analytics.logEvent("NotificationScreenDone", parameters: nil)
            case .useCase:
                selection = .widgets
              
            case .subscription:
                let categoryString = appState.selectedNotificationCategories.components(separatedBy: ",").first ?? "destiny"
                if let category = DeclarationCategory(categoryString) {
                    viewModel.choose(category) { _ in }
                }
                dismissOnboarding()
                Analytics.logEvent("SubscriptionScreenDone", parameters: nil)
               // selection = .widgets
            case .widgets:
                if isDonePersonalization {
                    selection = .subscription
                } else {
                    selection = .loading
                }
                
            case .loading:
                Analytics.logEvent("LoadingScreenDone", parameters: nil)
                selection = .subscription
                isDonePersonalization = true
            //    dismissOnboarding()
            case .discount:
                dismissOnboarding()
            }
        }
    }
    
    private func askNotificationPermission()  {
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                    (settings.authorizationStatus == .provisional) else {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    
                    DispatchQueue.main.async {
                        if let _ = error {
                            appState.notificationEnabled = false
                            //return
                            // Handle the error here.
                        }
                        
                        if granted {
                            appState.notificationEnabled = true
                            registerNotifications()
                            
                        } else {
                            appState.notificationEnabled = false
                            // return
                        }
                        
                        withAnimation {
                           // advance()
                            selection = .widgets
                        }
                    }
                }
                return
            }
            
            
            withAnimation {
                selection = .widgets
            }
            
            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification.
            } else {
                // Schedule a notification with a badge and sound.
            }
        }
    }
    
    private func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Constants.DALightBlue)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Constants.DALightBlue).withAlphaComponent(0.2)
    }
    
    private func moveToDiscount() {
        if subscriptionStore.isPremium {
            withAnimation {
                appState.isOnboarded = true
                Analytics.logEvent(Event.onBoardingFinished, parameters: nil)
            }
            
        } else {
            selection = .discount
        }
    }
    
    private func dismissOnboarding() {
        withAnimation {
            appState.isOnboarded = true
            Analytics.logEvent(Event.onBoardingFinished, parameters: nil)
        }
        
    }
    
    private func registerNotifications() {
        if appState.notificationEnabled {
            let categories = Set(appState.selectedNotificationCategories.components(separatedBy: ",").compactMap({ DeclarationCategory($0) }))
            NotificationManager.shared.registerNotifications(count: appState.notificationCount,
                                                             startTime: appState.startTimeIndex,
                                                             endTime: appState.endTimeIndex,
                                                             categories: categories)
            appState.lastNotificationSetDate = Date()
        }
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

