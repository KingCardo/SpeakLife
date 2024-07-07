//
//  CategoryListCell.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 3/2/22.
//

import SwiftUI
import UIKit

func assetExists(named assetName: String) -> Bool {
    return UIImage(named: assetName) != nil
}
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
                .font(Font.custom("Roboto-SemiBold", size: 20, relativeTo: .title))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Spacer()
            
            if categoryList.selectedCategories.contains(category) {
                Image(systemName: "checkmark")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
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
