//
//  Theme.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/7/22.
//

import Foundation
import SwiftUI

class Theme: Identifiable, Codable {
    
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
    
    private(set) var userSelectedImageData: Data?
    
    var userSelectedImage: UIImage? {
        if let imageData = userSelectedImageData,  let uiimage = UIImage(data: imageData) {
            return uiimage
        }
        return nil
    }
    
    init(_ backgroundImageString: String, mode: Mode = .dark, isPremium: Bool = true, blurEffect: Bool = false, userSelectedImageData: Data? = nil) {
        self.backgroundImageString = backgroundImageString
        self.mode = mode
        self.isPremium = isPremium
        self.blurEffect = blurEffect
        self.userSelectedImageData = userSelectedImageData
    }
    
    func setUserSelectedImage(image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            userSelectedImageData = imageData
        }
    }
    
    func setBackground(_ backgroundImageString: String) {
        self.backgroundImageString = backgroundImageString
        self.userSelectedImageData = nil
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
    
    static var all: [Theme] = [autumnTrees, cross, lion, longroadtraveled, landingView1, landingView2, highway, lakeMountain, lakeHills, sandOcean, rainbow, space, stars, summerbeach, moon, canyons, artsy, luxurydrive,beautifulsky, desertsky, gorgeousmoon, plantgreen, fogroad, greenplants, talltrees, trippy, jungleflower, shadowrose]
    
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
    private static let canyons = Theme("canyons")
    private static let talltrees = Theme("talltrees",  mode: .light)
    private static let luxurydrive = Theme("luxurydrive")
    private static let beautifulsky = Theme("beautifulsky")
    private static let desertsky = Theme("desertSky", mode: .light, blurEffect: true)
    private static let gorgeousmoon = Theme("gorgeousmoon")
    private static let plantgreen = Theme("plantgreen")
    private static let fogroad = Theme("fogroad", blurEffect: true)
    private static let greenplants = Theme("greenPlants",blurEffect: true)
    private static let trippy = Theme("trippy",blurEffect: true)
    private static let shadowrose = Theme("shadowrose",blurEffect: false)
    private static let jungleflower = Theme("jungleflower",blurEffect: true)
    private static let landingView1 = Theme("landingView1",blurEffect: true)
    static let landingView2 = Theme("landingView2",blurEffect: true)
    static let highway = Theme("highway",blurEffect: true)
    static let lakeMountain = Theme("lakeMountain",blurEffect: true)
    static let lakeHills = Theme("lakeHills",blurEffect: true)
    static let sandOcean = Theme("sandOcean",blurEffect: true)
}




