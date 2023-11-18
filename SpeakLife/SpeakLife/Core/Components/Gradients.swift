//
//  Gradients.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/30/23.
//

import SwiftUI

struct Gradients {
    
    let colors: [Color] = [.cyan, .purple, .white, .red]
    
    func randomColors() -> [Color] {
            let shuffledColors = colors.shuffled()
            let array = Array(shuffledColors.prefix(2))
            return array
        }
    
    var purple: some View {
        LinearGradient(gradient: Gradient(colors: [.purple, .cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
    
    var cyanGold: some View { LinearGradient(gradient: Gradient(colors: [.cyan, Constants.gold]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    
    
    var random: some View { LinearGradient(gradient: Gradient(colors: randomColors()), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

