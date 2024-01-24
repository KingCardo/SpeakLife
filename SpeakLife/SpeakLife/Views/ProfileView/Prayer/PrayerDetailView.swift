//
//  PrayerDetailView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/10/23.
//

import SwiftUI

struct PrayerDetailView<InjectedView: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    let prayer: String
    var gradient: InjectedView
    let createYourOwn: Declaration?
    var isCreatedOwn = false

    init(prayer: String, @ViewBuilder content: () -> InjectedView) {
        self.prayer = prayer
        self.gradient = content()
        self.createYourOwn = nil
    }
    
    init(declaration: Declaration, isCreatedOwn: Bool = false, @ViewBuilder content: () -> InjectedView) {
        self.createYourOwn = declaration
        self.isCreatedOwn = isCreatedOwn
        self.gradient = content()
        self.prayer = ""
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            if isCreatedOwn {
                isCreatedOwnView
            } else {
                prayerView
            }
                
               
        }
        .background(gradient)
    }
    
    var isCreatedOwnView: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Text(createYourOwn?.lastEdit?.toPrettyString() ?? "")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .caption))
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                        .foregroundColor(.black)
                }
                
                Spacer().frame(height: 20)
                
                Text(createYourOwn?.text ?? "")
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 22, relativeTo: .body))
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width)
                
                Spacer()
            }
        }
    }
    
    var prayerView: some View {
        ScrollView {
            
            Text(prayer)
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                .lineSpacing(4)
                .padding(.horizontal, 32)
                .foregroundColor(.black)
                .frame(width: UIScreen.main.bounds.width)
            
            Spacer()
        }
    }
}

