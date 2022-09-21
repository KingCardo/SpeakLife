//
//  DailyDeclaration.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/1/22.
//

import Foundation


enum DeclarationCategory: String, CaseIterable, Identifiable, Codable {
    case faith
    case love
    case favorites
    case myOwn
    case gratitude
    case fear
    case hope
    case health
    case peace
    case wealth
    case motivation
    case positivity
    
    var id: String {
         self.rawValue
    }
    
    var name: String {
        self.rawValue.capitalized
    }
    
    
    var imageString: String {
        self.rawValue.lowercased()
    }
    
    var categoryTitle: String {
        switch self {
        case .myOwn:
            return "My Own"
        default:
            return name
        }
    }
    
    init?(_ name: String) {
        self.init(rawValue: name.lowercased())
    }
    
    var isPremium: Bool {
        switch self {
        case .faith, .love, .favorites: return false
        default: return true
        }
    }
}

// MARK: - Welcome
struct Welcome: Codable {
    let count: Int
    let declarations: [Declaration]
}

// MARK: - Declaration
struct Declaration: Codable, Identifiable, Hashable {
    let text: String
    var category: DeclarationCategory = .faith
    var isFavorite: Bool = false
    var id: String {
        text
    }
}
