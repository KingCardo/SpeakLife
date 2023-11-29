//
//  CategoryListCell.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 3/2/22.
//

import SwiftUI

struct CategoryListCell: View  {
    @Environment(\.colorScheme) var colorScheme
    
    let category: DeclarationCategory
    @ObservedObject var categoryList: CategoryListViewModel
    
    
    var body: some  View  {
        ZStack  {
        HStack {
            Image(category.imageString)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .padding([.trailing])
            
            Text(category.categoryTitle)
                .font(.title2)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Spacer()
            
            if categoryList.selectedCategories.contains(category) {
                Image(systemName: "checkmark")
            }
        }
            Button(action: categoryCheck) {
                
            }
        }
    }
    
    private func categoryCheck()  {
        if !categoryList.selectedCategories.contains(category) {
            categoryList.addCategory(category)
        } else {
            categoryList.remove(category: category)
        }
    }
}
