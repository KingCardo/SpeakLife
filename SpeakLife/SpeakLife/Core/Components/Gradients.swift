//
//  Gradients.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/30/23.
//

import SwiftUI

struct Gradients {
    
    let colors: [Color] = [.cyan, .purple,.pink, .indigo, .teal, Constants.DAMidBlue]
    
    func randomColors() -> [Color] {
            let shuffledColors = colors.shuffled()
            let array = Array(shuffledColors.prefix(3))
            return array
        }
    
    func randomColor() -> Color {
        let shuffledColors = colors.shuffled()
        return shuffledColors.first!
    }
    
    var purple: some View {
        LinearGradient(gradient: Gradient(colors: [.purple, .cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    var midBlue: some View {
        LinearGradient(gradient: Gradient(colors: [Constants.DAMidBlue, .black]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
    var cyanBlue: some View {
        LinearGradient(gradient: Gradient(colors: [.cyan, .black]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
    var cyanWhite: some View {
        LinearGradient(gradient: Gradient(colors: [.cyan, .white]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
    
    var trio: some View {
        LinearGradient(gradient: Gradient(colors: [.purple, .cyan, .red]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    var redPurple: some View {
        LinearGradient(gradient: Gradient(colors: [.purple, .red]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    var redCyan: some View {
        LinearGradient(gradient: Gradient(colors: [ .cyan, .red]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    var cyan: some View { LinearGradient(gradient: Gradient(colors: [.cyan, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    var cyanPurple: some View { LinearGradient(gradient: Gradient(colors: [.cyan, .purple, .cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    var cyanGold: some View { LinearGradient(gradient: Gradient(colors: [.cyan, Constants.gold]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    var goldCyan: some View { LinearGradient(gradient: Gradient(colors: [Constants.gold, .cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    var randomGradient: some View { LinearGradient(gradient: Gradient(colors: [randomColor(), .black]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
    
    
    
    var random: some View { LinearGradient(gradient: Gradient(colors: randomColors()), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

