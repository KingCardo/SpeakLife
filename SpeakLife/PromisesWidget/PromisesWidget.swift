//
//  PromisesWidget.swift
//  PromisesWidget
//
//  Created by Riccardo Washington on 11/2/22.
//

import WidgetKit
import SwiftUI

// MARK: - Constants

private enum WidgetConstants {
    static let appGroupSuiteName = "group.com.speaklife.widget"
    static let syncedPromisesKey = "syncedPromises"
    static let fallbackPromise = "I am blessed!"
    static let placeholderText = "Loading..."
    static let customFontName = "BodoniSvtyTwoOSITCTT-Book"
    
    enum Design {
        static let backgroundOpacity: Double = 0.85
        static let greetingOpacity: Double = 0.8
        static let contentSpacing: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 8
        
        enum FontSizes {
            static let small: CGFloat = 14
            static let medium: CGFloat = 16
            static let large: CGFloat = 18
            static let greeting: CGFloat = 12
        }
    }
    
    enum UserPreferences {
        static let selectedCategoriesKey = "selectedCategories"
        static let recentCategoriesKey = "recentCategories"
        static let categoryUsageKey = "categoryUsage"
        static let lastCategoryUpdateKey = "lastCategoryUpdate"
    }
    
    enum TimeRanges {
        static let morningStart = 5
        static let morningEnd = 11
        static let afternoonEnd = 17
        static let eveningEnd = 21
    }
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), promise: WidgetConstants.placeholderText)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let promise = getCurrentPromise()
        completion(SimpleEntry(date: Date(), promise: promise))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let now = Date()
        let promise = getCurrentPromise()
        
        // Create entries for the current hour and next few hours
        var entries: [SimpleEntry] = []
        
        // Current entry
        entries.append(SimpleEntry(date: now, promise: promise))
        
        // Next hour entry (different promise if available)
        if let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: now) {
            let nextPromise = getPromiseForTime(nextHour)
            entries.append(SimpleEntry(date: nextHour, promise: nextPromise))
        }
        
        // Determine next refresh time (next hour boundary)
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? 
                         Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now
        
        let timeline = Timeline(entries: entries, policy: .after(nextRefresh))
        completion(timeline)
    }
    
    // MARK: - Private Methods
    
    private func getCurrentPromise() -> String {
        return getPromiseForTime(Date())
    }
    
    private func getPromiseForTime(_ date: Date) -> String {
        guard let widgetDefaults = UserDefaults(suiteName: WidgetConstants.appGroupSuiteName) else {
            return WidgetConstants.fallbackPromise
        }
        
        // Try to get category-filtered promises first
        if let categoryPromise = getCategoryFilteredPromise(from: widgetDefaults, for: date) {
            return categoryPromise
        }
        
        // Fallback to all synced promises
        guard let syncedPromises = widgetDefaults.stringArray(forKey: WidgetConstants.syncedPromisesKey),
              !syncedPromises.isEmpty else {
            return WidgetConstants.fallbackPromise
        }
        
        // Use hour-based selection for consistent daily rotation
        let hour = Calendar.current.component(.hour, from: date)
        let safeIndex = hour % syncedPromises.count
        
        return syncedPromises[safeIndex]
    }
    
    private func getCategoryFilteredPromise(from defaults: UserDefaults, for date: Date) -> String? {
        // Strategy 1: Time-based category intelligence
        let contextualCategories = getContextualCategories(for: date)
        
        for category in contextualCategories {
            if let categoryPromises = defaults.stringArray(forKey: "category_\(category)"),
               !categoryPromises.isEmpty {
                let hour = Calendar.current.component(.hour, from: date)
                let index = hour % categoryPromises.count
                return categoryPromises[index]
            }
        }
        
        // Strategy 2: User's selected categories
        if let selectedCategories = defaults.stringArray(forKey: WidgetConstants.UserPreferences.selectedCategoriesKey) {
            for category in selectedCategories {
                if let categoryPromises = defaults.stringArray(forKey: "category_\(category)"),
                   !categoryPromises.isEmpty {
                    let hour = Calendar.current.component(.hour, from: date)
                    let index = hour % categoryPromises.count
                    return categoryPromises[index]
                }
            }
        }
        
        return nil
    }
    
    private func getContextualCategories(for date: Date) -> [String] {
        let hour = Calendar.current.component(.hour, from: date)
        let dayOfWeek = Calendar.current.component(.weekday, from: date)
        
        var categories: [String] = []
        
        // Time-based context
        switch hour {
        case 5...8:
            categories.append(contentsOf: ["Morning", "Strength", "New Beginnings", "Energy"])
        case 9...11:
            categories.append(contentsOf: ["Work", "Focus", "Productivity", "Wisdom"])
        case 12...13:
            categories.append(contentsOf: ["Rest", "Reflection", "Gratitude"])
        case 14...17:
            categories.append(contentsOf: ["Perseverance", "Strength", "Purpose"])
        case 18...20:
            categories.append(contentsOf: ["Family", "Love", "Gratitude", "Reflection"])
        case 21...23:
            categories.append(contentsOf: ["Peace", "Rest", "Forgiveness", "Comfort"])
        default:
            categories.append(contentsOf: ["Peace", "Comfort", "Protection"])
        }
        
        // Day-based context
        switch dayOfWeek {
        case 1: // Sunday
            categories.append(contentsOf: ["Worship", "Rest", "Family", "Reflection"])
        case 2: // Monday
            categories.append(contentsOf: ["New Beginnings", "Strength", "Purpose", "Energy"])
        case 6, 7: // Friday/Saturday
            categories.append(contentsOf: ["Gratitude", "Joy", "Celebration", "Rest"])
        default:
            categories.append(contentsOf: ["Work", "Perseverance", "Wisdom"])
        }
        
        return categories
    }
}

// MARK: - Timeline Entry

/// Represents a single timeline entry for the widget
struct SimpleEntry: TimelineEntry {
    let date: Date
    let promise: String
    
    init(date: Date, promise: String) {
        self.date = date
        self.promise = promise.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Widget Entry View

struct PromisesWidgetEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: Provider.Entry
    
    var body: some View {
        widgetContent
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityText)
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var widgetContent: some View {
        if #available(iOS 17.0, *) {
            contentView
                .containerBackground(.clear, for: .widget)
        } else {
            contentView
        }
    }
    
    private var contentView: some View {
        ZStack {
            WidgetGradientBackground()
                .opacity(WidgetConstants.Design.backgroundOpacity)
            
            VStack(spacing: WidgetConstants.Design.contentSpacing) {
                Spacer()
                
                promiseText
                
                Spacer()
                
                if shouldShowGreeting {
                    greetingText
                }
            }
        }
    }
    
    private var promiseText: some View {
        Text(entry.promise)
            .foregroundColor(.white)
            .font(.custom(WidgetConstants.customFontName, size: fontSize))
            .fontWeight(.medium)
            .multilineTextAlignment(.center)
            .padding(.horizontal, WidgetConstants.Design.horizontalPadding)
            .minimumScaleFactor(0.8) // Allow text scaling for better fit
    }
    
    private var greetingText: some View {
        Text(TimeBasedGreeting.current.message)
            .font(.system(size: WidgetConstants.Design.FontSizes.greeting, weight: .light))
            .foregroundColor(.white.opacity(WidgetConstants.Design.greetingOpacity))
            .padding(.bottom, WidgetConstants.Design.bottomPadding)
    }
    
    // MARK: - Computed Properties
    
    private var fontSize: CGFloat {
        switch family {
        case .systemSmall:
            return WidgetConstants.Design.FontSizes.small
        case .systemMedium:
            return WidgetConstants.Design.FontSizes.medium
        default:
            return WidgetConstants.Design.FontSizes.large
        }
    }
    
    private var shouldShowGreeting: Bool {
        family == .systemLarge
    }
    
    private var accessibilityText: String {
        if shouldShowGreeting {
            return "\(entry.promise). \(TimeBasedGreeting.current.message)"
        }
        return entry.promise
    }
}

// MARK: - Time-Based Greeting System

enum TimeBasedGreeting {
    case morning, afternoon, evening, night
    
    var message: String {
        switch self {
        case .morning:
            return "Good morning! Start your day with faith."
        case .afternoon:
            return "Good afternoon! Keep your spirit strong."
        case .evening:
            return "Good evening! Reflect on God's blessings."
        case .night:
            return "Good night! Rest in His promises."
        }
    }
    
    static var current: TimeBasedGreeting {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case WidgetConstants.TimeRanges.morningStart...WidgetConstants.TimeRanges.morningEnd:
            return .morning
        case (WidgetConstants.TimeRanges.morningEnd + 1)...WidgetConstants.TimeRanges.afternoonEnd:
            return .afternoon
        case (WidgetConstants.TimeRanges.afternoonEnd + 1)...WidgetConstants.TimeRanges.eveningEnd:
            return .evening
        default:
            return .night
        }
    }
}

// MARK: - Gradient Background

struct WidgetGradientBackground: View {
    
    private enum GradientColors {
        static let morning: [Color] = [.orange, .yellow, .pink]
        static let afternoon: [Color] = [.blue, .cyan, .teal]
        static let evening: [Color] = [.purple, .indigo, .blue]
        static let night: [Color] = [.black, .purple, .indigo]
    }
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: timeBasedColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var timeBasedColors: [Color] {
        let colors: [Color]
        
        switch TimeBasedGreeting.current {
        case .morning:
            colors = GradientColors.morning
        case .afternoon:
            colors = GradientColors.afternoon
        case .evening:
            colors = GradientColors.evening
        case .night:
            colors = GradientColors.night
        }
        
        // Return a stable 2-color gradient (no randomization for consistency)
        return Array(colors.prefix(2))
    }
}

// MARK: - Widget Configuration

@main
struct PromisesWidget: Widget {
    private static let widgetKind = "PromisesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: Self.widgetKind,
            provider: Provider()
        ) { entry in
            PromisesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Promises")
        .description("Inspiring Bible promises that change throughout the day to encourage your faith journey.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled() // Use full widget space
    }
}

// MARK: - Widget Preview

#if DEBUG
struct PromisesWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Small widget preview
            PromisesWidgetEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    promise: "Trust in the Lord with all your heart; do not depend on your own understanding."
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small")
            
            // Medium widget preview
            PromisesWidgetEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    promise: "For I know the plans I have for you, says the Lord. They are plans for good and not for disaster, to give you a future and a hope."
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium")
            
            // Large widget preview
            PromisesWidgetEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    promise: "Don't worry about anything; instead, pray about everything. Tell God what you need, and thank him for all he has done."
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDisplayName("Large")
        }
    }
}
#endif