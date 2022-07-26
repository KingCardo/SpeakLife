//
//  CategoryChooserView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/13/22.
//

import SwiftUI

struct CategoryCell: View  {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    let size: CGSize
    var category: DeclarationCategory
    
    var body: some View {
        categoryCell(size: size)
    }
    
    @ViewBuilder
    private func categoryCell(size: CGSize) -> some  View  {
        
        let dimension =  size.width *  0.4
        
        ZStack {
            colorScheme == .dark ? Constants.DEABlack : Color.white
            
            VStack {
                ZStack {
                    Image(category.imageString)
                        .resizable().scaledToFill()
                    
                        .frame(width: dimension, height: dimension)
                        .clipped()
                        .cornerRadius(4)
                    
                    if category.isPremium && !appState.isPremium {
                        Image(systemName: "lock.fill")
                            .font(.title)
                            .frame(width: 30, height: 30)
                    }
                }
                
                Text(category.categoryTitle)
                    .font(Font.custom("Roboto-Regular", size: 16, relativeTo: .body))
                    .foregroundColor( colorScheme == .dark ? .white : Constants.DEABlack)
                
            }
        }
        .frame(width: dimension + 16, height: size.width * 0.52)
        .cornerRadius(6)
        .shadow(color: Constants.lightShadow, radius: 8, x: 0, y: 4)
    }
}

struct CategoryChooserView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: DeclarationViewModel
    
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geometry in
        NavigationView {
            ScrollView {
                Spacer()
                
                Text("Select one of the following categories to get focused inspiration.", comment: "category reminder selection")
                    .font(Font.custom("Roboto-Regular", size: 16, relativeTo: .body))
                    .foregroundColor(colorScheme == .dark ?  Constants.DEABlack : Constants.DALightBlue)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .lineLimit(2)
                
                LazyVGrid(columns: twoColumnGrid, spacing: 16) {
                    ForEach(viewModel.allCategories) { category in
                        
                        if category.isPremium && !appState.isPremium {
                            ZStack {
                                CategoryCell(size: geometry.size, category: category)
                              
                                NavigationLink("            ", destination: PremiumView())
                                
                            }
                            
                        } else {
                        CategoryCell(size: geometry.size, category: category)
                            .onTapGesture {
                                
                                Selection.shared.selectionFeedback()
                                viewModel.choose(category)
                                self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                    }
                }.padding()
            }
            .navigationBarTitle(Text("Select Category"))
            .background(
                Image("declarationBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
        }.onAppear  {
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Constants.DAMidBlue)]
        }
        }
    }
}
