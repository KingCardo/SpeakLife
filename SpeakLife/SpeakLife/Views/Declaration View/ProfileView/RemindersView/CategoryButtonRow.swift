//
//  CategoryButtonRow.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/19/22.
//

import SwiftUI

struct CategoryButtonRow: View  {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @State var isPresentingCategoryList = false
    @State var isPresentingPremiumView = false
    
    var body: some View {
        HStack {
            Button(action: displayCategoryView) {
                Text("Categories", comment: "category button title")
            }
            .padding()
            
            Spacer()
            
            Button(action: displayCategoryView) {
                Image(systemName: "chevron.right")
            }
            .sheet(isPresented: appState.isPremium ? $isPresentingCategoryList : $isPresentingPremiumView, onDismiss: {
                self.isPresentingPremiumView = false
                self.isPresentingCategoryList = false
            }, content: {
                contentView
            })
            .padding()
        }
        
        .accentColor(Constants.DALightBlue)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Constants.DAMidBlue, lineWidth: 1))

    }
    
    private func displayCategoryView()  {
        if !appState.isPremium {
            isPresentingPremiumView = true
        } else {
            isPresentingCategoryList = true
        }
        
    }
    
    @ViewBuilder
    private var contentView: some View {
        if !appState.isPremium {
            PremiumView()
        } else {
            CategoryListView(categoryList: CategoryListViewModel(declarationStore))
        }
    }
}
