//
//  DeclarationViewModel.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/1/22.
//

import SwiftUI
import Combine


final class DeclarationViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @AppStorage("selectedCategory") var selectedCategoryString = "faith"
    
    @Published var declarations: [Declaration] = []
    
    private (set) var currentDeclaration: Declaration?
    
    @Published var allCategories: [DeclarationCategory] = DeclarationCategory.getCategoryOrder()
    
    private var allDeclarationsDict: [DeclarationCategory: [Declaration]] = [:]
    
    var selectedCategory: DeclarationCategory {
        DeclarationCategory(rawValue: selectedCategoryString) ?? .love
    }
    
    @Published var favorites: [Declaration] = [] {
        didSet  {
            if selectedCategory == .favorites {
                declarations = favorites.shuffled()
            }
        }
    }
    
    @Published var createOwn: [Declaration] = [] {
        didSet {
            if selectedCategory == .myOwn {
                declarations = createOwn.shuffled()
            }
        }
    }
    
    @Published var isFetching = false
    
    @Published var isPurchasing = false
    
    var errorMessage: String? {
        didSet {
            if errorMessage != nil  {
                showErrorMessage = true
            }
        }
    }
    
    @Published var showErrorMessage = false
    
    @Published var showNewAlertMessage = false
    
    private var allDeclarations: [Declaration] = []
    
    var selectedCategories = Set<DeclarationCategory>()
    
    private let service: APIService
    
    private let notificationManager: NotificationManager
    
    // MARK: - Init(s)
    
    init(apiService: APIService,
         notificationManager: NotificationManager = .shared) {
        self.service = apiService
        self.notificationManager = notificationManager
        
        fetchDeclarations()
        fetchSelectedCategories()
        
        NotificationHandler.shared.callback = { [weak self] content in
            self?.setDeclaration(content.body, category: content.title)
        }
    }
    
    private func fetchDeclarations() {
        isFetching = true
        
        service.declarations() {  [weak self] declarations, error, neededSync in
            guard let self  = self else { return }
            self.isFetching = false
            self.allDeclarations = declarations
            self.populateDeclarationsByCategory()
            self.choose(self.selectedCategory) { _ in }
            self.favorites = self.getFavorites()
            self.createOwn = self.getCreateOwn()
            self.errorMessage = error?.localizedDescription
            
            if neededSync {
                self.showNewAlertMessage = true
            }
        }
    }
    
    private func populateDeclarationsByCategory() {
        for declaration in allDeclarations {
            let category = declaration.category
            if allDeclarationsDict[category] == nil {
                allDeclarationsDict[category] = []
            }
            allDeclarationsDict[category]?.append(declaration)
        }
    }
    
    // MARK: - Intent(s)
    
    func setCurrent(_ declaration: Declaration) {
        currentDeclaration = declaration
    }
    
    // MARK: - Favorites
    
    func favorite(declaration: Declaration) {
        guard let indexOf = declarations.firstIndex(where: { $0.id == declaration.id } ) else {
            return
        }
        
        
        declarations[indexOf]
            .isFavorite
            .toggle()
        
        guard let index = allDeclarations.firstIndex(where: { $0.id == declaration.id }) else { return }
        allDeclarations[index] = declarations[indexOf]
        
        
        service.save(declarations: allDeclarations) { [weak self] success in
            self?.refreshFavorites()
        }
    }
    
    func refreshFavorites() {
        favorites = getFavorites()
    }
    
    private func getFavorites() -> [Declaration] {
        allDeclarations.filter { $0.isFavorite == true }
    }
    
    
    func removeFavorite(at indexSet: IndexSet) {
        _ = indexSet.map { int in
            let declaration = favorites[int]
            favorite(declaration: declaration)
        }
    }
    
    // MARK: - Create own
    
    func createDeclaration(_ text: String)  {
        guard text.count > 2 else {  return }
        let declaration = Declaration(text: text, category: .myOwn, isFavorite: false, lastEdit: Date())
        guard !allDeclarations.contains(declaration) else {
            return
        }
        allDeclarations.append(declaration)
        
        service.save(declarations: allDeclarations) { [weak self] success in
            guard success else { return }
            self?.refreshCreateOwn()
        }
    }
    
    func editMyOwn(_ declaration: String) {
        let declaration = Declaration(text: declaration, category: .myOwn, isFavorite: false, lastEdit: Date())
        removeOwn(declaration: declaration)
    }
    
    func removeOwn(declaration: Declaration) {
        guard let indexOf = createOwn.firstIndex(where: { $0.id == declaration.id } ) else {
            return
        }
        
        allDeclarations.removeAll(where: { $0.id == declaration.id })
        createOwn.remove(at: indexOf)
        service.save(declarations: allDeclarations) { [weak self] success in
            self?.refreshCreateOwn()
        }
    }
    
    
    func refreshCreateOwn() {
        createOwn = getCreateOwn()
    }
    
    private func getCreateOwn() -> [Declaration] {
        allDeclarations.filter { $0.category == .myOwn }
    }
    
    
    func removeOwn(at indexSet: IndexSet) {
        _ = indexSet.map { int in
            let declaration = createOwn[int]
            removeOwn(declaration: declaration)
        }
    }
    
    // MARK: - Declarations
    
    func choose(_ category: DeclarationCategory, completion: @escaping(Bool) -> Void) {
        fetchDeclarations(for: category) { [weak self] declarations in
            guard declarations.count > 0 else {
                self?.errorMessage = "Oops, you need to add one to this category first!"
                completion(false)
                return
            }
            self?.selectedCategoryString = category.rawValue
            let shuffled = declarations.shuffled()
            self?.declarations = shuffled
            completion(true)
        }
    }
    
    func choose(_  declaration: Declaration) {
        if !declarations.contains(where: { $0 == declaration }) {
            declarations.append(declaration)
            guard declarations.count > 1 else { return }
            declarations.swapAt(declarations.indices.first!, declarations.indices.last!)
        }  else {
            let favIndex = declarations.firstIndex(where: { $0.id == declaration.id})
            declarations.swapAt(declarations.indices.first!, favIndex!)
        }
    }
    
    func fetchDeclarations(for category: DeclarationCategory, completion: @escaping(([Declaration]) -> Void)) {
        if let declarations = allDeclarationsDict[category] {
            completion(declarations)
        }  else if category == .favorites {
            refreshFavorites()
            completion(favorites)
        } else if category == .myOwn {
            refreshCreateOwn()
            completion(createOwn)
        } else {
            let declarations = allDeclarations.filter { $0.category == category }
            allDeclarationsDict[category] = declarations
            completion(declarations)
        }
    }
    
    func fetchSelectedCategories()  {
        service.declarationCategories { selectedCategories, error in
            if let error = error {
                print(error)
            }
            self.selectedCategories = selectedCategories
        }
    }
    
    func save(_ selectedCategories: Set<DeclarationCategory>) {
        self.selectedCategories = selectedCategories
        service.save(selectedCategories: selectedCategories) { success in
            if success {
                
            }
        }
    }
    
    func setDeclaration(_ content: String,  category: String)  {
        var contentData = content
        contentData += " ~ " + category
        let contentText = prefixString(content, until: "~").dropLast()
        print(contentText, "RWRW")
        
        if let category = DeclarationCategory(category),
           let categoryArray = allDeclarationsDict[category] {
            guard let declaration = categoryArray.filter ({ $0.text == contentData }).first else {
                print("failed to create dec rwrw")
                return
            }
            self.choose(declaration)
            print("choose dec")
        } else {
            guard let declaration = allDeclarations.filter ({ $0.text == contentText }).first else {
                print("failed to create dec rwrw find")
                return
            }
            self.choose(declaration)
            
        }
    }
}

func prefixString(_ text: String, until character: Character) -> String {
    if let index = text.firstIndex(of: character) {
        let prefix = text[..<index]
        return String(prefix)
    } else {
        return text
    }
}
