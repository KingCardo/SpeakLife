//
//  NotificationScene.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 3/29/22.
//

import SwiftUI

struct NotificationOnboarding:  View {
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    
    let size: CGSize
    let callBack: (() -> Void)
    
    var body: some View  {
        notificationSceneAlt(size: size)
    }
    
    private func notificationSceneAlt(size: CGSize) -> some View  {
        VStack {
            
            if appState.onBoardingTest {
                Spacer().frame(height: 30)
            } else {
                Spacer().frame(height: 50)
                
                Image("Notifications_illustration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 235, height: size.height * 0.20)
                Spacer().frame(height: 20)
            }
            
            VStack {
                Text("Stay Connected Throughout Your Days", comment: "Notification onboarding title")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.center)
                    .foregroundColor(appState.onBoardingTest ? .white : Constants.DEABlack)
                
                Spacer().frame(height: 16)
                
                VStack {
                    Text("Choose how often and when you’d like to be inspired.", comment: "Setup notifications instructions")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .lineLimit(2)
                }
                .frame(width: size.width * 0.8)
                
                Spacer().frame(height: 28)
                
                VStack (spacing: 16) {
                StepperNotificationCountView(appState.notificationCount) { valueCount in
                    appState.notificationCount = valueCount
                    
                }
                .foregroundColor(appState.onBoardingTest ? .white : Constants.DEABlack)
                .frame(width: size.width * 0.87 ,height: size.height * 0.09)
               
                
                TimeNotificationCountView(value: appState.startTimeIndex) {
                    Text("Start_time", comment: "notification start time")
                    
                } valueTime:  { valueTime in
                    appState.startTimeNotification = valueTime
                } valueIndex: { valueIndex in
                    appState.startTimeIndex = valueIndex
                }
                
                .foregroundColor(appState.onBoardingTest ? .white : Constants.DEABlack)
                .frame(width: size.width * 0.87 ,height: size.height * 0.09)

                TimeNotificationCountView(value: appState.endTimeIndex) {
                    Text("End_time", comment: "notification end time")
                } valueTime: { valueTime in
                    appState.endTimeNotification = valueTime
                } valueIndex: { valueIndex in
                    appState.endTimeIndex = valueIndex
                }
                .foregroundColor(appState.onBoardingTest ? .white : Constants.DEABlack)
               
                .frame(width: size.width * 0.87 ,height: size.height * 0.09)
                }

                Spacer()
                
                
            }
            
            ShimmerButton(colors: [.blue], buttonTitle: "Save My Preferences", action: callBack)
            .frame(width: size.width * 0.87 ,height: 50)
           // .shadow(color: Constants.DAMidBlue, radius: 8, x: 0, y: 10)
            
            Spacer()
                .frame(width: 5, height: size.height * 0.07)
        }
        .frame(width: size.width, height: size.height)
        .background(
            ZStack {
                Image(subscriptionStore.testGroup == 0 ? subscriptionStore.onboardingBGImage : onboardingBGImage2)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                Color.black.opacity(subscriptionStore.testGroup == 0 ? 0.1 : 0.2)
                    .edgesIgnoringSafeArea(.all)
            }
        )
    }
    
}
