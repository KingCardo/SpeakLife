import SwiftUI

struct QuizQuestionView: View {
    @State private var selectedIndex: Int? = nil
    @State private var showFeedback = false
    @State private var questionIndex = 0
    @State private var showExplanation = false
    @State private var showCelebration = false
    @State private var isAnswerCorrect = false
    @State private var quizCompleted = false

    let questions = [
        (
            "What should you do when the devil whispers, 'You're not good enough'?",
            ["Agree and try harder", "Ignore it", "Speak God's truth aloud", "Complain to a friend"],
            2,
            "Speak the truth: ‘I am the righteousness of God in Christ’ (2 Cor. 5:21)."
        ),
        (
            "You feel anxiety rising—what's the best first response?",
            ["Accept it as normal", "Declare 'God has not given me a spirit of fear'", "Distract yourself", "Call someone"],
            1,
            "Use 2 Tim. 1:7. Speaking Scripture out loud silences fear and activates peace."
        ),
        (
            "What do you do when symptoms hit your body suddenly?",
            ["Panic", "Pray silently", "Declare healing Scriptures", "Search online for answers"],
            2,
            "Isaiah 53:5 says by His wounds, we are healed. Speak healing boldly."
        ),
        (
            "The enemy says you’ll never change—what do you say?",
            ["Maybe that’s true", "Say nothing", "Declare 'I am a new creation in Christ'", "Try to prove him wrong"],
            2,
            "2 Cor. 5:17 — remind yourself and the enemy of your reborn identity."
        ),
        (
            "What’s the best response when your finances look hopeless?",
            ["Cry", "Declare God is your provider", "Blame yourself", "Work more hours"],
            1,
            "Declare: 'My God supplies all my needs' (Phil. 4:19). Speak faith, not fear."
        ),
        (
            "In the middle of a trial, what honors God most?",
            ["Complaining", "Silence", "Worship and gratitude", "Waiting to see what happens"],
            2,
            "Psalm 34:1 — 'I will bless the Lord at all times.' Praise shifts the atmosphere."
        ),
        (
            "The enemy whispers, 'You're alone' — what do you speak?",
            ["It's true", "Call a friend", "Declare 'God will never leave me'", "Cry it out"],
            2,
            "Hebrews 13:5 — God promised never to leave or forsake you. Speak it with boldness."
        ),
        (
            "You feel shame from your past — what now?",
            ["Own it", "Bury it", "Speak 'I’m forgiven and free'", "Try harder to be better"],
            2,
            "Romans 8:1 — No condemnation in Christ. Declare freedom!"
        ),
        (
            "How do you renew your mind daily?",
            ["Ignore bad thoughts", "Think positive", "Read and speak Scripture", "Pray only in church"],
            2,
            "Romans 12:2 — Be transformed by renewing your mind with God's Word."
        ),
        (
            "The devil says your future is doomed—how do you answer?",
            ["Believe it", "Speak Jeremiah 29:11", "Worry", "Wait and see"],
            1,
            "Speak: 'God has plans to prosper me, not to harm me.' Faith speaks."
        ),
        (
            "What do you do when you feel unworthy to pray?",
            ["Stay silent", "Try to fix yourself", "Declare your righteousness in Jesus", "Ask someone else to pray"],
            2,
            "Hebrews 4:16 — Come boldly to the throne because of Jesus, not your performance."
        ),
        (
            "When healing is slow, what should your response be?",
            ["Doubt it", "Keep declaring the Word", "Complain", "Give up"],
            1,
            "Faith holds on to the Word. Keep speaking it (Hebrews 10:23)."
        ),
        (
            "If symptoms return after prayer, what do you do?",
            ["Accept them", "Keep standing on God's promise", "Search for new remedies", "Blame yourself"],
            1,
            "Symptoms don’t cancel God’s Word. Keep standing — healing is yours (Isaiah 53:5)."
        ),
        (
            "The enemy says 'You’ll always be stuck' — what’s the truth?",
            ["Maybe he’s right", "Hope it changes", "Declare freedom in Jesus", "Stay quiet"],
            2,
            "John 8:36 — Whom the Son sets free is free indeed. Speak your freedom."
        ),
        (
            "When things don’t change fast, what do you believe?",
            ["It’s not working", "God’s Word is still true", "I must be doing something wrong", "Quit"],
            1,
            "God’s Word never fails (Isaiah 55:11). Speak it, believe it, wait in faith."
        )
    ]


    var body: some View {
        if quizCompleted {
            QuizCompletionView()
        } else if showExplanation {
                if !isAnswerCorrect {
                    QuizExplanationView(explanation: questions[questionIndex].3) {
                    resetFeedback()
                }
            }
        } else {
            VStack(spacing: 20) {
                ProgressView(value: Double(questionIndex + 1), total: Double(questions.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
                    .padding()
                
                Image("appIconDisplay")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                

                Text(questions[questionIndex].0)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                ForEach(0..<4) { index in
                    Button(action: {
                        withAnimation {
                            selectedIndex = index
                            showFeedback = true
                            isAnswerCorrect = index == questions[questionIndex].2
                            if isAnswerCorrect {
                                showCelebration = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    showCelebration = false
                                    nextQuestion()
                                }
                            } else {
                                showExplanation = true
                            }
                        }
                    }) {
                        Text(questions[questionIndex].1[index])
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(buttonColor(for: index))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .disabled(showFeedback)
                }

                if showCelebration {
                    QuizConfettiView()
    
                }

            }
            .padding([.leading, .trailing])
        }
    }

    private func buttonColor(for index: Int) -> Color {
        guard let selected = selectedIndex else { return Color.gray.opacity(0.2) }
        if index == selected {
            return selected == questions[questionIndex].2 ? Color.green : Color.red
        }
        return Color.gray.opacity(0.2)
    }

    private func nextQuestion() {
        if questionIndex + 1 >= questions.count {
            quizCompleted = true
        } else {
            questionIndex = (questionIndex + 1) % questions.count
            resetFeedback()
        }
    }

    private func resetFeedback() {
        selectedIndex = nil
        showFeedback = false
        showExplanation = false
        showCelebration = false
        isAnswerCorrect = false
    }
}
