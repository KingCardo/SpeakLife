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
    case joy
    
    case hardtimes
    case parenting
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
//    case timothy1, timothy2, titus, philemon
    case hebrews, james
    case peter1, peter2
    case john1, john2, john3, jude, revelation
    
    static var allCategories: [DeclarationCategory] = [
        .favorites,
        .myOwn,
        .destiny,
        .grace,
        .faith,
        .genesis,
        .exodus,
        .leviticus,
        .numbers,
        .deuteronomy,
        .joshua,
        .judges,
        .ruth,
        .samuel1,
        .samuel2,
        .kings1,
        .kings2,
        .chronicles1,
        .chronicles2,
        .ezra,
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
        .philippians,
        .colossians,
        .hebrews,
        .james,
        .peter1,
        .peter2,
        .thessalonians1,
        .thessalonians2,
        .revelation,
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
        .parenting,
        .praise,
        .purity,
        .rest,
        .relationships,
        .marriage,
        .peace,
        .perseverance,
        .wisdom,
        .wealth,
        ]
    
    static var bibleCategories: [DeclarationCategory] = [
        .genesis,
        .exodus,
        .leviticus,
        .numbers,
        .deuteronomy,
        .joshua,
        .judges,
        .ruth,
        .samuel1,
        .samuel2,
        .kings1,
        .kings2,
        .chronicles1,
        .chronicles2,
        .ezra,
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
        .philippians,
        .colossians,
        .hebrews,
        .james,
        .peter1,
        .peter2,
        .thessalonians1,
        .thessalonians2,
        .revelation
        ]
    
    static var generalCategories: [DeclarationCategory] = [
        .general,
        .favorites,
        .myOwn,
        ]
    
    
    static var categoryOrder: [DeclarationCategory] = [
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
        .marriage,
        .parenting,
        .peace,
        .perseverance,
        .praise,
        .purity,
        .relationships,
        .rest,
        .wealth,
        .wisdom
    ]
    
    var isBibleBook: Bool {
        return DeclarationCategory.bibleCategories.contains(where: { $0 == self } )
    }
    var id: String {
         self.rawValue
    }
    
    var name: String {
        switch self {
       // case .selfcontrol: return "Self Control"
        case .hardtimes: return "Hard Times"
        case .godsprotection: return "God's Protection"
        case .fear: return "Fear Not!"
        case .addiction: return "Overcome Addiction"
        case .heaven: return "Heavenly Thinking"
        case .purity: return "Purity"
        case .corinthians1: return "1 Corinthians"
        case .corinthians2: return "2 Corinthians"
        case .samuel1: return "1 Samuel"
        case .samuel2: return "2 Samuel"
        case .kings1: return "1 Kings"
        case .kings2: return "2 Kings"
        case .chronicles1: return "1 Chronicles"
        case .chronicles2: return "2 Chronicles"
        case .parenting: return "Raising children"
        case .peter1: return "1 Peter"
        case .peter2: return "2 Peter"
        case .thessalonians1: return "1 Thessalonians"
        case .thessalonians2: return "2 Thessalonians"
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
        case .general, .favorites, .myOwn, .ephesians, .faith, .health, .destiny, .genesis,  .godsprotection, .proverbs, .luke : return false
        default: return true
        }
    }
}

struct Updates: Codable {
    let currentDeclarationVersion: Int?
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
    var bibleVerseText: String? = nil
    var category: DeclarationCategory = .faith
    var categories: [DeclarationCategory] = []
    var isFavorite: Bool? = false
    var id: String {
       //UUID().uuidString
        text + category.rawValue
    }
    
    enum CodingKeys: String, CodingKey {
            case text
            case book
            case bibleVerseText
            case category
            case isFavorite
        }
    
    var lastEdit: Date?
}
