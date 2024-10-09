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
    @Published var onBoardingTest = true
    @Published var showScreenshotLabel = false
    @AppStorage("onboarded") var isOnboarded = false
    @AppStorage("newPrayersAdded") var newPrayersAdded = true
    @AppStorage("newCategoriesAddedv4") var newCategoriesAddedv4 = true
    @AppStorage("newThemesAdded") var newThemesAdded = true
    @AppStorage("newSettingsAdded") var newSettingsAdded = true
    @AppStorage("abbasLoveAdded") var abbasLoveAdded = true
    @AppStorage("newTrackerAdded") var newTrackerAdded = true
    @AppStorage("lastNotificationSetDate") var lastNotificationSetDate = Date()
    @AppStorage("lastSharedAttemptDate") var lastSharedAttemptDate = Date()
    @AppStorage("notificationEnabled") var notificationEnabled = false
    @AppStorage("notificationCount") var notificationCount = 10
    @AppStorage("startTimeNotification") var startTimeNotification = ""
    @AppStorage("endTimeNotification") var endTimeNotification = ""
    @AppStorage("startTimeIndex") var startTimeIndex = 12
    @AppStorage("endTimeIndex") var endTimeIndex = 40
    @AppStorage("selectedNotificationCategories") var selectedNotificationCategories: String = ""
    @AppStorage("abbasLoveLetterIndex") var loveLetterIndex = 0
    @AppStorage("resetNotifications") var resetNotifications = true
    @AppStorage("lastReviewRequestSetDatev1") var lastReviewRequestSetDate: Date?
    @AppStorage("offerDiscount") var offerDiscount = false
    @AppStorage("offerDiscountTry") var offerDiscountTry = 0
    @AppStorage("discountEndTime") var discountEndTime: Date?
    @AppStorage("lastRequestedRatingVersion") var lastRequestedRatingVersion: String?
    @AppStorage("helpUs") var helpUsGrowCount = 0
    @Published var timeRemainingForDiscount = 0
    @AppStorage("userName") var userName = ""
    @AppStorage("firstSelection") var firstSelection = ""
    @AppStorage("discountSelection") var discountSelection = ""
    @AppStorage("discountPercentage") var discountPercentage = ""
    @AppStorage("subscriptionTest") var subscriptionTestnineteen = false
  
}

@propertyWrapper
struct AppStorageCodable<T: Codable> {
    let key: String
    let defaultValue: T
    var container: UserDefaults = .standard

    var wrappedValue: T {
        get {
            guard let data = container.data(forKey: key) else {
                return defaultValue
            }
            let decodedValue = try? JSONDecoder().decode(T.self, from: data)
            return decodedValue ?? defaultValue
        }
        set {
            let encodedData = try? JSONEncoder().encode(newValue)
            container.set(encodedData, forKey: key)
        }
    }
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
    
    var isDateToday: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
}
