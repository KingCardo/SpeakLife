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
    @Environment(\.colorScheme) var colorScheme
    @State private var showingImagePicker = false
    @State private var isPresentingPremiumView = false
    @State private var selectedFont: UIFont?
    @State private var showFontPicker = false
    
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geometry in
            themeChooserBodyNew(size: geometry.size)
        }
    }
    
    var selectCustomImageView: some View {
        HStack {
            Button {
                if !subscriptionStore.isPremium {
                    presentPremiumView()
                    Selection.shared.selectionFeedback()
                } else {
                    showingImagePicker = true
                }
            } label: {
                HStack {
                    Text("Select Custom Image")
                        .fontWeight(.semibold)
                    Image(systemName: "photo.fill")
                }
                .foregroundStyle(Color.blue)
            }
        }
        .padding()
    }
    
    private func presentPremiumView()  {
        self.isPresentingPremiumView = true
    }
    
    @ViewBuilder
    private var textHeader: some View {
        Spacer()
        
        Text("Pick from a selection of fonts and backgrounds to personalize your theme.")
            .font(Font.custom("Roboto-Regular", size: 16, relativeTo: .body))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(2)
        
        Spacer()
        
        Text("Select Font")
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(.white)
    }
    
    private func themeChooserBodyNew(size: CGSize) -> some View {
        NavigationView {
            ScrollView {
                
                HStack {
                    Text("Theme")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                
                textHeader
                
                fontChooser(size: size)
                    
                
                selectCustomImageView
                
                Text("Choose Background Image 👇")
                    .font(.body)
                    .foregroundColor(.white)
                
                LazyVGrid(columns: twoColumnGrid, spacing: 16) {
                    ForEach(themesViewModel.themes) { theme in
                            themeCell(imageString: theme.backgroundImageString, size: size, isPremium: theme.isPremium)
                                .onTapGesture {
                                    if theme.isPremium && !subscriptionStore.isPremium {
                                        isPresentingPremiumView = true
                                    } else {
                                        themesViewModel.choose(theme)
                                        self.presentationMode.wrappedValue.dismiss()
        
                                    }
                                }
                    }
                }.padding()
            }
            .sheet(isPresented: $showFontPicker) {
                FontPickerView(themesViewModel: themesViewModel, selectedFont: $selectedFont, isPresented: $showFontPicker)

            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $themesViewModel.selectedImage)
            }
            .sheet(isPresented: $isPresentingPremiumView) {
                self.isPresentingPremiumView = false
            } content: {
                PremiumView()
            }
            .background(Image(subscriptionStore.onboardingBGImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                )
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
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        ZStack {
                            VisualEffectBlur(blurStyle: .systemMaterial)
                                .frame(width: 18, height: 18)
                            
                                .padding(10)
                                .blur(radius: 8)
                            Image(systemName: "lock.fill")
                                .font(.body)
                                .frame(width: 16, height: 16)
                        }
                        Spacer()
                    }
                }.padding([.top, .trailing], 8)
            }
        }
        .frame(width: dimension * 0.45, height: dimension * 0.5)
        .cornerRadius(6)
        .shadow(color: Constants.lightShadow, radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func fontChooser(size: CGSize) -> some View {
        if !showFontPicker {
            Text(themesViewModel.fontString)
                .foregroundStyle(Color.blue)
                .onTapGesture {
                    withAnimation {
                        self.showFontPicker = true
                    }
                }
                .padding()

        }
    }
}

