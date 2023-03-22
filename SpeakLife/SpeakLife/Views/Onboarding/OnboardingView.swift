//
//  OnboardingView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/7/22.
//

import SwiftUI
import FirebaseAnalytics

struct OnboardingView: View  {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    @State var selection: Tab = .intro
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selection) {
                
                IntroScene(size: geometry.size, callBack: advance)
                    .tag(Tab.intro)
                
                NotificationOnboarding(size: geometry.size) {
                    advance()
                }
                    .tag(Tab.notification)
                
                WidgetScene(size: geometry.size) {
                    dismissOnboarding()
                   // advance()
                }
                    .tag(Tab.widgets)
            
                
                //                categoryScene()
                //                    .tag(Tab.category)
                
//                subscriptionScene(size: geometry.size)
//                    .tag(Tab.subscription)
                
                
            }
            .ignoresSafeArea()
            .tabViewStyle(.page(indexDisplayMode: .always))
            .font(.headline)
        }
        .preferredColorScheme(.light)
        
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
        Text("categroy")
    }
    
    private func subscriptionScene(size: CGSize) -> some View  {
        
        ZStack {
            SubscriptionView(size: size) {
                advance()
            }
            
            VStack  {
                HStack  {
                    Button(action:  dismissOnboarding) {
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
    
    // MARK: - Private methods
    
    private func advance() {
        withAnimation {
            switch selection {
            case .intro:
                selection = .notification
            case .notification:
                askNotificationPermission()
            case .widgets:
               
                selection = .subscription
            case .subscription:
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
    
    private func dismissOnboarding() {
        withAnimation {
            appState.isOnboarded = true
            Analytics.logEvent(Event.onBoardingFinished, parameters: nil)
        }
    }
    
    private func registerNotifications() {
        if appState.notificationEnabled {
            NotificationManager.shared.registerNotifications(count: appState.notificationCount,
                                                             startTime: appState.startTimeIndex,
                                                             endTime: appState.endTimeIndex,
                                                             categories: nil)
            appState.lastNotificationSetDate = Date()
        }
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}




