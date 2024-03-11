//
//  ReminderView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/3/22.
//

import SwiftUI
import BackgroundTasks
import FirebaseAnalytics

final class ReminderViewModel: ObservableObject {
    private let reminders: [Reminder] = [
        Reminder(category: .faith, reminderCount: 4, startTime: Date(), endTime: Date(), repeatDays: [], sound: nil)]
    var notificationsIsEnabled: Bool = false
    
    var reminderCellViewModel: [ReminderCellViewModel] {
        reminders.map { ReminderCellViewModel($0) }
    }
    
}
struct ReminderView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var declarationViewModel: DeclarationViewModel
    @State private var showAlert = false
    
    let reminderViewModel: ReminderViewModel
   
    var body: some View {
        GeometryReader { geometry in
                ScrollView  {
                    Text("Set up your daily reminders to make your declaration's fit your daily routine", comment: "setup reminder")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(.caption)
                        .padding()
                    ForEach(reminderViewModel.reminderCellViewModel) { reminderVM in
                        ReminderCell(reminderVM)
                            .cornerRadius(8)
                            .padding()
                    }
                
                }
                .navigationTitle(LocalizedStringKey("Reminders"))
    
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notifications are not enabled on this device", comment: "notifications not enabled"),
                message: Text("Go to Settings", comment: "go to settings"),
                dismissButton: .default(Text("Settings", comment: "settings alert"), action: goToSettings)
            )
        }
        
        .onDisappear {
            registerNotifications()
        }
        .onAppear() {
            Analytics.logEvent(Event.remindersTapped, parameters: nil)
            askNotificationPermission() { showAlert in
                self.showAlert = showAlert
            }
        }
    }
    
    private func registerNotifications() {
        if appState.notificationEnabled {
            if declarationViewModel.selectedCategories.count == 0 {
                NotificationManager.shared.registerNotifications(count: appState.notificationCount,
                                                                 startTime: appState.startTimeIndex,
                                                                 endTime: appState.endTimeIndex,
                                                                 categories: nil)
                
            } else {
            NotificationManager.shared.registerNotifications(count: appState.notificationCount,
                                                             startTime: appState.startTimeIndex,
                                                             endTime: appState.endTimeIndex,
                                                             categories: declarationViewModel.selectedCategories) {
                declarationViewModel.errorAlert.toggle()
                
            }
            }
        }
        appState.lastNotificationSetDate = Date()
    }
    private func scheduleNotificationRequest() {

        let eighteenHours = TimeInterval(18 * 60  * 60)

        let request = BGAppRefreshTaskRequest(identifier: "com.speaklife.updateNotificationContent")
        request.earliestBeginDate = Date(timeIntervalSinceNow: eighteenHours)
        
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule notification cleaning: \(error)")
        }
        
    }
    
    private func goToSettings(){
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:],
                completionHandler: nil)
            }
    }
    
    private func askNotificationPermission(completion: @escaping(Bool) -> Void) {
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                    (settings.authorizationStatus == .provisional) else {
                DispatchQueue.main.async {
                    appState.notificationEnabled = true
                    completion(true)
                }
                return
            }
            completion(false)
            return
        }
    }
}
