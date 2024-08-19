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
    case relationships
    case genesis, exodus, leviticus, numbers, deuteronomy
    case joshua, judges, ruth
    case samuel1, samuel2
    case kings1, kings2
    case chronicles1, chronicles2
    case ezra, nehemiah, esther
    case job, psalms, proverbs, ecclesiastes, songOfSolomon
    case isaiah, jeremiah, lamentations, ezekiel, daniel
    case hosea, joel, amos, obadiah, jonah, micah
    case nahum, habakkuk, zephaniah, haggai, zechariah, malachi
    
    // New Testament
    case matthew, mark, luke, john, acts
    case romans
    case corinthians1, corinthians2
    case galatians, ephesians, philippians, colossians
    case thessalonians1, thessalonians2
    case timothy1, timothy2, titus, philemon
    case hebrews, james
    case peter1, peter2
    case john1, john2, john3, jude, revelation
    
    static var allCategories: [DeclarationCategory] = [
        .favorites,
        .myOwn,
        .destiny,
        .grace,
        .faith,
        .psalms,
        .proverbs,
        .matthew,
        .mark,
        .luke,
        .john,
        .romans,
        .corinthians1,
        .corinthians2,
        .galatians,
        .ephesians,
        .addiction,
        .confidence,
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
    
    static var bibleCategories: [DeclarationCategory] = [
        .psalms,
        .proverbs,
        .matthew,
        .mark,
        .luke,
        .john,
        .romans,
        .corinthians1,
        .corinthians2,
        .galatians,
        .ephesians
        ]
    
    
    static var categoryOrder: [DeclarationCategory] = [
        .general,
        .favorites,
        .myOwn,
        .destiny,
        .grace,
        .faith,
        .addiction,
        .confidence,
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
    
//        .genesis, .exodus, .leviticus, .numbers, .deuteronomy,
//           .joshua, .judges, .ruth,
//           .samuel1, .samuel2,
//           .kings1, .kings2,
//           .chronicles1, .chronicles2,
//           .ezra, .nehemiah, .esther,
//           .job, .psalms, .proverbs, .ecclesiastes, .songOfSolomon,
//           .isaiah, .jeremiah, .lamentations, .ezekiel, .daniel,
//           .hosea, .joel, .amos, .obadiah, .jonah, .micah,
//           .nahum, .habakkuk, .zephaniah, .haggai, .zechariah, .malachi,
//           // New Testament
//           .matthew, .mark, .luke, .john, .acts,
//           .romans,
//           .corinthians1, .corinthians2,
//           .galatians, .ephesians, .philippians, .colossians,
//           .thessalonians1, .thessalonians2,
//           .timothy1, .timothy2, .titus, .philemon,
//           .hebrews, .james,
//           .peter1, .peter2,
//           .john1, .john2, .john3, .jude, .revelation
    
    
    var id: String {
         self.rawValue
    }
    
    var name: String {
        switch self {
       // case .selfcontrol: return "Self Control"
        case .hardtimes: return "Hard Times"
        case .godsprotection: return "God's Protection"
        case .fear: return "Fear Not!"
        case .addiction: return "Crush Addiction"
        case .heaven: return "Heavenly Thinking"
        case .purity: return "Purity"
        default:  return self.rawValue.capitalized
        }
    }
    
    
    var imageString: String {
        if DeclarationCategory.bibleCategories.contains(self) {
            return "wisdom"
        }
        switch self {
        default:
            return self.rawValue.lowercased()
        }
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
        case .general, .destiny, .favorites, .myOwn, .ephesians, .love, .galatians, .mark, .luke, .john, .romans : return false
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
    var categories: [DeclarationCategory] = []
    var isFavorite: Bool = false
    var id: String {
      // UUID().uuidString
        text + category.rawValue
    }
    
    enum CodingKeys: String, CodingKey {
            case text
            case book
            case affirmationText
            case category
            case isFavorite
        }
    
    var disliked: Bool = false
    
    var lastEdit: Date?
}
