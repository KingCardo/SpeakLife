//
//  Gradients.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/30/23.
//

import SwiftUI

struct Gradients {
    
    var purple: some View {
        LinearGradient(gradient: Gradient(colors: [.purple, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    var cyan: some View { LinearGradient(gradient: Gradient(colors: [.cyan, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

