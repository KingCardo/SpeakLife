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
                AnimatedAppIconView()
                
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.3)
                
            }

           }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
           .background(Color.clear)

    }
}

struct AnimatedAppIconView: View {
    @State private var scaleDown = false
    @State private var zoomIn = false
    @State private var fadeOut = false

    var body: some View {
        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 250, height: 250)
            .clipShape(Circle())
            .scaleEffect(scaleDown ? 0.5 : 1.0) // Shrinks down
            .scaleEffect(zoomIn ? 5.0 : 1.0) // Zooms in
            .opacity(fadeOut ? 0 : 1) // Disappears after zoom
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.5)) {
                    scaleDown = true // First step: shrink
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        zoomIn = true // Second step: zoom in
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(Animation.easeOut(duration: 0.5)) {
                            fadeOut = true // Final step: disappear
                        }
                    }
                }
            }
    }
}

