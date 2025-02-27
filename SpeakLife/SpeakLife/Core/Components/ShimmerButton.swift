//
//  ShimmerButton.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/29/23.
//

import SwiftUI

struct ShimmerButton: View {
    let colors: [Color]
    let buttonTitle: String
    let action: () -> Void
    var textColor: Color = .white
    @State private var animationOffset: CGFloat = -UIScreen.main.bounds.width
    @State private var pulsate = false
   

    var body: some View {
        Button(action: action) {
            Text(buttonTitle)
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 18, relativeTo: .title))
                .bold()
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, minHeight: 50) // Ensures the button takes up the entire width and has a minimum height of 50
                .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(30)

        }
    }
}

