//
//  TimerViewModelTests.swift
//  SpeakLifeTests
//
//  Created by Riccardo Washington on 3/24/24.
//

import XCTest
@testable import SpeakLife

final class TimerViewModelTests: XCTestCase {

    func testCurrentStreakShouldBeTwo() {
        let sut = TimerViewModel()
        sut.currentStreak = 1
        let currentDate = Date()
        let calendar = Calendar.current
        
        let startOfToday = calendar.startOfDay(for: currentDate)
    
        let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)

        sut.lastCompletedStreak = startOfYesterday
        XCTAssertFalse(sut.checkIfMidnightOfTomorrowHasPassedSinceLastCompletedStreak())
        XCTAssert(sut.currentStreak == 1)
        sut.completeMeditation()
        
        XCTAssert(sut.currentStreak == 2)
    }
}
