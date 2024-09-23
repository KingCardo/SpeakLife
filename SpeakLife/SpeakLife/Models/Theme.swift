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
    
    var fontColor: Color {
        switch fontColorString {
        case "white": return Color.white
        case "green": return .green
        case "black" : return .black
        case "gold": return Constants.gold
        case "slBlue": return Constants.DAMidBlue
        default: return .white
        }
    }
    let fontColorString: String
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
    
    init(_ backgroundImageString: String, mode: Mode = .dark, isPremium: Bool = true, blurEffect: Bool = false, userSelectedImageData: Data? = nil, fontColorString: String = "white") {
        self.backgroundImageString = backgroundImageString
        self.mode = mode
        self.isPremium = isPremium
        self.blurEffect = blurEffect
        self.userSelectedImageData = userSelectedImageData
        self.fontColorString = fontColorString
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
    
    static var all: [Theme] = [JesusOnCross,JesusOnWater, twinAngels,warriorAngel, majesticNight, mountainLandscape, starryNight,peacefulMountainNight,countryNightSky, lakeTrees, pinkHueMountain, forestSunrise,sunsetMountain,sereneMountain,calmLake,tranquilSunset, breathTakingSunset,grassyField, sunset3,moonlight2,desertsky,moon,  stars, forestwinter,lakeHills, lakeMountain, safari,lion]
    
    private static let JesusOnCross = Theme("JesusOnCross", blurEffect: true)
    private static let JesusOnWater = Theme("JesusOnWater", blurEffect: true)
    private static let twinAngels = Theme("twinAngels", blurEffect: true)
    private static let warriorAngel = Theme("warriorAngel", blurEffect: true)
    private static let countryNightSky = Theme("countryNightSky", blurEffect: true)
    private static let mountainLandscape = Theme("mountainLandscape")
    private static let majesticNight = Theme("majesticNight")
    private static let forestSunrise = Theme("forestSunrise", blurEffect: true)
    private static let pinkHueMountain = Theme("pinkHueMountain", blurEffect: true)
    private static let sunsetMountain = Theme("sunsetMountain", blurEffect: true)
    private static let starryNight = Theme("starryNight", blurEffect: true)
    private static let peacefulMountainNight = Theme("peacefulMountainNight", blurEffect: true)
    private static let lakeTrees = Theme("lakeTrees", blurEffect: true)
    private static let sereneMountain = Theme("sereneMountain", blurEffect: true)
    private static let grassyField = Theme("grassyField", blurEffect: true)
    private static let tranquilSunset = Theme("tranquilSunset", blurEffect: true)
    private static let breathTakingSunset = Theme("breathTakingSunset", blurEffect: true)
    private static let calmLake = Theme("calmLake", blurEffect: true)
    private static let autumnTrees = Theme("autumntrees", isPremium: false, blurEffect: true, fontColorString: "white")
    private static let cross = Theme("cross", isPremium: false)
    private static let lion = Theme("lion", mode: .light, isPremium: false)
    static let longroadtraveled = Theme("longroadtraveled")
    private static let moon = Theme("moon")
    private static let rainbow = Theme("rainbow")
    private static let space = Theme("space", mode: .light)
    private static let stars = Theme("stars", mode: .light)
    private static let summerbeach = Theme("summerbeach", blurEffect: true)
    private static let canyons = Theme("canyons")
    private static let talltrees = Theme("talltrees",  mode: .light, blurEffect: true)
    private static let luxurydrive = Theme("luxurydrive")
    private static let beautifulsky = Theme("beautifulsky")
    private static let desertsky = Theme("desertSky", mode: .light, blurEffect: true)
    private static let gorgeousmoon = Theme("gorgeousmoon")
    private static let plantgreen = Theme("plantgreen")
    private static let fogroad = Theme("fogroad", blurEffect: true)
    private static let greenplants = Theme("greenPlants",blurEffect: true)
    private static let trippy = Theme("trippy",blurEffect: true)
    private static let landingView1 = Theme("landingView1",blurEffect: true)
    static let landingView2 = Theme("landingView2",blurEffect: true)
    static let highway = Theme("highway",blurEffect: true)
    static let lakeMountain = Theme("lakeMountain",blurEffect: true)
    static let lakeHills = Theme("lakeHills",isPremium: false,blurEffect: true)
    static let sandOcean = Theme("sandOcean",blurEffect: true)
    static let citynight = Theme("citynight",blurEffect: false)
    static let woodnight = Theme("woodnight",blurEffect: true)
    static let forestwinter = Theme("forestwinter",blurEffect: false)
    static let sunset1 = Theme("sunset1",blurEffect: false)
    static let sunset2 = Theme("sunset2",blurEffect: false)
    static let sunset3 = Theme("sunset3",blurEffect: false)
    static let sunset4 = Theme("sunset4",blurEffect: true)
    static let sunset5 = Theme("sunset5",blurEffect: false)
    static let moonlight2 = Theme("moonlight2",isPremium: false)
    static let icegreenmountain = Theme("icegreenmountain",blurEffect: true)
    static let chicago = Theme("chicago",blurEffect: false)
    static let gorgeous = Theme("gorgeous",blurEffect: true)//, fontColorString: "gold")
    static let kitty = Theme("kitty",blurEffect: true)
    static let meercat = Theme("meercat",blurEffect: true)
    static let taicitylights = Theme("taicitylights",blurEffect: true)
    static let safari = Theme("safari",blurEffect: true)
    static let aurora = Theme("aurora",blurEffect: false)
}




