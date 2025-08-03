//
//  EnhancedStreakViewModel.swift
//  SpeakLife
//
//  Enhanced streak view model with daily checklist functionality
//

import SwiftUI
import Combine
import Firebase

final class EnhancedStreakViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var todayChecklist: DailyChecklist
    @Published var streakStats: StreakStats
    @Published var showCompletionCelebration = false
    @Published var celebrationData: CompletionCelebration?
    @Published var showFireAnimation = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let checklistKey = "dailyChecklist"
    private let streakStatsKey = "streakStats"
    
    // MARK: - Initialization
    init() {
        self.todayChecklist = Self.createTodayChecklist()
        self.streakStats = StreakStats()
        
        loadData()
        checkStreakValidity()
        
        // Listen for app becoming active to check for new day
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    func completeTask(taskId: String) {
        Analytics.logEvent("complete_task", parameters: ["task_id": taskId])
        guard let taskIndex = todayChecklist.tasks.firstIndex(where: { $0.id == taskId }),
              !todayChecklist.tasks[taskIndex].isCompleted else { return }
        
        todayChecklist.tasks[taskIndex].isCompleted = true
        todayChecklist.tasks[taskIndex].completedAt = Date()
        
        // Check if all tasks are now completed
        if todayChecklist.isCompleted && todayChecklist.completedAt == nil {
            completeDay()
        }
        
        saveData()
    }
    
    func uncompleteTask(taskId: String) {
        guard let taskIndex = todayChecklist.tasks.firstIndex(where: { $0.id == taskId }),
              todayChecklist.tasks[taskIndex].isCompleted else { return }
        
        todayChecklist.tasks[taskIndex].isCompleted = false
        todayChecklist.tasks[taskIndex].completedAt = nil
        
        // If day was completed but now a task is unchecked, mark day as incomplete
        if todayChecklist.completedAt != nil {
            todayChecklist.completedAt = nil
        }
        
        saveData()
    }
    
    func resetDay() {
        todayChecklist = Self.createTodayChecklist()
        saveData()
    }
    
    // MARK: - Private Methods
    private func completeDay() {
        let today = Date()
        todayChecklist.completedAt = today
        
        let wasNewRecord = streakStats.currentStreak >= streakStats.longestStreak
        streakStats.updateStreak(for: today)
        
        // Create celebration data
        celebrationData = CompletionCelebration(
            streakNumber: streakStats.currentStreak,
            isNewRecord: wasNewRecord && streakStats.currentStreak > streakStats.longestStreak,
            motivationalMessage: CompletionCelebration.generateMessage(
                for: streakStats.currentStreak,
                isRecord: wasNewRecord && streakStats.currentStreak > streakStats.longestStreak
            ),
            shareImage: generateShareImage()
        )
        
        // Show fire animation first, then celebration
        showFireAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showFireAnimation = false
            self.showCompletionCelebration = true
        }
        
        saveData()
    }
    
    private func checkStreakValidity() {
        streakStats.checkStreakValidity()
        saveData()
    }
    
    @objc private func appDidBecomeActive() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let checklistDate = calendar.startOfDay(for: todayChecklist.date)
        
        if today != checklistDate {
            // New day, create fresh checklist
            todayChecklist = Self.createTodayChecklist()
            checkStreakValidity()
            saveData()
        }
    }
    
    private static func createTodayChecklist() -> DailyChecklist {
        let today = Calendar.current.startOfDay(for: Date())
        return DailyChecklist(
            date: today,
            tasks: DailyTask.defaultTasks
        )
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        // Save checklist
        if let checklistData = try? JSONEncoder().encode(todayChecklist) {
            userDefaults.set(checklistData, forKey: checklistKey)
        }
        
        // Save streak stats
        if let statsData = try? JSONEncoder().encode(streakStats) {
            userDefaults.set(statsData, forKey: streakStatsKey)
        }
    }
    
    private func loadData() {
        // Load checklist
        if let checklistData = userDefaults.data(forKey: checklistKey),
           let checklist = try? JSONDecoder().decode(DailyChecklist.self, from: checklistData) {
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let checklistDate = calendar.startOfDay(for: checklist.date)
            
            if today == checklistDate {
                todayChecklist = checklist
            }
        }
        
        // Load streak stats
        if let statsData = userDefaults.data(forKey: streakStatsKey),
           let stats = try? JSONDecoder().decode(StreakStats.self, from: statsData) {
            streakStats = stats
        }
    }
    
    // MARK: - Share Image Generation
    private func generateShareImage() -> UIImage? {
        let size = CGSize(width: 1080, height: 1920) // Instagram story size
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Create gradient background
        let colors = [UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1),
                     UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1)]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                colors: colors.map { $0.cgColor } as CFArray,
                                locations: [0.0, 1.0])!
        
        context.drawLinearGradient(gradient,
                                 start: CGPoint(x: 0, y: 0),
                                 end: CGPoint(x: 0, y: size.height),
                                 options: [])
        
        // Add content
        let textColor = UIColor.white
        let font = UIFont.systemFont(ofSize: 48, weight: .bold)
        let subFont = UIFont.systemFont(ofSize: 32, weight: .medium)
        
        // Fire emoji and streak number
        let fireText = "🔥 \(streakStats.currentStreak)"
        let fireAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 72, weight: .bold),
            .foregroundColor: textColor
        ]
        
        let fireSize = fireText.size(withAttributes: fireAttributes)
        let fireRect = CGRect(x: (size.width - fireSize.width) / 2,
                             y: size.height * 0.3,
                             width: fireSize.width,
                             height: fireSize.height)
        fireText.draw(in: fireRect, withAttributes: fireAttributes)
        
        // Days text
        let daysText = "DAYS STRONG!"
        let daysAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        let daysSize = daysText.size(withAttributes: daysAttributes)
        let daysRect = CGRect(x: (size.width - daysSize.width) / 2,
                             y: fireRect.maxY + 20,
                             width: daysSize.width,
                             height: daysSize.height)
        daysText.draw(in: daysRect, withAttributes: daysAttributes)
        
        // Motivational message
        if let message = celebrationData?.motivationalMessage {
            let messageAttributes: [NSAttributedString.Key: Any] = [
                .font: subFont,
                .foregroundColor: textColor
            ]
            
            let messageSize = message.size(withAttributes: messageAttributes)
            let messageRect = CGRect(x: (size.width - messageSize.width) / 2,
                                   y: daysRect.maxY + 40,
                                   width: messageSize.width,
                                   height: messageSize.height)
            message.draw(in: messageRect, withAttributes: messageAttributes)
        }
        
        // SpeakLife app icon logo - try multiple sources
        let logoImageNames = ["appIconDisplay", "speaklifeicon", "speaklifeicon 1", "AppIcon", "app-icon", "new-speaklifeiconoptionsv2-01 1"]
        var foundImage: UIImage?
        var foundImageName: String?
        
        for imageName in logoImageNames {
            if let image = UIImage(named: imageName) {
                foundImage = image
                foundImageName = imageName
                print("✅ Found logo image: \(imageName)")
                break
            } else {
                print("❌ Could not find logo image: \(imageName)")
            }
        }
        
        if let appIcon = foundImage {
            let logoSize: CGFloat = 100
            let logoRect = CGRect(x: (size.width - logoSize) / 2,
                                 y: size.height * 0.82,
                                 width: logoSize,
                                 height: logoSize)
            
            // Draw circular background with better visibility
            let circleRect = logoRect
            context.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
            context.fillEllipse(in: circleRect)
            
            // Draw stronger border
            context.setStrokeColor(UIColor.black.withAlphaComponent(0.1).cgColor)
            context.setLineWidth(1)
            context.strokeEllipse(in: circleRect)
            
            // Draw app icon - first try without clipping to test
            let iconRect = circleRect.insetBy(dx: 8, dy: 8)
            print("✅ Drawing logo at rect: \(iconRect), image size: \(appIcon.size)")
            
            // Try simple draw first
            appIcon.draw(in: iconRect)
            
            // Also try with clipping for circular effect
            context.saveGState()
            context.addEllipse(in: iconRect)
            context.clip()
            appIcon.draw(in: iconRect)
            context.restoreGState()
        } else {
            // Fallback to text logo if image not found
            let logoText = "SpeakLife"
            let logoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: textColor.withAlphaComponent(0.9)
            ]
            
            let logoSize = logoText.size(withAttributes: logoAttributes)
            let logoRect = CGRect(x: (size.width - logoSize.width) / 2,
                                 y: size.height * 0.87,
                                 width: logoSize.width,
                                 height: logoSize.height)
            logoText.draw(in: logoRect, withAttributes: logoAttributes)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - Legacy Compatibility
extension EnhancedStreakViewModel {
    // Bridge to existing StreakViewModel interface
    var currentStreak: Int { streakStats.currentStreak }
    var longestStreak: Int { streakStats.longestStreak }
    var totalDaysCompleted: Int { streakStats.totalDaysCompleted }
    var hasCurrentStreak: Bool { streakStats.currentStreak > 0 }
    
    var titleText: String {
        let streak = streakStats.currentStreak
        return streak == 1 ? "\(streak) day" : "\(streak) days"
    }
    
    var subTitleText: String {
        let longest = streakStats.longestStreak
        return longest == 1 ? "\(longest) day" : "\(longest) days"
    }
    
    var subTitleDetailText: String {
        let total = streakStats.totalDaysCompleted
        return total == 1 ? "\(total) day" : "\(total) days"
    }
}
