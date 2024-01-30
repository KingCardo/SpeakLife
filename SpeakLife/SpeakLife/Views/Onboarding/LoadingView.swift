//
//  LoadingView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 1/23/24.
//

import SwiftUI


struct CustomSpinnerView: View {
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.3)
                .foregroundColor(Constants.DAMidBlue)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .foregroundColor(Constants.DAMidBlue)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut(duration: 2), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.white)
        }
        .frame(width: 200, height: 200)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                withAnimation {
                    self.progress += 0.01
                    if self.progress >= 1.0 {
                        timer.invalidate()
                    }
                }
            }
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
    let delay: Double = Double.random(in: 9...12)

    var body: some View {
        ZStack {
            
            if appState.onBoardingTest {
                Image("highway")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Gradients().purple
                    .edgesIgnoringSafeArea(.all)
            }
            VStack(spacing: 10) {
                VStack(spacing: 10) {
                    CustomSpinnerView()
                    Spacer()
                        .frame(height: 16)
                    
                    Text("Hang tight, while we build your speak life plan")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(Animation.easeInOut(duration: 0.5)) {
                            checkedFirst = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(Animation.easeInOut(duration: 0.5)) {
                            checkedSecond = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
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
