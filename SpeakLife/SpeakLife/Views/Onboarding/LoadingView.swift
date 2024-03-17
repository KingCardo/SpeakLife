//
//  LoadingView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 1/23/24.
//

import SwiftUI

struct GoldBadgeView: View {
    @State private var animate = false
    @State private var isVisible = true

    var body: some View {
        ZStack {
            // Sparkle effect
            ForEach(0..<8) { i in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 10)
                    .foregroundColor(.yellow)
                    .opacity(animate ? 0 : 1) // Start fully visible and fade out
                    .offset(y: animate ? -30 : -20) // Move the stars outward as they fade
                    .rotationEffect(Angle(degrees: Double(i) * 45))
                    .animation(.easeOut(duration: 0.5).delay(Double(i) * 0.1), value: animate) // Staggered animation for each star
            }

            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .scaleEffect(animate ? 1 : 0)

            Image(systemName: "star.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
        }
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isVisible = false
                }
            }
        }
    }
}

final class TimerViewModel: ObservableObject {
    static let totalDuration = 10 * 60
    
    @AppStorage("currentStreak") var currentStreak = 0
    @AppStorage("longestStreak") var longestStreak = 0
    @AppStorage("lastCompletedStreak") var lastCompletedStreak: Date?
    
    @Published private(set) var isComplete = false
    @Published private(set) var timeRemaining: Int = 0
    @Published private(set) var isActive = false
    @Published var timer: Timer? = nil
    
    init() {
        loadRemainingTime()
        checkAndUpdateCompletionDate()
    }
    
    func setupMidnightReset() {
        let now = Date()
        let calendar = Calendar.current
        if let midnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) {
            let midnightResetTimer = Timer(fireAt: midnight, interval: 0, target: self, selector: #selector(resetTimerAtMidnight), userInfo: nil, repeats: false)
            RunLoop.main.add(midnightResetTimer, forMode: .common)
        }
    }
    
    @objc func resetTimerAtMidnight() {
        isComplete = false
        timeRemaining = TimerViewModel.totalDuration // Reset to 10 minutes
        stopTimer()
        startTimer()
        checkAndUpdateCompletionDate()
    }
    
    func runCountdownTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if checkIfCompletedToday() {
                isComplete = true
                isActive = false
                return
            }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                UserDefaults.standard.removeObject(forKey: "timestamp")
                isComplete = true
                saveCompletionDate()
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak += 1
                }
                timer.invalidate()
                self.isActive = false
                // Prepare for the next day's reset if needed, or set up another logic as per your requirement
                self.setupMidnightReset()
            }
        }
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
        
        return completionDate < calendar.startOfDay(for: currentDate)
    }
    
    func midnightOfTomorrow(after date: Date) -> Date? {
           if let nextDay = calendar.date(byAdding: .day, value: 1, to: date) {
               return calendar.startOfDay(for: nextDay)
           }
           return nil
       }
       
       func checkIfMidnightOfTomorrowHasPassed() -> Bool {
           guard let lastCompletionDate = lastCompletedStreak,
                 let midnightAfterCompletion = midnightOfTomorrow(after: lastCompletionDate) else {
               return false
           }
           
           return Date() > midnightAfterCompletion
       }
    
    func checkAndUpdateCompletionDate() {
        
        if checkIfMidnightOfTomorrowHasPassed(){
            // to do: notify user
            lastCompletedStreak = nil
            currentStreak = 0
        }
    }
    
    func saveRemainingTime() {
       // let timestamp = Date().timeIntervalSince1970
        UserDefaults.standard.set(timeRemaining, forKey: "timeRemaining")
    }
    
    func loadRemainingTime() {
        if checkIfCompletedToday() {
            isComplete = true
            isActive = false
            return
        } else if let savedTimeRemaining = UserDefaults.standard.value(forKey: "timeRemaining") as? Int {
            // Adjust the remaining time based on how much time has passed since the app was last open
            timeRemaining = savedTimeRemaining
        } else {
            timeRemaining = TimerViewModel.totalDuration
        }
    }
    
    func startTimer() {
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
        let totalTime = 10 * 60
        let float = CGFloat(timeRemaining) / CGFloat(totalTime)
        return float
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


struct CountdownTimerView: View {
    var action: (() -> Void)?
    
    @ObservedObject var viewModel: TimerViewModel

    init(viewModel: TimerViewModel, action: (() -> Void)?) {
        self.viewModel = viewModel
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .opacity(0.3)
                .foregroundColor(Constants.DAMidBlue)
            
            Circle()
                .trim(from: 0, to: viewModel.progress(for: viewModel.timeRemaining))
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .foregroundColor(Constants.DAMidBlue)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut(duration: 2), value: viewModel.timeRemaining)
            
            Text(viewModel.timeString(time: viewModel.timeRemaining))
                .font(.caption)
                .foregroundColor(Color.white)
        }
        .frame(width: 50, height: 50)
        
        .onAppear {
            viewModel.loadRemainingTime()
            viewModel.setupMidnightReset()
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.saveRemainingTime()
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
            viewModel.saveRemainingTime()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.saveRemainingTime()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.loadRemainingTime()
            viewModel.setupMidnightReset()
            viewModel.startTimer()
        }
        .onTapGesture {
            action?()
        }
    }
}



struct PersonalizationLoadingView: View {
    
    @EnvironmentObject var appState: AppState
    let size: CGSize
    let callBack: (() -> Void)
    
    @State private var checkedFirst = false
    @State private var checkedSecond = false
    @State private var checkedThird = false
    let delay: Double = Double.random(in: 6...7)
    
    var body: some View {
        ZStack {
            
            if appState.onBoardingTest {
                Image(onboardingBGImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Gradients().purple
                    .edgesIgnoringSafeArea(.all)
            }
            VStack(spacing: 10) {
                VStack(spacing: 10) {
//                    CustomSpinnerView(timeRemaining: <#Int#>, action: <#(() -> Void)?#>)
                    Spacer()
                        .frame(height: 110)
                    
                    Text("Hang tight, while we build your Speak Life plan")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(Animation.easeInOut(duration: 0.5)) {
                            checkedFirst = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(Animation.easeInOut(duration: 0.5)) {
                            checkedSecond = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(Animation.easeInOut(duration: 0.5)) {
                            checkedThird = true
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    BulletPointView(text: "Analyzing answers", isHighlighted: $checkedFirst, delay: 0.5)
                    BulletPointView(text: "Matching your goals", isHighlighted: $checkedSecond, delay: 1.0)
                    BulletPointView(text: "Creating affirmation notifications", isHighlighted: $checkedThird, delay: 1.5)
                }
                .frame(maxWidth: .infinity, alignment: appState.onBoardingTest ? .center : .leading)
                .padding()
            }
            
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation {
                        callBack()
                    }
                }
            }
        }
    }
}

struct BulletPointView: View {
    let text: String
    @Binding var isHighlighted: Bool
    let delay: Double // delay for the animation
    
    var body: some View {
        HStack {
            Image(systemName: isHighlighted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isHighlighted ? Constants.gold : .white)
                .scaleEffect(isHighlighted ? 1.1 : 1.0)
            Text(text)
                .foregroundColor(.white)
        }
        .opacity(!isHighlighted ? 0 : 1)
        .animation(.easeInOut, value: !isHighlighted)
        .onChange(of: isHighlighted) { newValue in
            if newValue {
                withAnimation(Animation.easeInOut(duration: 1.0).delay(delay)) {
                    isHighlighted = newValue
                }
            }
        }
    }
}
