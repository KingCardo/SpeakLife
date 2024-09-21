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
               Image(onboardingBGImage)
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .frame(maxWidth: .infinity, maxHeight: .infinity)
                   .edgesIgnoringSafeArea(.all)

            VStack {
                // App Icon centered and shaped
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
                    .offset(x: 0, y: 0)
                
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.3)
                
            }

           }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
           .background(Color.clear)

    }
}

