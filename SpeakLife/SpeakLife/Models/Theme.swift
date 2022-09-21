//
//  Theme.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/7/22.
//

import Foundation
import SwiftUI

struct Theme: Identifiable, Codable {
    
    enum Mode: String, Codable {
        case light
        case dark
    }
    
    let isPremium: Bool
    
    var backgroundImageString: String
    var id = UUID()
    var mode: Mode
    let blurEffect: Bool
    var image: Image {
        Image(backgroundImageString)
    }
    
    init(_ backgroundImageString: String, mode: Mode = .dark, isPremium: Bool = true, blurEffect: Bool = false) {
        self.backgroundImageString = backgroundImageString
        self.mode = mode
        self.isPremium = isPremium
        self.blurEffect = blurEffect
    }
    
    mutating func setBackground(_ backgroundImageString: String) {
        self.backgroundImageString  = backgroundImageString
    }
    
     func encode() -> Data? {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            return encoded
        } else {
            return nil
        }
    }
    
    static func decode(data: Data) -> Theme? {
        let decoder = JSONDecoder()
        if let theme = try? decoder.decode(Theme.self, from: data) {
            return theme
        } else {
            return nil
        }
    }
    
    static var all: [Theme] = [autumnTrees, cross, lion, longroadtraveled, rainbow, space, stars, summerbeach, moon, canyons, artsy, luxurydrive]
    
    private static let autumnTrees = Theme("autumntrees", isPremium: false, blurEffect: true)
    private static let cross = Theme("cross", isPremium: false)
    private static let lion = Theme("lion", mode: .light, isPremium: false)
    static let longroadtraveled = Theme("longroadtraveled", isPremium: false)
    private static let moon = Theme("moon")
    private static let rainbow = Theme("rainbow")
    private static let space = Theme("space", mode: .light)
    private static let stars = Theme("stars", mode: .light)
    private static let summerbeach = Theme("summerbeach", blurEffect: true)
    private static let artsy = Theme("artsy", blurEffect: true)
    private static let canyons = Theme("canyons", blurEffect: false)
    private static let talltrees = Theme("talltrees",  mode: .light, blurEffect: false)
    private static let luxurydrive = Theme("luxurydrive", blurEffect: false)
}




