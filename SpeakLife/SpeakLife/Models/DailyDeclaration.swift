//
//  DailyDeclaration.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/1/22.
//

import Foundation


enum DeclarationCategory: String, CaseIterable, Identifiable, Codable,  Comparable {
    static func < (lhs: DeclarationCategory, rhs: DeclarationCategory) -> Bool {
        return  lhs.name <= rhs.name
    }
    
    case destiny
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
    case addiction
    case depression
    case loneliness
    case motivation
    case confidence
    case hardtimes
    case forgiveness
    case discipline
    case perseverance
    case identity
    case marriage
    case godsprotection
    case guidance
    case rest
    case guilt
    case grace
    case joy
    
    static var categoryOrder: [DeclarationCategory] = [
        .destiny,
        .faith,
        .addiction,
        .identity,
        .love,
        .peace,
        .rest,
        .guidance,
        .gratitude,
        .godsprotection,
        .grace,
        .guilt,
        .wealth,
        .motivation,
        .discipline,
        .health,
        .depression,
        .marriage,
        .fear,
        .hope,
        .confidence,
        .hardtimes,
        .forgiveness,
        .loneliness,
        .selfcontrol,
        .perseverance,
        .joy
    ]
    
    static func getCategoryOrder() -> [DeclarationCategory] {
        var categories = categoryOrder.sorted(by: <)
        categories.insert(.faith, at: 0)
        categories.insert(.grace, at: 0)
        categories.insert(.destiny, at: 0)
        categories.insert(.myOwn, at: 0)
        categories.insert(.favorites, at: 0)
        categories.remove(at: 8)
        categories.remove(at: 9)
        categories.remove(at: 12)
        return categories
           
    }
    
    var id: String {
         self.rawValue
    }
    
    var name: String {
        switch self {
        case .selfcontrol: return "Self Control"
        case .hardtimes: return "Hard Times"
        case .godsprotection: return "God's Protection"
        case .depression: return "Conquer Depression"
        case .fear: return "Fear Not!"
        case .addiction: return "Crush Addiction"
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
        case .destiny, .favorites, .myOwn, .faith, .grace: return false
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
    
    var lastEdit: Date?
}
