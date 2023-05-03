//
//  ThemeChooserView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/7/22.
//

import SwiftUI

struct ThemeChooserView: View {
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var themesViewModel: ThemeViewModel
    @State private var isPresentingFontChooser = false
    @Environment(\.colorScheme) var colorScheme
    @State var hideFontPicker = true
    @State private var showingImagePicker = false
    @State private var isPresentingPremiumView = false
    
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geometry in
            themeChooserBodyNew(size: geometry.size)
        }
    }
    
    var selectImageView: some View {
        HStack {
            Button("Select Custom Image") {
                if !subscriptionStore.isPremium {
                        premiumView()
                        Selection.shared.selectionFeedback()
                } else {
                    showingImagePicker = true
                }
            }.foregroundColor(Constants.DAMidBlue)
        }
        .padding()
    }
    private func premiumView()  {
        self.isPresentingPremiumView = true
    }
    
    @ViewBuilder
    private var textHeader: some View {
        Spacer()
        
        Text("Pick from a selection of fonts and backgrounds to personalize your theme.")
            .font(Font.custom("Roboto-Regular", size: 16, relativeTo: .body))
            .foregroundColor(Constants.DALightBlue)
            .multilineTextAlignment(.center)
            .lineLimit(2)
        
        Spacer()
        
        Text("Select Font")
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(Constants.DALightBlue)
    }
    
    private func themeChooserBodyNew(size: CGSize) -> some View {
        NavigationView {
            ScrollView {
                
                textHeader
                
                fontChooser(size: size)
                
                selectImageView
                
                Text("Select Background Image")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.DALightBlue)
                
                LazyVGrid(columns: twoColumnGrid, spacing: 16) {
                    ForEach(themesViewModel.themes) { theme in
                        if theme.isPremium && !subscriptionStore.isPremium {
                            ZStack {
                                themeCell(imageString: theme.backgroundImageString, size: size, isPremium: theme.isPremium)
                                
                                NavigationLink("", destination: PremiumView())
                            }
                        } else {
                            themeCell(imageString: theme.backgroundImageString, size: size, isPremium: theme.isPremium)
                                .onTapGesture {
                                    themesViewModel.choose(theme)
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                        }
                    }
                }.padding()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $themesViewModel.selectedImage)
            }
            .sheet(isPresented: $isPresentingPremiumView) {
                self.isPresentingPremiumView = false
            } content: {
                PremiumView()
            }
            .navigationBarTitle(Text("Theme"))
            .background(colorScheme == .light ?
                        Image("declarationBackground")
                .resizable()
                .aspectRatio(contentMode: .fill) : nil
            )
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.isPresentingPremiumView = false
                self.showingImagePicker = false
            }
            .onAppear {
                DispatchQueue.global(qos: .userInitiated).async {
                    themesViewModel.load()
                }
                UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Constants.DAMidBlue)]
            }
            .onDisappear {
                DispatchQueue.global(qos: .userInitiated).async {
                    themesViewModel.save()
                }
            }
        }
    }
    
    @ViewBuilder
    private func themeCell(imageString: String, size: CGSize, isPremium: Bool) -> some View {
        let dimension = size.width
        
        ZStack {
            colorScheme == .dark ? Constants.DEABlack : Color.white
            
            VStack {
                Image(imageString)
                    .resizable()
                    .scaledToFill()
                    .frame(width: dimension * 0.4, height: dimension * 0.45)
                    .clipped()
                    .cornerRadius(4)
            }
            if isPremium && !subscriptionStore.isPremium {
                Image(systemName: "lock.fill")
                    .font(.title)
                    .frame(width: 30, height: 30)
            }
        }
        .frame(width: dimension * 0.45, height: dimension * 0.5)
        .cornerRadius(6)
        .shadow(color: Constants.lightShadow, radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func fontChooser(size: CGSize) -> some View {
        if hideFontPicker {
            Text(themesViewModel.fontString)
                .foregroundColor(colorScheme  ==  .dark ? .white : .black)
                .onTapGesture {
                    withAnimation {
                        self.hideFontPicker = false
                    }
                }
                .padding()
        } else {
            FontChooserView(themeViewModel: themesViewModel) { hideFontPicker in
                self.hideFontPicker = hideFontPicker
            }
            .frame(height: size.height * 0.25)
        }
    }
}
