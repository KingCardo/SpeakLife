//
//  NotificationHandler.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 3/10/22.
//

import SwiftUI

final class NotificationHandler: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationHandler()

    var callback: ((UNNotificationContent) -> Void)?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let content = response.notification.request.content
        callback?(content)
        
        completionHandler()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let content = notification.request.content
        callback?(content)
        completionHandler([.sound, .banner])
    }
}

extension NotificationHandler {
    func requestPermission(_ delegate : UNUserNotificationCenterDelegate? = nil ,
            onDeny handler :  (()-> Void)? = nil) {
        
            let center = UNUserNotificationCenter.current()
            
            center.getNotificationSettings(completionHandler: { settings in
            
                if settings.authorizationStatus == .denied {
                    if let handler = handler {
                        handler()
                    }
                    return
                }
                
                if settings.authorizationStatus != .authorized  {
                    center.requestAuthorization(options: [.alert, .sound, .badge]) {
                        _ , error in
                        
                        if let error = error {
                            print("error handling \(error)")
                        }
                    }
                }
                
            })
            center.delegate = delegate ?? self
        }
    
}
