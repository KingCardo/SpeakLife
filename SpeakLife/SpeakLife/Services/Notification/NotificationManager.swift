//
//  NotificationManager.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/20/22.
//

import UserNotifications
import Foundation

let resyncNotification = NSNotification.Name("NotificationsDone")
let notificationNavigate = NSNotification.Name("NavigateToContent")

final class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    var lastScheduledNotificationDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "lastScheduledNotificationDate") as? Date
        } set {
            UserDefaults.standard.set(newValue!, forKey: "lastScheduledNotificationDate")
            scheduleNotificationResync(lastScheduledNotificationDate)
        }
    }
    
    func notificationCategories() -> Set<DeclarationCategory> {
        [DeclarationCategory.destiny, .perseverance, .peace, .gratitude, .faith, .motivation, .identity, .grace, .joy, .wisdom]
    }
    
    
    private override init() {}
    
    private let notificationProcessor = NotificationProcessor(service: APIClient())
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    func registerNotifications(count: Int,
                               startTime: Int,
                               endTime: Int,
                               categories: Set<DeclarationCategory>? = nil) {
        removeNotifications()
        if let categories = categories {
            let notifications = getNotificationData(for: count, categories: categories)
            prepareNotifications(declarations: notifications,  startTime: startTime, endTime: endTime, count: count)
        } else {
            let notifications = getNotificationData(for: count, categories: notificationCategories())
            prepareNotifications(declarations: notifications,  startTime: startTime, endTime: endTime, count: count)
        }
        morningAffirmationReminder()
        nightlyAffirmationReminder()
        devotionalAffirmationReminder()
        christmasReminder()
        newYearsReminder()
    }
    
    func getNotificationData(for count: Int,
                                     categories: Set<DeclarationCategory>?)  ->  [NotificationProcessor.NotificationData] {
        var notificationData: [NotificationProcessor.NotificationData] = []
        
        if let categories = categories {
            notificationProcessor.getNotificationData(count: count, categories: Array(categories)) { data in
                notificationData = data
            }
        } else {
            notificationProcessor.getNotificationData(count: count, categories: nil) { data in
                notificationData = data
            }
        }
        
        return notificationData
    }
    
    
    
    private func prepareNotifications(declarations: [NotificationProcessor.NotificationData],
                                      startTime: Int,
                                      endTime: Int,
                                      count: Int) {
        
        let hourMinute = distributeTimes(startTime: startTime, endTime: endTime, count: count)
        
        for (idx, declaration) in declarations.enumerated() {
            let id = UUID().uuidString
            var body = declaration.body
            if declaration.title.count > 1 {
                body += " ~ " + declaration.title
            }
            let content = UNMutableNotificationContent()
            content.title = "SpeakLife"
            content.body = body
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.autoupdatingCurrent
            dateComponents.timeZone = TimeZone.autoupdatingCurrent
        
            dateComponents.hour = hourMinute[idx].hour

            dateComponents.minute = hourMinute[idx].minute
            
            if let ymd = dateComponents.calendar?.dateComponents([.year, .month, .day, .hour], from: Date()) {
                dateComponents.year = ymd.year
                dateComponents.month = ymd.month
                var day = ymd.day ?? 1
                
                if hourMinute[idx].hour < ymd.hour! {
                    day += 1
                }
                dateComponents.day = day
            }
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, repeats: false)
            
            
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            notificationCenter.add(request) { (error) in
                if error != nil {
                   //  TODO: - handle error
                }
                
            }
            
            if idx == (count - 1) {
                let now = Date()
                let modifiedDate = Calendar.current.date(byAdding: .day, value: -1, to: now)
                
                lastScheduledNotificationDate = modifiedDate
            }
        }
    }
    
    @objc func postResyncNotifcation() {
        NotificationCenter.default.post(name: resyncNotification, object: nil)
    }
    
    private func scheduleNotificationResync(_ resyncDate: Date?) {
        guard let resyncDate = resyncDate else { return }
        
        Timer.scheduledTimer(timeInterval: resyncDate.timeIntervalSinceNow,
                             target: self,
                             selector: #selector(postResyncNotifcation),
                             userInfo: nil,
                             repeats: false)
    }
    
    private func morningAffirmationReminder() {
        let id = UUID().uuidString
        let body = "🗣️ This is the day the Lord has made I will rejoice and be glad in it! - Let's start the day by speaking things into existence." // Localize
        
        let content = UNMutableNotificationContent()
        content.title = "SpeakLife"
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        dateComponents.timeZone = TimeZone.autoupdatingCurrent
        dateComponents.hour = 8
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if error != nil {
                //  TODO: - handle error
            }
        }
    }
    
    private func nightlyAffirmationReminder() {
        let id = UUID().uuidString
        
        let body = "💜 We conquered another day! Lets end the day with gratitude and speaking life into tomorrow." // Localize
        
        let content = UNMutableNotificationContent()
        content.title = "SpeakLife"
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        dateComponents.timeZone = TimeZone.autoupdatingCurrent
        dateComponents.hour = 21
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if error != nil {
                //  TODO: - handle error
            }
        }
    }
    
    private func devotionalAffirmationReminder() {
        let id = UUID().uuidString
        let body = "Your Daily Devotion is Ready! 🪑 Take a moment to sit with Jesus!" // Localize
        
        let content = UNMutableNotificationContent()
        content.title = "SpeakLife"
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        dateComponents.timeZone = TimeZone.autoupdatingCurrent
        dateComponents.hour = 8
        dateComponents.minute = 30
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: true)
        
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if error != nil {
                //  TODO: - handle error
            }
        }
    }
    
    func newAffirmationReminder() {
        let id = UUID().uuidString
        let body = "New Affirmations 🚨" // Localize
        
        let content = UNMutableNotificationContent()
        content.title = "SpeakLife"
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let nextTriggerDate = Calendar.current.date(byAdding: .minute, value: 10, to: Date())!
        let comps = Calendar.current.dateComponents([.year, .month, .day, .minute], from: nextTriggerDate)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: comps, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if error != nil {
                //  TODO: - handle error
            }
        }
    }
    
    private func christmasReminder() {
        let id = UUID().uuidString
        let body = "✝️ Jesus is the heart of this festive season. Let's embrace His love and teachings as we celebrate. Merry Christmas!" // Localize
        
        let content = UNMutableNotificationContent()
        content.title = "Celebrate the True Meaning of Christmas"
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        dateComponents.timeZone = TimeZone.autoupdatingCurrent
        dateComponents.hour = 9
        dateComponents.day = 25
        dateComponents.month = 12
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if error != nil {
                //  TODO: - handle error
            }
        }
    }
    
    private func newYearsReminder() {
        let id = UUID().uuidString
        let body = "🥳 As we step into the New Year, let's prioritize our walk with Jesus. May His teachings guide our choices and bring blessings in every aspect of our lives. Happy New Year!" // Localize
        
        let content = UNMutableNotificationContent()
        content.title = "Start the New Year with Jesus"
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        dateComponents.timeZone = TimeZone.autoupdatingCurrent
        dateComponents.day = 1
        dateComponents.month = 1
        dateComponents.hour = 9
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if error != nil {
                //  TODO: - handle error
            }
        }
    }
    
    private func getArrayDates(from dates: [Date], startTimeIndex: Int, endTimeIndex: Int) -> [Date] {
        
        var newArrayDate: [Date] = []
        
        if endTimeIndex <= startTimeIndex {
            let startToEndOfDay = dates.suffix(from: startTimeIndex)
            let endToStart = dates.prefix(through: endTimeIndex)
            newArrayDate.append(contentsOf: startToEndOfDay)
            newArrayDate.append(contentsOf: endToStart)
            return newArrayDate
        }
        
        var tick = 0
        for date in dates {
            if tick >= startTimeIndex && tick <= endTimeIndex  {
                newArrayDate.append(date)
            }
            tick += 1
        }
        return newArrayDate
    }
    
    func getHourMinute(startTime: Int, endTime: Int, count: Int) -> [(hour: Int, minute: Int)] {
        let dates = TimeSlots.getDateTimeSlots()
        let calendar = Calendar.autoupdatingCurrent
        
        let newArrayDates = getArrayDates(from: dates, startTimeIndex: startTime, endTimeIndex: endTime)
        
        var returnTimes: [(hour: Int, minute: Int)] = []
        var tempCount = 0
        
        while tempCount < count && tempCount < newArrayDates.count {
            let hour = calendar.component(.hour, from: newArrayDates[tempCount])
            let minute = calendar.component(.minute, from: newArrayDates[tempCount])
            let newTime = (hour: hour, minute: minute)
            returnTimes.append(newTime)
            tempCount += 1
        }
        
        let stopIndex = tempCount - 1
        
        
        while tempCount < count {
            let hour = calendar.component(.hour, from: newArrayDates[stopIndex])
            let minute = calendar.component(.minute, from: newArrayDates[stopIndex])
            let newTime = (hour: hour, minute: minute)
            returnTimes.append(newTime)
            tempCount += 1
            
        }
        
        return returnTimes
    }
    
    private func createDate(hour: Int, minute: Int) -> Date? {
        // Use the current date as the base
        let currentDate = Date()
        let calendar = Calendar.autoupdatingCurrent

        // Set the specific hour and minute
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: currentDate)
    }
    
    func distributeTimes(startTime: Int, endTime: Int, count: Int) -> [(hour: Int, minute: Int)] {
        let dates = TimeSlots.getDateTimeSlots()
        let calendar = Calendar.autoupdatingCurrent
        let newArrayDates = getArrayDates(from: dates, startTimeIndex: startTime, endTimeIndex: endTime)
        let startTimeHour = calendar.component(.hour, from: newArrayDates[0])
        let startTimeMinute = calendar.component(.minute, from: newArrayDates[0])
        
        let endTimeHour = calendar.component(.hour, from: newArrayDates.last!)
        let endTimeMinute = calendar.component(.minute, from: newArrayDates.last!)
                                                 
        let startTime = createDate(hour: startTimeHour, minute: startTimeMinute)!
        let endTime = createDate(hour: endTimeHour, minute: endTimeMinute)!
        
        
        guard count > 0, startTime < endTime else {
            return [] // Return an empty array if count is zero or if start time is after end time
        }

        var result: [(hour: Int, minute: Int)] = []

        // Calculate total duration in seconds
        let totalSeconds = Int(endTime.timeIntervalSince(startTime))
        
        // Calculate interval in seconds
        let interval = totalSeconds / count

        // Generate times
        for i in 0..<count {
            if let time = Calendar.current.date(byAdding: .second, value: i * interval, to: startTime) {
                let hour = Calendar.current.component(.hour, from: time)
                let minute = Calendar.current.component(.minute, from: time)
                result.append((hour, minute))
            }
        }

        return result
    }
    
    func notificationsPending(completion: @escaping(Bool, Int?) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            if requests.count > 0 {
                completion(true, requests.count)
                return
            } else {
                completion(false, nil)
                return
            }
        }
    }
    
    private func removeNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}


final class UpdateNotificationsOperation: Operation {
    
    private let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    override func start() {
        let categories = appState.selectedNotificationCategories.components(separatedBy: ",").compactMap({ DeclarationCategory($0) })
        var setCategories = Set(categories)
        if setCategories.count == 1 {
            setCategories.insert(DeclarationCategory(rawValue: "destiny")!)
        }
        let selectedCategories = setCategories.isEmpty ? nil : setCategories
        
        NotificationManager.shared.notificationsPending { [weak self] pending, count in
            
            guard let self = self else { return }
            
            if self.appState.notificationEnabled {
                self.appState.lastNotificationSetDate = Date()
                NotificationManager.shared.registerNotifications(count: self.appState.notificationCount,
                                                                 startTime: self.appState.startTimeIndex,
                                                                 endTime: self.appState.endTimeIndex,
                                                                 categories: selectedCategories)
                self.completionBlock?()
                
            }
            
        }
    }
}
