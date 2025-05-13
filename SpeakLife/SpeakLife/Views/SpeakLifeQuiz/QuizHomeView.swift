import SwiftUI

struct QuizHomeView: View {
    let quizzes = ["When to Speak Faith"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(quizzes, id: \.self) { quiz in
                        NavigationLink(destination: QuizStartView(quizTitle: quiz)) {
                            QuizCardView(title: quiz)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.scale)
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
