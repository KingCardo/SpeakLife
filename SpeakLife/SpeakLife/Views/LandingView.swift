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
           
            Image("landingView1")
                .resizable()
                .aspectRatio(contentMode: .fill)
        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .edgesIgnoringSafeArea(.all)
    }
}
