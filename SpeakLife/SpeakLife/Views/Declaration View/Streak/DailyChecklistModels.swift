//
//  DailyChecklistModels.swift
//  SpeakLife
//
//  Daily checklist models for enhanced streak feature
//

import Foundation
import SwiftUI

// MARK: - Daily Task Model
struct DailyTask: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var isCompleted: Bool = false
    var completedAt: Date?
    
    // Default daily tasks
    static let defaultTasks: [DailyTask] = [
        DailyTask(
            id: "speak_affirmation",
            title: "Speak a Favorited Affirmation",
            description: "Declare one of your saved affirmations out loud",
            icon: "speaker.wave.3.fill"
        ),
        DailyTask(
            id: "share_affirmation",
            title: "Share an Affirmation",
            description: "Share God's truth with someone today",
            icon: "square.and.arrow.up.fill"
        ),
        DailyTask(
            id: "read_devotional",
            title: "Read Daily Devotional",
            description: "Spend time in God's Word",
            icon: "book.fill"
        ),
        DailyTask(
            id: "listen_audio",
            title: "Listen to Audio Affirmation",
            description: "Let truth sink deep through audio",
            icon: "headphones"
        )
    ]
}

// MARK: - Daily Checklist Model
struct DailyChecklist: Codable {
    let date: Date
    var tasks: [DailyTask]
    var completedAt: Date?
    
    var isCompleted: Bool {
        tasks.allSatisfy { $0.isCompleted }
    }
    
    var completionProgress: Double {
        let completedCount = tasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(tasks.count)
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
}

// MARK: - Streak Statistics
struct StreakStats: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalDaysCompleted: Int = 0
    var lastCompletedDate: Date?
    
    mutating func updateStreak(for date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        if let lastDate = lastCompletedDate {
            let daysDifference = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysDifference > 1 {
                // Streak broken
                currentStreak = 1
            }
            // If daysDifference == 0, it's the same day, don't update
        } else {
            // First completion
            currentStreak = 1
        }
        
        longestStreak = max(longestStreak, currentStreak)
        totalDaysCompleted += 1
        lastCompletedDate = today
    }
    
    mutating func checkStreakValidity() {
        guard let lastDate = lastCompletedDate else {
            currentStreak = 0
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let daysDifference = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
        
        if daysDifference > 1 {
            currentStreak = 0
        }
    }
}

// MARK: - Completion Celebration Data
struct CompletionCelebration {
    let streakNumber: Int
    let isNewRecord: Bool
    let motivationalMessage: String
    let shareImage: UIImage?
    
    static func generateMessage(for streak: Int, isRecord: Bool) -> String {
        if isRecord {
            return "🏆 NEW RECORD! \(streak) days of speaking LIFE! You're unstoppable!"
        }
        
        switch streak {
        case 1:
            return "🔥 Day 1 Complete! You've started something POWERFUL!"
        case 7:
            return "🔥 ONE WEEK STRONG! Your persistence is moving mountains!"
        case 30:
            return "🔥 30 DAYS! You're transformed by the renewing of your mind!"
        case 100:
            return "🔥 100 DAYS! You're a WARRIOR of faith and declaration!"
        default:
            return "🔥 \(streak) DAYS! Keep speaking life—heaven is listening!"
        }
    }
}