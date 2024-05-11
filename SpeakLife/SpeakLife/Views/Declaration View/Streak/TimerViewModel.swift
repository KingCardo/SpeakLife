//
//  TimerViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 3/17/24.
//

import SwiftUI
import UserNotifications
import Combine

final class TimerViewModel: ObservableObject {
    static let totalDuration = 5 * 60
    
    @AppStorage("currentStreak") var currentStreak = 0
    @AppStorage("longestStreak") var longestStreak = 0
    @AppStorage("totalDaysCompleted") var totalDaysCompleted = 0
    @AppStorage("lastCompletedStreak") var lastCompletedStreak: Date?
    @AppStorage("lastStartedStreak") var lastStartedStreak: Date?
    
    @AppStorage("newStreakNotification") var newStreakNotification = false
    
    @Published private(set) var isComplete = false
    @Published private(set) var timeRemaining: Int = 0
    @Published private(set) var isActive = false
    @Published var timer: Timer? = nil

    
    init() {
        checkAndUpdateCompletionDate()
        if !newStreakNotification {
            registerStreakNotification()
            newStreakNotification = true
        }
    }
    
//    func setupMidnightReset() {
//        let now = Date()
//        if let midnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) {
//            let midnightResetTimer = Timer(fireAt: midnight, interval: 0, target: self, selector: #selector(resetTimerAtMidnight), userInfo: nil, repeats: false)
//            RunLoop.main.add(midnightResetTimer, forMode: .common)
//        }
//    }
    
//    @objc func resetTimerAtMidnight() {
//        isComplete = false
//        timeRemaining = TimerViewModel.totalDuration // Reset to 10 minutes
//      //  stopTimer()
//       // startTimer()
//       // checkAndUpdateCompletionDate()
//    }
    
    func runCountdownTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if checkIfCompletedToday() {
                isActive = false
                return
            } else if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                completeMeditation()
                timer.invalidate()
                // Prepare for the next day's reset if needed, or set up another logic as per your requirement
               // self.setupMidnightReset()
            }
        }
    }
    
    func completeMeditation() {
        UserDefaults.standard.removeObject(forKey: "timeRemaining")
        timeRemaining = 0
        isComplete = true
        saveCompletionDate()
        currentStreak += 1
        totalDaysCompleted += 1
        if currentStreak > longestStreak {
            longestStreak += 1
        }
        NotificationCenter.default.post(name: Notification.Name("StreakCompleted"), object: nil)
        self.isActive = false
    }
    
    func saveCompletionDate() {
        lastCompletedStreak = Date()
    }
    
    lazy var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = .autoupdatingCurrent
        calendar.locale = .autoupdatingCurrent
        return calendar
    }()
    
    func checkIfCompletedToday() -> Bool {
        guard let completionDate = lastCompletedStreak else { return false }
        let currentDate = Date()
        let calendar = Calendar.current

        // Start of the current day
        let startOfToday = calendar.startOfDay(for: currentDate)

        // Start of the next day
        guard let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) else { return false }

        // Check if the completion date is within today's range
        let completed = completionDate >= startOfToday && completionDate < startOfTomorrow
        return completed
    }
    
    func midnightOfTomorrow(after date: Date) -> Date? {
        if let nextDay = calendar.date(byAdding: .day, value: 2, to: date) {
            return calendar.startOfDay(for: nextDay)
        }
        return nil
    }
    
    func checkIfMidnightOfTomorrowHasPassedSinceLastCompletedStreak() -> Bool {
        guard let lastCompletionDate = lastCompletedStreak,
              let midnightAfterCompletion = midnightOfTomorrow(after: lastCompletionDate) else {
            return false
        }
        return Date() > midnightAfterCompletion
    }
    
    func checkAndUpdateCompletionDate() {
        
        if checkIfMidnightOfTomorrowHasPassedSinceLastCompletedStreak() {
                scheduleNotificationForMidnightTomorrow()
            currentStreak = 0
        }
    }
    
    func saveRemainingTime() {
        UserDefaults.standard.set(timeRemaining, forKey: "timeRemaining")
        stopTimer()
       
    }
    
    func loadRemainingTime() {
        checkAndUpdateCompletionDate()
        
        if checkIfCompletedToday() {
            return
        } else if let savedTimeRemaining = UserDefaults.standard.value(forKey: "timeRemaining") as? Int, savedTimeRemaining > 2, let lastStartedStreak = lastStartedStreak, Calendar.current.isDateInToday(lastStartedStreak) {
            print(lastStartedStreak, "RWRW saved time from today")
            // Adjust the remaining time based on how much time has passed since the app was last open
            timeRemaining = savedTimeRemaining
            isComplete = false
            startTimer()
        } else {
            print("RWRW reset")
            timeRemaining = TimerViewModel.totalDuration
            lastStartedStreak = Date()
            isComplete = false
            startTimer()
        }
    }
    
    private func startTimer() {
        if checkIfCompletedToday() {
            return
        }
        if !isActive {
            isActive = true
            runCountdownTimer()
        }
    }
    
    func stopTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    
    func progress(for timeRemaining: Int) -> CGFloat {
        let totalTime = TimerViewModel.totalDuration
        let float = CGFloat(timeRemaining) / CGFloat(totalTime)
        return float
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    let speakLifeArray:[String] = ["Time to put them to use ⚔️🗣️",
                                   "The quest awaits! 🗺️⚔️ Ready to jump back in?",
                                   "Adventure calls! 🌄 Your journey resumes now.",
                                   "🛡️⚒️ Gear up and dive back in.",
                                   "Legends don't rest for too long! 🌟 It's time to claim your ground.",
                                   "The spiritual realm misses its hero! 🏰 Return to your adventure now.",
                                   "Too quiet without you! 🌿👣 Let's stir things up again.",
                                   "Your saga awaits its next chapter! 📖✨ Unpause your journey.",
                                   "Ready for another round? 🔄 The adventure never stops!",
                                   "It's comeback time! 🎉",
                                   "The heavens whisper your name! 🍃🗣️ Heed the call and return.",
                                   "Feeling the call of adventure? 🏞️ It's time to respond!",
                                   "Your destiny isn't written yet! 🌌 Continue your epic quest.",
                                   "A hero's work is never done! ⚔️🛡️ Keep fighting.",
                                   "The path remains! 🚶‍♂️🌲 Venture forward.",
                                   "Epic moments await! 🌠 Seize your destiny once more."

    ]
    
    func scheduleNotificationForMidnightTomorrow() {
        let content = UNMutableNotificationContent()
        content.title = "Speaking life is a weapon"
        content.body = speakLifeArray.shuffled().first ?? "Time to put them to use ⚔️🗣️"
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 0  // Midnight
        dateComponents.minute = 0

        // Increment day by 1 to schedule for tomorrow
        if let tomorrow = Calendar.current.date(byAdding: .hour, value: 7, to: Date()) {
            dateComponents.day = Calendar.current.component(.day, from: tomorrow)
            dateComponents.month = Calendar.current.component(.month, from: tomorrow)
            dateComponents.year = Calendar.current.component(.year, from: tomorrow)
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func registerStreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "New Streak 🔥"
        content.body = "Speaking Life just got easier, let's start a streak."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}


