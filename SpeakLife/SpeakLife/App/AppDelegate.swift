//
//  AppDelegate.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/30/22.
//

import UIKit
import BackgroundTasks
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    var appState: AppState?
    var declarationStore: DeclarationViewModel?
    var updateAppState: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        registerNotificationHandler()
        registerBGTask()
        
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleNotificationRequest), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleNotificationRequest), name: resyncNotification, object: nil)
        return true
    }
    
    private func registerNotificationHandler() {
        NotificationManager.shared.notificationCenter.delegate = NotificationHandler.shared
    }
    
    private func registerBGTask() {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.speaklife.updateNotificationContent", using: nil) { task in
            self.updateNotificationContent(task: task as! BGAppRefreshTask)
        }
    }
    
    @objc private func scheduleNotificationRequest(timeInterval: TimeInterval = TimeInterval(6 * 60  * 60)) {
    
        let request = BGAppRefreshTaskRequest(identifier: "com.speaklife.updateNotificationContent")
        request.earliestBeginDate = Date(timeIntervalSinceNow: timeInterval)

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
