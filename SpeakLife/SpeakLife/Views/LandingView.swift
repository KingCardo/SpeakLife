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
                
                //.clipShape(Rectangle())
//                .overlay(Circle().stroke(Constants.DALightBlue, lineWidth: 1))
//            VStack {
//                
//                Spacer()
//                    .frame(height: 100)
//                Text("SpeakLife")
//                    .foregroundStyle(Color.white)
//                    .font(Constants.titleFont)
//                Spacer()
//            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .edgesIgnoringSafeArea(.all)
    }
}
