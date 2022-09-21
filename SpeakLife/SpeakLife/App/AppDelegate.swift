//
//  AppDelegate.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/30/22.
//

import UIKit
import BackgroundTasks
import StoreKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    var appState: AppState?
    var declarationStore: DeclarationViewModel?
    var updateAppState: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
       
        registerNotificationHandler()
        registerBGTask()
        registerIAPDelegateAndObservers()
        SKPaymentQueue.default().add(StoreObserver.shared)
        updateSubscriptions()
        
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleNotificationRequest), name: UIApplication.didEnterBackgroundNotification, object: nil)
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(StoreObserver.shared)
    }

    
    private func updateSubscriptions() {
        StoreObserver.shared.receiptValidation(id: InAppId.revampYearlyId) { [weak self] didDelete in
            if didDelete {
            self?.updateAppState?()
            }
        }
        StoreObserver.shared.receiptValidation(id: InAppId.revampMonthlyId) { didDelete in
            
        }
    }
    
    
    private func registerNotificationHandler() {
        NotificationManager.shared.notificationCenter.delegate = NotificationHandler.shared
    }
    
    private func registerBGTask() {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.diosesaqui.updateNotificationContent", using: nil) { task in
            self.updateNotificationContent(task: task as! BGAppRefreshTask)
        }
    }
    
    @objc private func scheduleNotificationRequest() {
        let sixhours = TimeInterval(6 * 60  * 60)

        let request = BGAppRefreshTaskRequest(identifier: "com.diosesaqui.updateNotificationContent")
        request.earliestBeginDate = Date(timeIntervalSinceNow: sixhours)


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
    
    private func registerIAPDelegateAndObservers() {
        StoreManager.shared.delegate = self
        StoreObserver.shared.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseSuccess), name: PurchaseSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseCancelled), name: PurchaseCancelled, object: nil)
    }
    
    @objc private func purchaseSuccess() {
        appState?.isPremium = true
        declarationStore?.isPurchasing = false
    }
    
    @objc private func purchaseCancelled()  {
        declarationStore?.isPurchasing = false
    }
    
}

extension AppDelegate: StoreManagerDelegate {
    func storeManagerDidReceiveMessage(_ message: String) {
        declarationStore?.isPurchasing = false
        declarationStore?.errorMessage = message
    }
}

extension AppDelegate: StoreObserverDelegate {
    func storeObserverDidReceiveMessage(_ message: String) {
        declarationStore?.isPurchasing = false
        declarationStore?.errorMessage = message
    }
    
    func storeObserverRestoreDidSucceed(isPremium: Bool) {
        declarationStore?.isPurchasing = false
        declarationStore?.errorMessage = "All successful purchases have been restored."
        appState?.isPremium = isPremium
    }
    
}
