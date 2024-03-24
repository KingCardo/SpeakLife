//
//  StreakDetails.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 3/17/24.
//

import SwiftUI


struct DayCompletion: Codable {
    let date: Date
    var isCompleted: Bool
}

final class StreakViewModel: ObservableObject {
    @Published var weekCompletions: [DayCompletion] = []
    
    @AppStorage("currentStreak") var currentStreak = 0
    @AppStorage("longestStreak") var longestStreak = 0
    @AppStorage("totalDaysCompleted") var totalDaysCompleted = 0
    
    @Published var titleText: String = ""
    @Published var subTitleText: String = ""
    @Published var subTitleDetailText: String = ""
    
    init() {
        loadFromUserDefaults()
        NotificationCenter.default.addObserver(self, selector: #selector(eventCompletedReceived), name: Notification.Name("StreakCompleted"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func eventCompletedReceived() {
        completeEvent()
    }
    
    func updateCompletionStatus(for date: Date, isCompleted: Bool) {
        if let index = weekCompletions.firstIndex(where: { $0.date == date }) {
            weekCompletions[index].isCompleted = isCompleted
            saveToUserDefaults()
        }
    }
    
    // Call this method when an event is completed
    func markDayAsCompleted(for date: Date) {
        updateCompletionStatus(for: date, isCompleted: true)
    }
    
    func completeEvent() {
        let today = Calendar.current.startOfDay(for: Date())
        markDayAsCompleted(for: today)
        
    }
    
    
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weekCompletions) {
            UserDefaults.standard.set(encoded, forKey: "weekCompletions")
        }
    }
    
    func loadFromUserDefaults() {
        let titleText = currentStreak == 1 ? "\(currentStreak) day" : "\(currentStreak) days"
        let subTitleText = longestStreak == 1 ? "\(longestStreak) day" : "\(longestStreak) days"
        let subTitleDetailText = totalDaysCompleted == 1 ? "\(totalDaysCompleted) day" : "\(totalDaysCompleted) days"
        self.titleText = "\(titleText)"
        self.subTitleText = "\(subTitleText)"
        self.subTitleDetailText = "\(subTitleDetailText)"
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        
        if let savedCompletions = UserDefaults.standard.object(forKey: "weekCompletions") as? Data {
            let decoder = JSONDecoder()
            
            if let loadedCompletions = try? decoder.decode([DayCompletion].self, from: savedCompletions) {
                weekCompletions = (0..<7).compactMap { offset in
                    let currentDate = calendar.date(byAdding: .day, value: offset, to: weekStart)!
                    if let loaded = loadedCompletions.first(where: { $0.date == currentDate }) {
                        return loaded
                    } else {
                        return DayCompletion(date: currentDate, isCompleted: false)
                    }
                }
            }
            
        } else {
            weekCompletions = (0..<7).compactMap { offset in
                let currentDate = calendar.date(byAdding: .day, value: offset, to: weekStart)!
                // Initially set isCompleted to false
                return DayCompletion(date: currentDate, isCompleted: false)
            }
        }
    }
}

struct StreakView: View {
    let streak: [Bool]
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        HStack {
            ForEach(0..<daysOfWeek.count, id: \.self) { index in
                VStack {
                    Text(daysOfWeek[index])
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Image(systemName: streak[index] ? "heart.fill" : "circle")
                        .foregroundColor(streak[index] ? .red : .gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}



struct StreakSheet: View {
    @Binding var isShown: Bool
    @ObservedObject var streakViewModel: StreakViewModel
    
    let titleFont = Font.custom("AppleSDGothicNeo-Regular", size: 26, relativeTo: .title)
    let bodyFont = Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body)
    
    
    var body: some View {
        ZStack{
            Gradients().purple
            VStack {
                StreakView(streak: streakViewModel.weekCompletions.map { $0.isCompleted })
                Text("Current streak 🔥")
                    .font(titleFont)
                
                HStack {
                    Text(streakViewModel.titleText)
                        .font(bodyFont)
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .frame(width: 15, height: 20)
                }
                Spacer()
                    .frame(height: 8)
                
                
                Text("Longest streak 🥇")
                    .font(titleFont)
                HStack {
                    Text(streakViewModel.subTitleText)
                        .font(bodyFont)
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .frame(width: 15, height: 20)
                }
                
                Text("Total days completed 📈")
                    .font(titleFont)
                HStack {
                    Text(streakViewModel.subTitleDetailText)
                        .font(bodyFont)
                }
            }
        }
        .foregroundColor(.white)
        .onAppear {
            streakViewModel.loadFromUserDefaults()
        }
        
    }
}
