//
//  CategoryButtonRow.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/19/22.
//

import SwiftUI
import FirebaseAnalytics

struct CategoryButtonRow: View  {
    
    @EnvironmentObject var subscriptionStore: SubscriptionStore
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
            .sheet(isPresented: subscriptionStore.isPremium ? $isPresentingCategoryList : $isPresentingPremiumView, onDismiss: {
                self.isPresentingPremiumView = false
                self.isPresentingCategoryList = false
            }, content: {
                contentView
            })
            .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isPresentingPremiumView = false
            self.isPresentingCategoryList = false
        }
        
        .accentColor(Constants.DALightBlue)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Constants.DAMidBlue, lineWidth: 1))

    }
    
    private func displayCategoryView()  {
        if !subscriptionStore.isPremium {
            isPresentingPremiumView = true
            Analytics.logEvent(Event.tryPremiumTapped, parameters: nil)
        } else {
            isPresentingCategoryList = true
            Analytics.logEvent(Event.reminders_categoriesTapped, parameters: nil)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if !subscriptionStore.isPremium {
            PremiumView()
        } else {
            CategoryListView(categoryList: CategoryListViewModel(declarationStore))
        }
    }
}