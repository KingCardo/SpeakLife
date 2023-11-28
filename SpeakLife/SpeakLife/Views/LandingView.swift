//
//  LandingView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/27/23.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        ZStack(alignment: .center) {
            Gradients().purple
            Image("desertSky")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .overlay(Circle().stroke(Constants.DALightBlue, lineWidth: 1))
            VStack {
                
                Spacer()
                    .frame(height: 100)
                Text("SpeakLife")
                    .font(Constants.titleFont)
                Spacer()
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .edgesIgnoringSafeArea(.all)
    }
}
