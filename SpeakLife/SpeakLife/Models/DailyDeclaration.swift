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
   // case selfcontrol
    case wisdom
    case grace
    case loneliness
  //  case motivation
    case addiction
    case depression
    case confidence
    case forgiveness
    case godsprotection
    case guidance
    case rest
   // case guilt
    case joy
   
    case hardtimes
   // case discipline
    case perseverance
    case identity
    case marriage
    case general
    case praise
    case heaven
    case purity
    case creativity
    case relationships
    
    
    static var categoryOrder: [DeclarationCategory] = [
        .general,
        .favorites,
        .myOwn,
        .destiny,
        .grace,
        .faith,
        .addiction,
        .creativity,
        .confidence,
        .depression,
        .fear,
        .forgiveness,
        .godsprotection,
        .gratitude,
        .guidance,
        .hardtimes,
        .health,
        .heaven,
        .hope,
        .identity,
        .joy,
        .loneliness,
        .love,
        .purity,
        .praise,
        .rest,
        .relationships,
        .marriage,
        .peace,
        .perseverance,
        .wisdom,
        .wealth,
    ]
    
    
    var id: String {
         self.rawValue
    }
    
    var name: String {
        switch self {
       // case .selfcontrol: return "Self Control"
        case .hardtimes: return "Hard Times"
        case .godsprotection: return "God's Protection"
        case .depression: return "Conquer Depression"
        case .fear: return "Fear Not!"
        case .addiction: return "Crush Addiction"
        case .heaven: return "Heavenly Thinking"
        case .purity: return "Purity"
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
        case .general, .destiny, .favorites, .myOwn, .grace, .love, .health, .purity : return false
        default: return true
        }
    }
}

// MARK: - Welcome
struct Welcome: Codable {
    let count: Int
    let version: Int?
    let declarations: [Declaration]
}

// MARK: - Declaration
struct Declaration: Codable, Identifiable, Hashable {
    let text: String
    var book: String? = nil
    var affirmationText: String? = nil
    var category: DeclarationCategory = .faith
    var isFavorite: Bool = false
    var id: String {
      // UUID().uuidString
        text + category.rawValue
    }
    
    var lastEdit: Date?
}
