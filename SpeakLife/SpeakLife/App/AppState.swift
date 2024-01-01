//
//  AppState.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/25/22.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var rootViewId = UUID()
    @Published var showIntentBar = true
    @AppStorage("onboarded") var isOnboarded = false
    @AppStorage("newPrayersAdded") var newPrayersAdded = true
    @AppStorage("newCategoriesAddedv4") var newCategoriesAddedv4 = true
    @AppStorage("newThemesAdded") var newThemesAdded = true
    @AppStorage("newSettingsAdded") var newSettingsAdded = true
    @AppStorage("abbasLoveAdded") var abbasLoveAdded = true
    @AppStorage("newTrackerAdded") var newTrackerAdded = true
    @AppStorage("lastNotificationSetDate") var lastNotificationSetDate = Date()
    @AppStorage("notificationEnabled") var notificationEnabled = false
    @AppStorage("notificationCount") var notificationCount = 10
    @AppStorage("startTimeNotification") var startTimeNotification = ""
    @AppStorage("endTimeNotification") var endTimeNotification = ""
    @AppStorage("startTimeIndex") var startTimeIndex = 16
    @AppStorage("endTimeIndex") var endTimeIndex = 26
    @AppStorage("selectedNotificationCategories") var selectedNotificationCategories: String = ""
    @AppStorage("showScreenshotLabel") var showScreenshotLabel = false
    @AppStorage("abbasLoveLetterIndex") var loveLetterIndex = 0
    @AppStorage("discountOfferedTries") var discountOfferedTries = 0
    @AppStorage("resetNotifications") var resetNotifications = true
    @AppStorage("lastReviewRequestSetDate") var lastReviewRequestSetDate = Date()
}

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
    
    func toPrettyString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
    
    func toSimpleDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
}
