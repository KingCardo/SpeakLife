//
//  AppState.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/25/22.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var rootViewId = UUID()
    @AppStorage("onboarded") var isOnboarded = false
    @AppStorage("notificationEnabled") var notificationEnabled = false
    @AppStorage("notificationCount") var notificationCount = 4
    @AppStorage("startTimeNotification") var startTimeNotification = ""
    @AppStorage("endTimeNotification") var endTimeNotification = ""
    @AppStorage("startTimeIndex") var startTimeIndex = 16
    @AppStorage("endTimeIndex") var endTimeIndex = 25
    @AppStorage("selectedNotificationCategories") var selectedNotificationCategories: String = ""
}
