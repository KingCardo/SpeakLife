import SwiftUI
import Firebase
import Foundation

class QuizProgressManager: ObservableObject {
    @AppStorage("completedQuizTitlesRaw") private var completedRaw: String = ""

    @Published var completedQuizTitles: [String] = []

    init() {
        load()
    }

    private func load() {
        completedQuizTitles = (try? JSONDecoder().decode([String].self, from: Data(completedRaw.utf8))) ?? []
    }

    private func save() {
        if let data = try? JSONEncoder().encode(completedQuizTitles) {
            completedRaw = String(data: data, encoding: .utf8) ?? ""
        }
    }

    func markQuizComplete(_ title: String) {
        if !completedQuizTitles.contains(title) {
            completedQuizTitles.append(title)
            save()
        }
    }
}
struct QuizHomeView: View {
    @StateObject private var progressManager = QuizProgressManager()
    
    let quizzes = [Quiz(title: "When to Speak Faith", questions: questions), Quiz(title:"How to Get & Stay Healed", questions: healingQuizQuestions), Quiz(title:"How to Stay in Peace", questions: peaceQuizQuestions), Quiz(title:"The Power of Words", questions: wordsQuizQuestions), Quiz(title:"God’s Protection", questions: protectionQuizQuestions), Quiz(title:"Trusting God With Your Destiny", questions: destinyQuizQuestions)]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(quizzes) { quiz in
                        NavigationLink(
                            destination: QuizStartView(
                                quizTitle: quiz.title,
                                questions: quiz.questions,
                                progressManager: progressManager
                            )
                        ) {
                            HStack {
                                QuizCardView(title: quiz.title)
                                if progressManager.completedQuizTitles.contains(quiz.title) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("SpeakLife Lessons")
        }
    }
}


struct QuizCardView: View {
    let title: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(radius: 10)
                .frame(height: 120)
                .overlay(
                    Text(title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                )
        }
        .scaleEffect(1.0)
        .animation(.spring(), value: UUID())
    }
}
