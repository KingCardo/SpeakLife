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
    case selfcontrol
    case positivity
    case anxiety
    case addiction
    case depression
    case loneliness
    
    static var categoryOrder: [DeclarationCategory] = [
        .favorites,
        .myOwn,
        .anxiety,
        .peace,
        .faith,
        .love,
        .addiction,
        .depression,
        .fear,
        .gratitude,
        .health,
        .hope,
        .loneliness,
        .positivity,
        .selfcontrol,
        .wealth
            ]
    
    var id: String {
         self.rawValue
    }
    
    var name: String {
        switch self {
        case .selfcontrol: return "Self Control"
        default:  return self.rawValue.capitalized
        }
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
        case .faith, .love, .favorites, .anxiety, .peace: return false
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
    var book: String? = nil
    var category: DeclarationCategory = .faith
    var isFavorite: Bool = false
    var id: String {
        text + category.rawValue
    }
}
