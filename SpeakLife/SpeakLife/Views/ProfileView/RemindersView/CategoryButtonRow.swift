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
    @EnvironmentObject var config: AppConfigViewModel
    @State var presentDevotionalSubscriptionView = false
    @State var isPresentingCategoryList = false
    @State var isPresentingPremiumView = false {
        didSet {
            print("\(isPresentingPremiumView) is being changed")
        }
    }
    
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
                    .sheet(isPresented: $presentDevotionalSubscriptionView) {
                        DevotionalSubscriptionView() {
                            presentDevotionalSubscriptionView = false
                        }
                       }
                       
            })
            .padding()
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
            SubscriptionView(size:  UIScreen.main.bounds.size)
                .onDisappear {
                    if !subscriptionStore.isPremium, !subscriptionStore.isInDevotionalPremium {
                        if config.showDevotionalSubscription {
                            presentDevotionalSubscriptionView = true
                        }
                    }
                }
                
        } else {
            CategoryListView(categoryList: CategoryListViewModel(declarationStore))
        }
    }
}
