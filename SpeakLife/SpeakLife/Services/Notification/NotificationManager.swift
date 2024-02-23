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
        [DeclarationCategory.destiny, .perseverance, .peace, .gratitude, .faith, .identity, .grace, .joy,]
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
        let bodyArray: [String] = ["🗣️ This is the day the Lord has made I will rejoice and be glad in it! - Let's start the day by speaking things into existence.",
                                   "🌞 Good morning! Embrace the new day with gratitude in your heart and positive affirmations on your lips. Make today amazing!",
                                   "🌅 Rise and shine! Start your day with a thankful spirit and affirm that today will be filled with joy and success.",
                                   "🌼 Welcome to a new day! Remember, each morning is a fresh start. Be grateful for this gift and affirm your strengths.",
                                   "🌈 Good morning! Let's begin today with gratitude for the little things. Affirm your ability to create a wonderful day.",
                                   "🍃 Wake up to a new beginning! Take a deep breath, express your gratitude for life, and affirm your positive intentions for the day.",
                                   "☀️ A new day awaits! Start with gratitude for a fresh start and affirmations for a fulfilling and happy day ahead.",
                                   "🐦 As you listen to the morning birds, remind yourself of all the things you're grateful for. Affirm today as a day of happiness and growth.",
                                   "🌷 Good morning! Let's greet the day with a heart full of gratitude and affirmations of strength and peace.",
                                   "🍂 Each morning brings new opportunities. Be grateful for them and affirm your readiness to embrace whatever comes your way.",
                                   "🌻 Good morning! Begin your day with thoughts of gratitude for life's blessings and affirmations of your limitless potential.",
                                   "🌟 As a new day dawns, fill your mind with gratitude for this chance to live, love, and grow. Affirm your positive impact on the world.",
                                   "🌙 As you leave the world of dreams, step into a new day with gratitude and affirm your commitment to make the most of it.",
                                   "🌍 Embrace this beautiful morning with an open heart. Be grateful for your journey and affirm your power to shape the day.",
                                   "☕ As you enjoy your morning coffee, take a moment to be thankful for the new day and affirm your intentions to live it fully.",
                                   "🌅 Good morning! 'This is the day the Lord has made; let us rejoice and be glad in it.' (Psalm 118:24) Start your day with joy and gratitude in your heart.",
                                   "🌞 As you wake up, remember, 'The steadfast love of the Lord never ceases; His mercies never come to an end.' (Lamentations 3:22-23) Embrace His new mercies today with thankfulness.",
                                   "🌼 'I can do all things through Christ who strengthens me.' (Philippians 4:13) Let this verse guide you today with confidence and gratitude for His strength in you.",
                                   "🍃 'For I know the plans I have for you,' declares the Lord, 'plans to prosper you and not to harm you, plans to give you hope and a future.' (Jeremiah 29:11) Start today with hope and gratitude.",
                                   "🌈 Each morning is a gift. 'His compassions never fail. They are new every morning.' (Lamentations 3:22-23) Be grateful for His unfailing love as you start your day.",
                                   "☀️ 'Let the morning bring me word of your unfailing love.' (Psalm 143:8) Begin your day with a heart full of gratitude for God’s unwavering love and faithfulness.",
                                   "🐦 As you hear the birds sing, remember Jesus’ words: 'Look at the birds of the air; they do not sow or reap... yet your heavenly Father feeds them.' (Matthew 6:26) Start your day trusting in His provision.",
                                   "🌷 'The Lord is my shepherd, I lack nothing.' (Psalm 23:1) Meditate on this as you start your day, embracing gratitude for His guidance and care.",
                                   "🍂 'Give thanks to the Lord, for He is good; His love endures forever.' (Psalm 107:1) Let this be your affirmation as you embark on today's journey with a thankful heart.",
                                   "🌻 'We love because He first loved us.' (1 John 4:19) Let the knowledge of His love fill your day with gratitude and inspire you to spread kindness and joy.",
                                   "🙏 Good Morning! Start with gratitude: 'Give thanks to the Lord, for He is good; His love endures forever.' – Psalm 107:1.",
                                       "🌺 Wake Up! 'I can do all things through Him who strengthens me.' – Philippians 4:13. Embrace the day's possibilities!",
                                       "🕊️ Peaceful Morning! 'Peace I leave with you; my peace I give to you.' – John 14:27. Start today in peace and calm.",
                                       "🌱 Good Morning! 'For we walk by faith, not by sight.' – 2 Corinthians 5:7. Let faith guide your steps today.",
                                       "💪 Start Strong! 'The Lord is my strength and my shield.' – Psalm 28:7. Face the day with His strength.",
                                       "💖 Loving Morning! 'We love because He first loved us.' – 1 John 4:19. Spread love and kindness today.",
                                       "🌟 Bright Morning! 'Let your light shine before others.' – Matthew 5:16. Illuminate your day with goodness.",
                                       "🙌 Uplifting Morning! 'Be strong and take heart, all you who hope in the Lord.' – Psalm 31:24. Keep hope alive today.",
                                       "🌈 Hopeful Morning! 'For I know the plans I have for you,' declares the Lord. – Jeremiah 29:11. Embrace His plans for you.",
                                       "🛐 Guided Morning! 'Trust in the Lord with all your heart.' – Proverbs 3:5. Seek His guidance as you start your day.",
                                       "🌼 Celebrate Creation! 'The earth is the Lord’s, and everything in it.' – Psalm 24:1. Appreciate the beauty around you.",
                                       "✨ Timely Morning! 'He has made everything beautiful in its time.' – Ecclesiastes 3:11. Trust His timing in all things.",
                                       "🕯️ Enlightened Day! 'Your word is a lamp for my feet, a light on my path.' – Psalm 119:105. Let His word guide you.",
                                       "❤️ Love-Filled Morning! 'Above all, love each other deeply.' – 1 Peter 4:8. Love deeply and sincerely today.",
                                       "👣 Following His Steps! 'He leads me in paths of righteousness for His name’s sake.' – Psalm 23:3. Follow His righteous path.",
                                       "📖 Meditative Morning! 'Blessed is the one... whose delight is in the law of the Lord.' – Psalm 1:1-2. Delight in His teachings.",
                                       "🌍 Courageous Day Ahead! 'Be strong and courageous. Do not be afraid.' – Deuteronomy 31:6. Be brave in all you do.",
                                       "🌦️ Comforting Start! 'God is our refuge and strength, an ever-present help in trouble.' – Psalm 46:1. Find comfort in Him.",
                                       "🌹 Rosy Morning! 'Let all that you do be done in love.' – 1 Corinthians 16:14. Act in love today.",
                                       "🌄 Glorious Morning! 'The Lord has done great things for us, and we are filled with joy.' – Psalm 126:3. Rejoice in His blessings.",
                                       "🌟 Starry Dawn! 'Those who are wise shall shine like the brightness of the sky above.' – Daniel 12:3. Shine with wisdom today.",
                                       "🌼 Grateful Awakening! 'Every good gift and every perfect gift is from above.' – James 1:17. Be grateful for today's gifts.",
                                       "🙏 Prayerful Morning! 'Pray without ceasing.' – 1 Thessalonians 5:17. Start your day with a prayerful heart."
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
        let bodyArray: [String] = ["💜 We conquered another day! Lets end the day with gratitude and speaking life into tomorrow.",
                                   "🌙 As you end your day, remember 'In peace I will lie down and sleep, for you alone, LORD, make me dwell in safety.' (Psalm 4:8). Rest well in His care.",
                                   "🌌 Reflect on 'By day the LORD directs his love, at night his song is with me— a prayer to the God of my life.' (Psalm 42:8). Sleep with a song of gratitude in your heart.",
                                   "✨ 'The heavens declare the glory of God; the skies proclaim the work of his hands.' (Psalm 19:1) Gaze at the stars and sleep peacefully, knowing you're part of His marvelous creation.",
                                   "🌒 'He gives strength to the weary and increases the power of the weak.' (Isaiah 40:29) As you rest tonight, may you be renewed by His strength.",
                                   "🌠 'Cast all your anxiety on him because he cares for you.' (1 Peter 5:7) Let go of your worries as you rest tonight, entrusting them to His loving care.",
                                   "💫 'Come to me, all you who are weary and burdened, and I will give you rest.' (Matthew 11:28) As you prepare to sleep, remember His promise of rest for your soul.",
                                   "🌜 'You will keep in perfect peace those whose minds are steadfast, because they trust in you.' (Isaiah 26:3) Rest with a peaceful heart and a mind at ease in His presence.",
                                   "⭐ 'God is our refuge and strength, an ever-present help in trouble.' (Psalm 46:1) Sleep soundly knowing you are in His safe refuge.",
                                   "🌊 'He stilled the storm to a whisper; the waves of the sea were hushed.' (Psalm 107:29) May your night be calm and your rest deep, as He quiets the storms around you.",
                                   "🌹 'I lay down and slept, yet I woke up in safety, for the LORD was watching over me.' (Psalm 3:5) Close your eyes in peace, for He watches over you.",
                                   "🌟 Reflect on your day with gratitude. Remember, every day is a gift. Let's end this one with positive thoughts!",
                                   "🌅 As the day winds down, take a moment to affirm your achievements and be thankful for the journey. You've done well!",
                                   "🙏 Embrace the evening with a heart full of gratitude. Let's count our blessings together as we say goodbye to another beautiful day.",
                                   "✨ End your day on a high note! Reflect on what went well today and be grateful for these moments. Sweet dreams ahead!",
                                   "🌙 As the stars appear, let's take a minute to appreciate the day's blessings. Every day is a story of gratitude.",
                                   "💖 Close your day with a smile. Think of three things you're grateful for today. Gratitude brings peace.",
                                   "🌌 Nighttime is a canvas for gratitude. Paint it with your positive thoughts and affirmations. Sleep well, dream big!",
                                   "🌛 Before you drift to sleep, remember to count your blessings, not your troubles. Sweet dreams of gratitude!",
                                   "🌠 End your day with a gratitude journey. Reflect on the good moments, big or small. Every day is a blessing.",
                                   "💤 As you prepare to rest, take a moment of gratitude. What made you smile today? Cherish these gems of joy!",
                                   "🌒 The moon is out, and it's time for gratitude. Reflect on today's gifts and wake up refreshed for a new day!",
                                   "🌊 Let the waves of gratitude wash over you tonight. Think of the happy moments from your day as you drift off to sleep.",
                                   "🌼 Evening is a time for reflection. Look back on today with a grateful heart and a mind full of positive affirmations.",
                                   "✨ As the day closes, remember to give thanks for the journey. Every step is an opportunity for growth and gratitude.",
                                   "🌙 As the day ends, remember to count your blessings, not your troubles. You are loved and cherished by the Lord.",
                                   "✨ Reflect on the day with gratitude. Every moment is a gift from God, cherish it.",
                                   "🌟 End your day with a peaceful heart. Remember, God's love is with you through every moment.",
                                   "🙏 Give thanks for the day's blessings. Sleep peacefully knowing God is watching over you.",
                                   "💤 As you lay down to sleep, release your worries. Trust in God’s plan for your tomorrow.",
                                   "🌈 Take a moment to appreciate the day's joys and lessons. Each is a step closer to God’s wisdom.",
                                   "🕊️ End your day with a prayer of gratitude. Thank God for His endless love and guidance.",
                                  "😊 Reflect on the moments that made you smile today. Cherish these blessings from above.",
                                   "📖 Remember, each day is a testament to God's glorious plan. Sleep well in His grace.",
                                  "🌜 As night falls, let go of your stresses. Rest in God’s comforting embrace.",
                                  "⭐ Count the stars and remember, God’s promises are just as numerous and faithful.",
                                   "🌌 Let the quiet of the night bring you closer to God’s whisper, guiding and soothing you.",
                                   "🛌 Embrace the peace of the night. God’s love is the blanket that keeps you warm.",
                                   "🌱 As you end your day, remember: With God, every challenge faced is an opportunity to grow.",
                                  "❤️ Take a deep breath and feel God's presence. You are never alone, even in the darkest night.",
                                   "🙌 Give thanks for the lessons of the day. Each experience is a stepping stone on your spiritual journey.",
                                   "🌤️ Sleep in peace tonight, for God has promised a new day of blessings and opportunities.",
                                   "🌠 Let the silence of the night be a canvas for your prayers and dreams. God is listening.",
                                   "🛏️ As you close your eyes, leave your worries behind. God holds your tomorrow with hope and love.",
                                   "🌺 Remember, each night is a chance to reset, refresh, and be reminded of God’s endless grace.",
                                   "🕯️ Cherish the stillness of the night. It’s a sacred time to connect with God and your inner self.",
                                   "🌊 As the world quiets down, let your heart find its rhythm in God’s unchanging love.",
                                  "🌼 Give thanks for today’s journey. Sleep well knowing God walks beside you every day.",
                                   "🌹 Let the calmness of the night fill your soul. God’s peace is the greatest comfort.",
                                   "🌙 Close your day with a thankful heart. Each night is a reminder of God's faithful presence in your life.",
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
