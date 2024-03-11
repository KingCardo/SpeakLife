//
//  CategoryListView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/19/22.
//

import SwiftUI


final class CategoryListViewModel: ObservableObject {
    
    init(_ declarationStore: DeclarationViewModel) {
        self.declarationStore = declarationStore
        self.categories = declarationStore.allCategories
        self.selectedCategories = declarationStore.selectedCategories
    }
    
    private let declarationStore: DeclarationViewModel
    
    @Published var selectedCategories: Set<DeclarationCategory>
    
    let categories: [DeclarationCategory]
    
    func addCategory(_ category: DeclarationCategory) {
        selectedCategories.update(with: category)
    }
    
    func remove(category:  DeclarationCategory) {
        selectedCategories.remove(category)
    }
    
    func saveCategories(_ appState: AppState) {
        let categoryString = selectedCategories.map { $0.name }.joined(separator: ",")
        appState.selectedNotificationCategories = categoryString
        declarationStore.save(selectedCategories)
    }
}

struct CategoryListView: View  {
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var categoryList: CategoryListViewModel
    
    var body: some View  {
        NavigationView {
            VStack {
                Spacer()
                    .frame(height: 8)
                Text("Selection's will personalize your general feed")
                    .foregroundColor(.primary)
                List(categoryList.categories, id: \.id) { category in
                    CategoryListCell(category: category, categoryList: categoryList)
                }
            }
           
            .navigationTitle(Text("Choose Categories", comment: "choose categories"))
            .toolbar { EditButton() }
        }.onDisappear {
            categoryList.saveCategories(appState)
        }
    }
}

