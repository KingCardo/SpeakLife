//
//  Untitled.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/13/25.
//

import Foundation

struct Quiz: Identifiable {
    let id: UUID
    let title: String
    let questions: [QuizQuestion]
}

struct QuizQuestion: Identifiable {
    let id: UUID
    let question: String
    let choices: [String]
    let correctAnswerIndex: Int
    let explanation: String
}
