//
//  EnhancedStreakView.swift
//  SpeakLife
//
//  Enhanced streak view that replaces the countdown timer with daily checklist
//

import SwiftUI

struct EnhancedStreakView: View {
    @EnvironmentObject var viewModel: EnhancedStreakViewModel
    @State private var showStreakSheet = false
    @State private var showChecklistView = false
    @State private var showCompletedBanner = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showCompletedBanner && viewModel.todayChecklist.isCompleted {
                // Show completion banner temporarily
                CompletedStreakBadge(streakNumber: viewModel.streakStats.currentStreak)
                    .onTapGesture {
                        showStreakSheet = true
                    }
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        // Auto-collapse after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                showCompletedBanner = false
                            }
                        }
                    }
            } else {
                // Always show compact circle button (default state)
                CompactStreakButton(viewModel: viewModel) {
                    if viewModel.todayChecklist.isCompleted {
                        showStreakSheet = true
                    } else {
                        showChecklistView = true
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: viewModel.todayChecklist.isCompleted) { isCompleted in
            if isCompleted {
                // Show banner when tasks completed
                withAnimation(.easeInOut(duration: 0.5)) {
                    showCompletedBanner = true
                }
            }
        }
        .fullScreenCover(isPresented: $showChecklistView) {
            DailyChecklistFullScreenView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showStreakSheet) {
            EnhancedStreakSheet(
                isShown: $showStreakSheet,
                viewModel: viewModel
            )
        }
        .fullScreenCover(isPresented: $viewModel.showFireAnimation) {
            FireStreakView(streakNumber: viewModel.streakStats.currentStreak)
                .onTapGesture {
                    viewModel.showFireAnimation = false
                    // Show banner after fire animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            showCompletedBanner = true
                        }
                    }
                }
        }
        .fullScreenCover(isPresented: $viewModel.showCompletionCelebration) {
            if let celebration = viewModel.celebrationData {
                CompletionCelebrationView(celebration: celebration)
            }
        }
    }
}

struct CompactStreakButton: View {
    @ObservedObject var viewModel: EnhancedStreakViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.1, green: 0.15, blue: 0.3), Color(red: 0.02, green: 0.07, blue: 0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                // Progress ring
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                    .frame(width: 52, height: 52)
                
                Circle()
                    .trim(from: 0, to: viewModel.todayChecklist.completionProgress)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.todayChecklist.completionProgress)
                
                // Center content
                if viewModel.todayChecklist.isCompleted {
                    // Fire icon with streak number
                    VStack(spacing: -2) {
                        Text("🔥")
                            .font(.system(size: 16))
                        Text("\(viewModel.streakStats.currentStreak)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    // Sexy task count with dots indicator
                    VStack(spacing: 4) {
                        // Main count number
                        Text("\(viewModel.todayChecklist.completedTasksCount)")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Dots indicator instead of fraction
                        HStack(spacing: 3) {
                            ForEach(0..<viewModel.todayChecklist.tasks.count, id: \.self) { index in
                                Circle()
                                    .fill(index < viewModel.todayChecklist.completedTasksCount ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CompletedStreakBadge: View {
    let streakNumber: Int
    @State private var animateFlame = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Fire animation
            ZStack {
                // Background circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                // Animated fire emoji
                Text("🔥")
                    .font(.system(size: 28))
                    .scaleEffect(animateFlame ? 1.1 : 0.9)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                        value: animateFlame
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(streakNumber)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("day streak!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Text("🎉 Daily practice complete!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.green)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.1, green: 0.15, blue: 0.3), Color(red: 0.02, green: 0.07, blue: 0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            animateFlame = true
        }
    }
}

// MARK: - Enhanced Streak Sheet
struct EnhancedStreakSheet: View {
    @Binding var isShown: Bool
    @ObservedObject var viewModel: EnhancedStreakViewModel
    
    private var progress: Double {
        let currentStreak = viewModel.streakStats.currentStreak
        let nextMilestone = getNextMilestone(currentStreak)
        let previousMilestone = getPreviousMilestone(currentStreak)
        
        if currentStreak == 0 {
            return 0.0
        }
        
        let progressInMilestone = Double(currentStreak - previousMilestone)
        let milestoneRange = Double(nextMilestone - previousMilestone)
        
        return progressInMilestone / milestoneRange
    }
    
    private func getNextMilestone(_ current: Int) -> Int {
        let milestones = [7, 14, 30, 50, 100, 200, 365]
        return milestones.first { $0 > current } ?? (current + 100)
    }
    
    private func getPreviousMilestone(_ current: Int) -> Int {
        let milestones = [0, 7, 14, 30, 50, 100, 200, 365]
        return milestones.last { $0 <= current } ?? 0
    }
    
    private var showSparkles: Bool {
        progress >= 0.8
    }
    
    var body: some View {
        ZStack {
            Gradients().speakLifeCYOCell
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation bar with close button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isShown = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                VStack(spacing: 20) {
                    HandleBar()
                        .padding(.top, 12)
                
                // Today's checklist status
                DailyChecklistSummary(viewModel: viewModel)
                    .padding(.horizontal, 20)
                
                // Enhanced Progress ring with milestone info
                EnhancedProgressRing(
                    progress: progress,
                    currentStreak: viewModel.streakStats.currentStreak,
                    nextMilestone: getNextMilestone(viewModel.streakStats.currentStreak),
                    showSparkles: showSparkles
                )
                .padding(.top, 12)
                
                // Enhanced streak stats
                EnhancedStreakStatsView(viewModel: viewModel)
                    .padding(.horizontal, 24)
                
                // Action buttons
                if !viewModel.todayChecklist.isCompleted {
                    VStack(spacing: 12) {
                        Button("Complete Daily Practice") {
                            isShown = false
                        }
                        .font(.headline)
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        Button("Reset Today's Tasks") {
                            viewModel.resetDay()
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 24)
                }
                
                    Spacer()
                }
                
                Spacer()
            }
        }
        .foregroundColor(.white)
    }
}

struct DailyChecklistSummary: View {
    @ObservedObject var viewModel: EnhancedStreakViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Practice")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if viewModel.todayChecklist.isCompleted {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Complete!")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                } else {
                    Text("\(viewModel.todayChecklist.completedTasksCount)/\(viewModel.todayChecklist.tasks.count)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Mini task list
            LazyVStack(spacing: 8) {
                ForEach(viewModel.todayChecklist.tasks) { task in
                    HStack {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .white.opacity(0.5))
                            .font(.system(size: 16))
                        
                        Text(task.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .strikethrough(task.isCompleted)
                        
                        Spacer()
                        
                        if task.isCompleted {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
}

struct EnhancedStreakStatsView: View {
    @ObservedObject var viewModel: EnhancedStreakViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Hero stat - Current streak
            PremiumStatCard(
                label: "Current Streak",
                value: "\(viewModel.streakStats.currentStreak)",
                subtitle: viewModel.streakStats.currentStreak == 1 ? "day" : "days",
                isHero: true
            )
            
            // Secondary stats in elegant grid
            HStack(spacing: 16) {
                PremiumStatCard(
                    label: "Best Streak",
                    value: "\(viewModel.streakStats.longestStreak)",
                    subtitle: viewModel.streakStats.longestStreak == 1 ? "day" : "days",
                    isHero: false
                )
                
                PremiumStatCard(
                    label: "Total Completed",
                    value: "\(viewModel.streakStats.totalDaysCompleted)",
                    subtitle: viewModel.streakStats.totalDaysCompleted == 1 ? "day" : "days",
                    isHero: false
                )
            }
        }
        .padding(.horizontal, 8)
    }
}

struct PremiumStatCard: View {
    let label: String
    let value: String
    let subtitle: String
    let isHero: Bool
    
    var body: some View {
        VStack(spacing: isHero ? 8 : 6) {
            // Label
            Text(label.uppercased())
                .font(.system(size: isHero ? 14 : 12, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.7))
                .tracking(1.2)
            
            // Value
            Text(value)
                .font(.system(
                    size: isHero ? 48 : 32,
                    weight: .black,
                    design: .default
                ))
                .foregroundColor(.white)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            // Subtitle
            Text(subtitle.uppercased())
                .font(.system(size: isHero ? 16 : 14, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.8))
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isHero ? 24 : 20)
        .padding(.horizontal, isHero ? 32 : 20)
        .background(
            RoundedRectangle(cornerRadius: isHero ? 20 : 16)
                .fill(
                    LinearGradient(
                        colors: isHero ? 
                            [Color.white.opacity(0.15), Color.white.opacity(0.05)] :
                            [Color.white.opacity(0.08), Color.white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: isHero ? 20 : 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Preview
#if DEBUG
struct EnhancedStreakView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EnhancedStreakView()
                .padding()
            
            Spacer()
        }
        .background(Color.black)
    }
}
#endif
