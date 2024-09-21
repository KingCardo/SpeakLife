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
               // Background image with fill
               Image(onboardingBGImage)
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .frame(maxWidth: .infinity, maxHeight: .infinity)
                   .edgesIgnoringSafeArea(.all)// Ensure it fills the screen

               // App Icon centered and shaped
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                   .resizable() // Ensure it scales properly
                   .aspectRatio(contentMode: .fit) // Make sure it keeps its aspect ratio
                   .frame(width: 300, height: 300) // Adjust the size to your needs
                   .clipShape(Circle())
                   .offset(x: 0, y: 0)

           }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
           .background(Color.clear)

    }
}

