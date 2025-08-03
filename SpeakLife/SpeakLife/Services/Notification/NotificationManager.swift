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
        [DeclarationCategory.destiny, .gratitude, .faith, .identity, .grace, .joy, .rest]
    }
    
    
    private override init() {}
    
    private let notificationProcessor = NotificationProcessor(service: LocalAPIClient())
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    func registerNotifications(count: Int,
                               startTime: Int,
                               endTime: Int,
                               categories: Set<DeclarationCategory>? = nil,
                               callback: (() -> Void)? = nil) {
        removeNotifications()
        if let categories = categories {
            let notifications = getNotificationData(for: count, categories: categories)
            // callback if data is less than count RWRW
            prepareNotifications(declarations: notifications,  startTime: startTime, endTime: endTime, count: count) {
                callback?()
            }
        } else {
            let notifications = getNotificationData(for: count, categories: notificationCategories())
            prepareNotifications(declarations: notifications,  startTime: startTime, endTime: endTime, count: count) {
                callback?()
            }
        }
        morningAffirmationReminder()
        nightlyAffirmationReminder()
        //devotionalAffirmationReminder()
       // prayersAffirmationReminder()
        christmasReminder()
        newYearsReminder()
        thanksgivingReminder()
    }
    

    func checkForLowReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            if requests.isEmpty {
                // Likely wiped on reboot or uninstall
                DispatchQueue.main.async {
                    self.scheduleReminder(
                        title: "⚠️ Reminders ending!",
                        body: "Tap to schedule more reminders.",
                        date: Date().addingTimeInterval(10),
                        id: "reschedule_prompt"
                    )
                }
            }
        }
    }
    
    func scheduleReminder(title: String, body: String, date: Date, id: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleTrialEndingReminder(subscriptionDate: Date) {
        setupNotificationCategory()
            let notificationCenter = UNUserNotificationCenter.current()
            
            // Calculate the fire date (5 days after subscription)
            let fireDate = Calendar.current.date(byAdding: .day, value: 5, to: subscriptionDate) ?? Date()
            let content = UNMutableNotificationContent()
            content.title = "Your Trial is Ending Soon"
            content.body = "Your 7-day trial ends in 2 days. If you don’t cancel, your subscription will renew automatically."
            content.sound = .default
            
            // Create a trigger based on the calculated fire date
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            // Create and add the request
            let request = UNNotificationRequest(identifier: "TrialEndingReminder", content: content, trigger: trigger)
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    
    func setupNotificationCategory() {
        let manageAction = UNNotificationAction(
            identifier: "MANAGE_SUBSCRIPTION",
            title: "Manage Subscription",
            options: [.foreground] // Opens the app when tapped
        )
        
        let category = UNNotificationCategory(
            identifier: "TRIAL_ENDING_CATEGORY",
            actions: [manageAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func prepareDailyStreakNotification(with name: String = "Friend", streak: Int, hasCurrentStreak: Bool) {
        let noStreakBody: [String] = ["Don’t forget to speak life today! God’s promises are waiting for you. ✨",
                                   "Have you spoken God’s promises yet? Take a moment to activate them now. 🙏",
                                   "A quick reminder: Speak life today and unlock God’s blessings over your day. 🌟",
                                   "Your day isn’t complete without declaring God’s promises. Speak life now! 🗣️",
                                   "Missed speaking life today? It’s not too late to declare God’s truth over your life. ⏳",
                                   "Take a moment to speak God’s promises—there’s still time to activate His power today. ⏰",
                                   "Don’t let today pass without speaking life. God’s promises are ready to be activated! 💬",
                                   "A gentle nudge—have you declared God’s promises today? Speak life now! 🌱",
                                   "Haven’t spoken life today? Your words can still activate God’s promises. 🕊️",
                                   "Reminder: Speak life and let God’s promises guide the rest of your day. ✨",
                                   ]
        
        let hasStreakBody: [String] = [
            "Well done! You spoke life today and activated God’s promises. Keep it going! 🎉",
            "Great job! Your words are bringing God’s promises to life. Keep the streak alive! 🔥",
            "You did it! God’s promises are at work because you spoke life today. 🙌",
            "Streak on fire! 🔥 Keep declaring God’s truth and watch the blessings flow.",
            "Consistency is key! You’re unlocking God’s promises one day at a time. ✨",
            "Another day, another victory! Keep speaking life and activating God’s power. 🎯",
            "Congratulations! You’ve made today count by declaring God’s promises. Keep shining! 🌟",
            "Your streak is going strong! Keep speaking life and watch God’s promises unfold. 💫",
            "Amazing! You’re on a roll—keep declaring God’s truth and blessings. 🗣️",
            "Way to go! Your commitment to speaking life is making a difference. 🙏",
            "You’re unstoppable! Keep activating God’s promises daily. 🚀",
            "Another day of speaking life—your streak is growing, and so are the blessings! 🌱",
            "Great consistency! Keep declaring God’s promises and see the rewards. 🌈",
            "You’re on the right path! Keep up the great work and watch God’s promises be fulfilled. 🌟",
            "Streak maintained! 🎉 Your faithfulness in speaking life is powerful. Keep it up!",
        ]
        
        let body: String
        
        if hasCurrentStreak {
            body = "Hey \(name),\(hasStreakBody.randomElement()!)"
        } else {
            body = "Hey \(name),\(noStreakBody.randomElement()!)"
        }
        
        let content = UNMutableNotificationContent()
        content.title = "SpeakLife"
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        dateComponents.timeZone = TimeZone.autoupdatingCurrent
        dateComponents.hour = 20
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        let id = "StreakReminder"
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
       
        notificationCenter.add(request) { (error) in
            if error != nil {
                //  TODO: - handle error
            }
        }
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
                                      count: Int,
                                      callback: (() -> Void)? = nil) {
        
        print(startTime, endTime, "RWRW initial times")
        
        let hourMinute = distributeTimes(startTime: startTime, endTime: endTime, count: count)
        
        guard hourMinute.count > 1 else { callback?()
            return }
        guard declarations.count >= count else { callback?()
            return }
    
        for (hour, minute) in hourMinute {
            print(hour, minute, "RWRW")
        }
        
        for (idx, declaration) in declarations.enumerated() {
            let id = UUID().uuidString
            var body = declaration.body
            if declaration.book.count > 1 {
                body += " ~ " + declaration.book
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
        let bodyArray: [String] = [
            "🔥 YOU ARE HEALED! Your identity is sealed by the blood of Jesus. Every symptom is a LIE that must bow to who you REALLY are!",
            "⚔️ Rise up WARRIOR! The battle is ALREADY WON! Speak back to every lying symptom: 'You have NO authority over me!'",
            "👑 You are a CHILD OF THE KING! What you see is temporary—what God says is ETERNAL. Keep declaring His truth!",
            "💪 Your healing is FINISHED WORK! Jesus said 'It is finished!' Don't negotiate with symptoms—COMMAND them to leave!",
            "🛡️ The spiritual realm RULES the physical! Your words are WEAPONS. Keep speaking life—persistence always wins!",
            "⚡ You're not fighting FOR victory—you're fighting FROM victory! Every declaration enforces what Jesus already won!",
            "🌟 Your TRUE IDENTITY: Healed. Whole. Victorious. Don't let symptoms tell you who you are—GOD already declared it!",
            "🔥 SPEAK BACK to every lie! 'Pain, you're a liar! Sickness, you have no place in me! I am the healed of the Lord!'",
            "💎 You are ROYALTY walking in divine health! Keep declaring—your persistence is moving mountains in the spirit realm!",
            "⚔️ Every symptom is ILLEGAL in your body! You have AUTHORITY to evict them. Speak with boldness—heaven backs you!",
            "🦅 You operate from HEAVEN'S REALITY! What you feel must bow to what you KNOW. Keep speaking—breakthrough is here!",
            "👑 Your words are CREATING your reality! The physical MUST align with the spiritual. Don't stop declaring!",
            "🔥 You're not hoping to be healed—you ARE healed! Symptoms are just shadows fleeing the light of truth!",
            "💪 IDENTITY CHECK: You are who GOD says you are! Every cell in your body is listening—speak LIFE!",
            "🛡️ The facts say one thing, but TRUTH says another! You live by truth, not by sight. Keep declaring!",
            "⚡ Your persistence is PROOF of faith! Every declaration is a hammer blow against the lies. Keep swinging!",
            "🌟 You have the SAME SPIRIT that raised Jesus! Command your body to line up with heaven's blueprint!",
            "🔥 Don't beg—COMMAND! You have authority. 'Body, you WILL manifest the healing Jesus paid for!'",
            "💎 The spiritual realm is MORE REAL than the physical! Your words are reshaping reality. Don't stop!",
            "⚔️ Every morning is a new opportunity to ENFORCE your healing! Symptoms must flee persistent faith!",
            "🦅 You're seated in HEAVENLY PLACES! Speak from that position of authority. You've already won!",
            "👑 Your healing isn't coming—it's HERE! Keep speaking until the physical catches up with the spiritual!",
            "🔥 WARRIOR, rise up! Your words are spiritual VIOLENCE against sickness. Keep attacking with truth!",
            "💪 You don't speak TO the problem—you speak FROM the solution! You ARE healed, so speak like it!",
            "🛡️ Heaven's reality is YOUR reality! Every symptom is an opportunity to demonstrate your authority!",
            "⚡ Your IDENTITY determines your destiny! You are the healed, so healing MUST manifest!",
            "🌟 Don't let feelings be your guide—let FAITH lead! What God says is FINAL. Keep declaring!",
            "🔥 You're not trying to GET healed—you're ENFORCING what's already yours! Speak with authority!",
            "💎 The physical realm is SUBJECT to the spiritual! Your persistent words are rearranging atoms!",
            "⚔️ Every declaration is a DECREE from heaven's throne! Hell trembles when you speak God's Word!",
            "🦅 You have RESURRECTION POWER in your words! Command life to flow through every cell!",
            "👑 Your healing is as SURE as your salvation! Both were paid for at the cross. Stand firm!",
            "🔥 IDENTITY REMINDER: You are completely healed! Now speak until your body remembers who it belongs to!",
            "💪 Don't whisper—ROAR! You have the Lion of Judah in you. Let heaven and earth hear your declarations!",
            "🛡️ You're not fighting flesh and blood—you're enforcing spiritual LAW! Your healing is legally yours!",
            "⚡ Persistence is your SUPERPOWER! Every word spoken in faith is building your testimony!",
            "🌟 You see through HEAVEN'S EYES! What looks impossible is already done. Keep speaking the solution!",
            "🔥 Rise up in your TRUE IDENTITY! You're not sick trying to get well—you're healed manifesting wholeness!",
            "💎 Your words carry CREATIVE POWER! Speak to every organ, every cell: 'Line up with heaven's design!'",
            "⚔️ The battle was won 2000 years ago! You're just collecting the spoils. Speak and receive!"
        ]
        let body = bodyArray.randomElement()// Localize
        
        let content = UNMutableNotificationContent()
        content.title = "SpeakLife"
        content.body = body ?? "🗣️ This is the day the Lord has made I will rejoice and be glad in it! - Let's start the day by speaking things into existence."
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
        let bodyArray: [String] = [
            "🌙 You spoke LIFE all day—now rest knowing heaven is WORKING! Your words don't return void. Healing manifests even as you sleep!",
            "✨ WARRIOR, you fought well today! Every declaration pushed back darkness. Rest in VICTORY—the battle is already won!",
            "🛡️ Your TRUE IDENTITY doesn't change at night! You're still healed, still whole. Let your spirit declare truth while you rest!",
            "💫 You SILENCED lying symptoms today! Your persistence moved mountains. Sleep in peace—angels are enforcing your words!",
            "🌟 The spiritual realm NEVER SLEEPS! Your declarations are still working. Rest knowing heaven is fighting for you!",
            "🔥 You didn't just survive today—you CONQUERED! Every word spoken was a victory. Tomorrow, you'll speak with even more authority!",
            "👑 Sleep like ROYALTY! You're not hoping for healing—you're resting in FINISHED WORK. Your identity is secure!",
            "⚡ Your words today SHOOK the spiritual realm! Demons fled, angels rejoiced. Rest well, mighty warrior!",
            "🌙 Even in sleep, you're DANGEROUS to the enemy! Your spirit knows the truth. Dream of victory—it's already yours!",
            "✨ You REFUSED to agree with symptoms today! That's spiritual WARFARE! Rest knowing you're winning!",
            "🛡️ Your persistence today was POWERFUL! Every declaration was a seed. Tomorrow you'll see the harvest!",
            "💫 You operate from HEAVEN'S TIMEZONE! While you rest, the spiritual realm is manifesting your words!",
            "🌟 CHECK YOUR IDENTITY before bed: Still healed! Still victorious! Still seated in heavenly places!",
            "🔥 You spoke with AUTHORITY today! Hell took notice. Rest peacefully—your healing is secured!",
            "👑 Don't let today's symptoms define tomorrow's reality! You know WHO YOU ARE. Rest in that truth!",
            "⚡ Your words today were SPIRITUAL VIOLENCE against sickness! Well done, warrior. Rest and reload!",
            "🌙 The physical is CATCHING UP to the spiritual! Your persistence is working. Sleep in faith!",
            "✨ You COMMANDED your body today—that takes courage! Rest knowing every word hit its target!",
            "🛡️ Your healing isn't fragile—it's GUARANTEED by the blood! Sleep peacefully in that assurance!",
            "💫 Today you chose TRUTH over facts! That's maturity. Rest knowing heaven honors persistence!",
            "🌟 Even your REST is warfare! You're demonstrating trust. The battle is won—sleep like a victor!",
            "🔥 You didn't back down from lying symptoms! Your identity stood firm. Tomorrow, speak even bolder!",
            "👑 Review today's VICTORIES: You spoke life! You refused lies! You stood in truth! Well done!",
            "⚡ Your words are STILL ECHOING in the spirit realm! Rest while heaven works the night shift!",
            "🌙 You're not fighting alone—heaven's ARMIES back every word! Sleep knowing you have backup!",
            "✨ Today's persistence is tomorrow's TESTIMONY! Keep going—breakthrough is closer than you think!",
            "🛡️ Your TRUE IDENTITY never sleeps! You're healed 24/7. Let that truth guard your dreams!",
            "💫 You OUTLASTED the lies today! Persistence always wins. Rest and prepare for tomorrow's victory!",
            "🌟 The spiritual realm SAW your faith today! Angels are working overtime. Sleep in peace!",
            "🔥 Don't let symptoms have the last word! Before you sleep, declare: 'I AM HEALED!'",
            "👑 You're going to bed VICTORIOUS! Not because of what you feel, but because of WHO YOU ARE!",
            "⚡ Your declarations today SHIFTED atmospheres! Rest knowing you changed things in the spirit!",
            "🌙 Tomorrow you'll speak with MORE authority! Each day builds momentum. Rest and recharge!",
            "✨ You're not just sleeping—you're SOAKING in truth! Let God's promises saturate your dreams!",
            "🛡️ Check your spiritual ARMOR—still on! You're protected even in rest. The enemy can't touch your identity!",
            "💫 You REFUSED to negotiate with symptoms! That's kingdom authority. Sleep like the warrior you are!",
            "🌟 Your persistence is your WORSHIP! Heaven celebrates fighters. Rest in His pleasure!",
            "🔥 You're not tired—you're TRIUMPHANT! Today's declarations will echo into eternity!",
            "👑 FINAL IDENTITY CHECK: Still healed! Still loved! Still victorious! Now rest in that reality!",
            "⚡ Tomorrow, you'll speak with FRESH FIRE! Tonight, let heaven restore your strength. You're winning!"
        ]
        
        let body =  bodyArray.randomElement()// Localize
        
        let content = UNMutableNotificationContent()
        content.title = "SpeakLife"
        content.body = body ?? "💜 We conquered another day! Lets end the day with gratitude and speaking life into tomorrow."
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
    private func prayersAffirmationReminder() {
        let id = UUID().uuidString
        let body = "Time to move mountains 🏔️, come pray along to start your day!" // Localize
        
        let content = UNMutableNotificationContent()
        content.title = "SpeakLife"
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        dateComponents.timeZone = TimeZone.autoupdatingCurrent
        dateComponents.hour = 8
        
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
    
    private func thanksgivingReminder() {
        let id = UUID().uuidString
        let body = "Let gratitude fill your heart and overflow with thankfulness. May His grace and love surround you and yours today and always. 🍂🦃" // Localize
        
        let content = UNMutableNotificationContent()
        content.title = "Happy Thanksgiving from SpeakLife!"
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        dateComponents.timeZone = TimeZone.autoupdatingCurrent
        dateComponents.hour = 10
        dateComponents.day = 27
        dateComponents.month = 11
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        
        
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
        if setCategories.count <= 1 {
            setCategories.insert(DeclarationCategory(rawValue: "destiny")!)
            setCategories.insert(DeclarationCategory(rawValue: "love")!)
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
