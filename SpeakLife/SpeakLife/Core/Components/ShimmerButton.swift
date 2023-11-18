//
//  ShimmerButton.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/29/23.
//

import SwiftUI

struct ShimmerButton: View {
    @State private var animationOffset: CGFloat = -UIScreen.main.bounds.width
    let colors: [Color]
    let buttonTitle: String
    let action: (() -> Void)
    
    var body: some View {
        
        ZStack {
            Button(buttonTitle, action: action)
                .font(.system(size: 25, weight: .bold, design: .default))
                .foregroundColor(.white)
            
            LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]), startPoint: .leading, endPoint: .trailing)
                .frame(width: UIScreen.main.bounds.width * 0.85, height: 50)
                .offset(x: animationOffset - UIScreen.main.bounds.width / 2)
        }
        .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(20)
        .onAppear {
            withAnimation(Animation.linear(duration: 3.0).repeatForever()) {
                animationOffset = UIScreen.main.bounds.width
            }
        }
    }
}

