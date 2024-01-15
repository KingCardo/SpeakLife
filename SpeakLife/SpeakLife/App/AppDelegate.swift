//
//  AppDelegate.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/30/22.
//

import UIKit
import BackgroundTasks
import FirebaseCore
import FirebaseAnalytics
import GoogleMobileAds
import UserNotifications
import FacebookCore
import AppTrackingTransparency

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    var appState: AppState?
    var declarationStore: DeclarationViewModel?
    var updateAppState: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
            
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        registerNotificationHandler()
        registerBGTask()
        Analytics.logEvent(Event.SessionStarted, parameters: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleNotificationRequest), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleNotificationRequest), name: resyncNotification, object: nil)
        NotificationHandler.shared.callback = { [weak self] content in
            self?.declarationStore?.setDeclaration(content.body, category: content.title)
        }
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
//            if granted {
//                application.registerForRemoteNotifications()
//            }
//        }
        
        return true
    }
    
    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {
            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
        }
    
    private func registerNotificationHandler() {
        NotificationManager.shared.notificationCenter.delegate = NotificationHandler.shared
    }
    

    
    
    private func registerBGTask() {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.speaklife.updateNotificationContent", using: nil) { task in
            self.updateNotificationContent(task: task as! BGAppRefreshTask)
        }
    }
    
    @objc func scheduleNotificationRequest()  {
        scheduleNotificationRequestWithInterval(true)
        scheduleNotificationRequestWithInterval()
    }
    
    func scheduleNotificationRequestWithInterval(_ resyncNow: Bool = false) {
    
        let now = TimeInterval(1)
        let sixHours = TimeInterval(6 * 60 * 60)
        
        let request = BGAppRefreshTaskRequest(identifier: "com.speaklife.updateNotificationContent")
        request.earliestBeginDate = Date(timeIntervalSinceNow: resyncNow ? now : sixHours)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule notification cleaning: \(error)")
        }

    }
    
    private func updateNotificationContent(task: BGAppRefreshTask)  {
        scheduleNotificationRequest()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        guard let appState = appState else  {
            return
        }
        
        let updateNotificationsOperation = UpdateNotificationsOperation(appState: appState)
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        updateNotificationsOperation.completionBlock = {
            task.setTaskCompleted(success: true)
        }
        
        queue.addOperation(updateNotificationsOperation)
        queue.waitUntilAllOperationsAreFinished()
        
    }
}


//extension AppDelegate: SKPaymentTransactionObserver {
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        
//    }
//    
//    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
//        // Handle the incoming purchase request
//        // Return true if you are ready to process the payment; return false to defer it
//        return true
//    }
//}
