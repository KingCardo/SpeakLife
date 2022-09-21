//
//  ThemeChooserView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/7/22.
//

import SwiftUI


struct ThemeChooserView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var themesViewModel: ThemeViewModel
    @State private var isPresentingFontChooser = false
    @Environment(\.colorScheme) var colorScheme
    @State var hideFontPicker = true
    
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geometry  in
            themeChooserBodyNew(size: geometry.size)
        
        }
    }
    
    private func themeChooserBodyNew(size: CGSize) -> some  View  {
        
        NavigationView {
            ScrollView {
                Spacer()
                Text("Pick from a selection of fonts and backgrounds to personalize your theme.", comment: "theme chooser  selection of fonts")
                    .font(Font.custom("Roboto-Regular", size: 16, relativeTo: .body))
                    .foregroundColor(colorScheme == .dark ? Constants.DAMidBlue : Constants.DALightBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Spacer()
                
                Text("Select Font", comment: "theme chooser select font")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.DALightBlue)
                
                fontChooser(size: size)
                
                Text("Select Background Image", comment: "theme chooser select image")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.DALightBlue)
                
                LazyVGrid(columns: twoColumnGrid, spacing: 16) {
                    ForEach(themesViewModel.themes) { theme in
                        
                        if theme.isPremium && !appState.isPremium {
                            ZStack {
                                themeCell(imageString: theme.backgroundImageString, size: size, isPremium: theme.isPremium)
                                
                                NavigationLink("            ", destination: PremiumView())
                                
                            }
                        } else  {
                        themeCell(imageString: theme.backgroundImageString, size: size, isPremium: theme.isPremium)
                        
                            .onTapGesture {
                                themesViewModel.choose(theme)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                            }
                    }
                }.padding()
            }
            .navigationBarTitle(Text("Theme", comment: "theme title"))
            .background(colorScheme == .light  ?
                Image("declarationBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill) : nil
            )
            .onAppear  {
                themesViewModel.load()
                UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Constants.DAMidBlue)]
            }
            .onDisappear {
                themesViewModel.save()
            }
        }
    }
    
    @ViewBuilder
    private func themeCell(imageString: String, size: CGSize, isPremium: Bool) -> some  View  {
        
        let dimension =  size.width
    
        ZStack {
            colorScheme == .dark ? Constants.DEABlack : Color.white
           
            VStack {
                Image(imageString)
                                .resizable().scaledToFill()
                                
                                .frame(width: dimension * 0.4, height: dimension * 0.45)
                                .clipped()
                                .cornerRadius(4)
                    
            }
            if isPremium && !appState.isPremium {
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
    private func fontChooser(size: CGSize) -> some View  {
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
            FontChooserView(themeViewModel: themesViewModel)  { hideFontPicker in
                self.hideFontPicker = hideFontPicker
            }
            .frame(height: size.height * 0.25)
        }
    }

    private func chooseFont() {
        self.isPresentingFontChooser = true
    }
}
