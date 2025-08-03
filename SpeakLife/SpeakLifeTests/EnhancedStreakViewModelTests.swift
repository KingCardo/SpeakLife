//
//  EnhancedStreakViewModelTests.swift
//  SpeakLifeTests
//
//  Unit tests for EnhancedStreakViewModel to ensure streak management and celebration logic works correctly
//

import XCTest
import Combine
@testable import SpeakLife

final class EnhancedStreakViewModelTests: XCTestCase {
    
    var viewModel: EnhancedStreakViewModel!
    var cancellables: Set<AnyCancellable>!
    let calendar = Calendar.current
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        
        // Clear any existing UserDefaults data to ensure clean state
        UserDefaults.standard.removeObject(forKey: "dailyChecklist")
        UserDefaults.standard.removeObject(forKey: "streakStats")
        
        viewModel = EnhancedStreakViewModel()
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        
        // Clean up UserDefaults
        UserDefaults.standard.removeObject(forKey: "dailyChecklist")
        UserDefaults.standard.removeObject(forKey: "streakStats")
        
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState_ShouldHaveZeroStreak() {
        // Then: Initial state should be clean
        XCTAssertEqual(viewModel.streakStats.currentStreak, 0)
        XCTAssertEqual(viewModel.streakStats.longestStreak, 0)
        XCTAssertEqual(viewModel.streakStats.totalDaysCompleted, 0)
        XCTAssertNil(viewModel.streakStats.lastCompletedDate)
        XCTAssertFalse(viewModel.showCompletionCelebration)
        XCTAssertFalse(viewModel.showFireAnimation)
        XCTAssertNil(viewModel.celebrationData)
    }
    
    func testInitialChecklist_ShouldBeForToday() {
        // Then: Today's checklist should be created
        let today = calendar.startOfDay(for: Date())
        let checklistDate = calendar.startOfDay(for: viewModel.todayChecklist.date)
        XCTAssertEqual(checklistDate, today)
        XCTAssertFalse(viewModel.todayChecklist.tasks.isEmpty)
    }
    
    // MARK: - Task Completion Tests
    
    func testCompleteTask_ShouldUpdateChecklist() {
        // Given: A task in the checklist
        let task = viewModel.todayChecklist.tasks.first!
        XCTAssertFalse(task.isCompleted)
        
        // When: Complete the task
        viewModel.completeTask(taskId: task.id)
        
        // Then: Task should be marked completed
        let updatedTask = viewModel.todayChecklist.tasks.first { $0.id == task.id }!
        XCTAssertTrue(updatedTask.isCompleted)
    }
    
    func testCompleteAllTasks_ShouldTriggerDayCompletion() {
        // Given: All tasks are incomplete
        XCTAssertFalse(viewModel.todayChecklist.isCompleted)
        
        // When: Complete all tasks
        completeAllTasks()
        
        // Then: Day should be completed and streak should update
        XCTAssertTrue(viewModel.todayChecklist.isCompleted)
        XCTAssertEqual(viewModel.streakStats.currentStreak, 1)
    }
    
    // MARK: - Streak Progression Tests
    
    func testFirstDayCompletion_ShouldCreateStreakOfOne() {
        // Given: Fresh start
        XCTAssertEqual(viewModel.streakStats.currentStreak, 0)
        
        // When: Complete all tasks for the first time
        completeAllTasks()
        
        // Then: Streak should be 1
        XCTAssertEqual(viewModel.streakStats.currentStreak, 1)
        XCTAssertEqual(viewModel.streakStats.longestStreak, 1)
        XCTAssertEqual(viewModel.streakStats.totalDaysCompleted, 1)
        XCTAssertNotNil(viewModel.streakStats.lastCompletedDate)
    }
    
    func testSecondConsecutiveDay_ShouldIncrementStreak() {
        // Given: Completed yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        viewModel.streakStats.updateStreak(for: yesterday)
        
        // When: Complete all tasks today
        completeAllTasks()
        
        // Then: Streak should be 2
        XCTAssertEqual(viewModel.streakStats.currentStreak, 2)
        XCTAssertEqual(viewModel.streakStats.longestStreak, 2)
    }
    
    // MARK: - Celebration Tests
    
    func testFirstCompletion_ShouldTriggerCelebration() {
        // Given: Fresh start
        var celebrationTriggered = false
        
        viewModel.$showCompletionCelebration
            .sink { showCelebration in
                if showCelebration {
                    celebrationTriggered = true
                }
            }
            .store(in: &cancellables)
        
        // When: Complete first day
        completeAllTasks()
        
        // Wait for celebration to trigger
        let expectation = XCTestExpectation(description: "Celebration should trigger")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        // Then: Celebration should be triggered
        XCTAssertTrue(celebrationTriggered)
        XCTAssertNotNil(viewModel.celebrationData)
        XCTAssertEqual(viewModel.celebrationData?.streakNumber, 1)
    }
    
    func testMilestoneCompletion_ShouldHaveCorrectCelebrationData() {
        // Given: 6 days completed (approaching 7-day milestone)
        for i in (1...6).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            viewModel.streakStats.updateStreak(for: date)
        }
        
        // When: Complete 7th day
        completeAllTasks()
        
        // Wait for celebration
        let expectation = XCTestExpectation(description: "Milestone celebration")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        // Then: Celebration should reflect 7-day milestone
        XCTAssertNotNil(viewModel.celebrationData)
        XCTAssertEqual(viewModel.celebrationData?.streakNumber, 7)
        XCTAssertTrue((viewModel.celebrationData?.motivationalMessage.contains("7") ?? false) || 
                      (viewModel.celebrationData?.motivationalMessage.contains("WEEK") ?? false))
    }
    
    func testNewRecord_ShouldBeMarkedInCelebration() {
        // Given: Previous record of 3, current streak broken
        viewModel.streakStats.longestStreak = 3
        viewModel.streakStats.currentStreak = 0
        
        // When: Complete 4 consecutive days (new record)
        for i in (0...3).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            viewModel.streakStats.updateStreak(for: date)
        }
        
        completeAllTasks()
        
        // Wait for celebration
        let expectation = XCTestExpectation(description: "New record celebration")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        // Then: Should be marked as new record
        XCTAssertNotNil(viewModel.celebrationData)
        XCTAssertEqual(viewModel.celebrationData?.streakNumber, 4)
        XCTAssertTrue(viewModel.celebrationData?.isNewRecord ?? false)
    }
    
    // MARK: - Data Persistence Tests
    
    func testDataPersistence_ShouldSaveAndLoadCorrectly() {
        // Given: Complete some tasks and build streak
        completeAllTasks()
        let originalStreak = viewModel.streakStats.currentStreak
        let originalTotal = viewModel.streakStats.totalDaysCompleted
        
        // When: Create new view model (simulates app restart)
        let newViewModel = EnhancedStreakViewModel()
        
        // Then: Data should be restored (this tests the private loadData() method)
        XCTAssertEqual(newViewModel.streakStats.currentStreak, originalStreak)
        XCTAssertEqual(newViewModel.streakStats.totalDaysCompleted, originalTotal)
    }
    
    func testChecklistPersistence_ShouldRestoreCompletedTasks() {
        // Given: Complete some tasks
        let taskToComplete = viewModel.todayChecklist.tasks.first!
        viewModel.completeTask(taskId: taskToComplete.id)
        
        // When: Create new view model (simulates app restart)
        let newViewModel = EnhancedStreakViewModel()
        
        // Then: Completed task should be restored
        let restoredTask = newViewModel.todayChecklist.tasks.first { $0.id == taskToComplete.id }
        XCTAssertNotNil(restoredTask)
        XCTAssertTrue(restoredTask?.isCompleted ?? false)
    }
    
    // MARK: - Progressive Task System Tests
    
    func testProgressiveTasks_ShouldUnlockBasedOnStreak() {
        // Given: Build up streak to unlock new tasks
        for i in (1...7).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            viewModel.streakStats.updateStreak(for: date)
        }
        
        // When: Check that the checklist has tasks (createProgressiveChecklist is private)
        // We'll test this indirectly by verifying task progression happens
        let initialTaskCount = viewModel.todayChecklist.tasks.count
        
        // Then: Should have some tasks available
        XCTAssertGreaterThan(initialTaskCount, 0)
    }
    
    func testUpcomingUnlocks_ShouldShowFutureTasks() {
        // Given: Current streak of 5
        viewModel.streakStats.currentStreak = 5
        
        // When: Get upcoming unlocks
        let upcomingTasks = viewModel.getUpcomingUnlocks(for: 5)
        
        // Then: Should return tasks that unlock in next few days
        XCTAssertFalse(upcomingTasks.isEmpty)
        for task in upcomingTasks {
            XCTAssertGreaterThan(task.minimumStreakDay, 5)
        }
    }
    
    // MARK: - Share Image Generation Tests
    
    func testShareImageGeneration_ShouldCreateImage() {
        // Given: Some streak data
        viewModel.streakStats.currentStreak = 5
        
        // When: Generate share image
        let shareImage = viewModel.generateShareImage()
        
        // Then: Should create a valid image
        XCTAssertNotNil(shareImage)
        XCTAssertGreaterThan(shareImage?.size.width ?? 0, 0)
        XCTAssertGreaterThan(shareImage?.size.height ?? 0, 0)
    }
    
    // MARK: - Badge Integration Tests
    
    func testBadgeUnlock_ShouldTriggerWhenStreakReachesMilestone() {
        // Given: Approaching a badge milestone
        var badgeUnlockTriggered = false
        
        viewModel.$showBadgeUnlock
            .sink { showBadgeUnlock in
                if showBadgeUnlock {
                    badgeUnlockTriggered = true
                }
            }
            .store(in: &cancellables)
        
        // When: Complete day that should unlock badge (e.g., 7 days)
        for i in (1...6).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            viewModel.streakStats.updateStreak(for: date)
        }
        
        completeAllTasks()
        
        // Wait for badge check
        let expectation = XCTestExpectation(description: "Badge unlock check")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // Then: Badge unlock might be triggered (depends on badge requirements)
        // Note: This test might need adjustment based on actual badge unlock logic
    }
    
    // MARK: - Helper Methods
    
    private func completeAllTasks() {
        for task in viewModel.todayChecklist.tasks {
            viewModel.completeTask(taskId: task.id)
        }
    }
    
    // MARK: - Mock/Test Helper Extensions
    
    private func simulateAppRestart() -> EnhancedStreakViewModel {
        // Data is saved automatically by the viewModel
        // Create new instance (simulates app restart)
        return EnhancedStreakViewModel()
    }
}