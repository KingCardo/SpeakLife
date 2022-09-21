//
//  ThemeViewModel.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/7/22.
//

import SwiftUI

final class ThemeViewModel: ObservableObject {
    
    @AppStorage("theme") var theme = Theme.longroadtraveled.encode()!
    @AppStorage("fontString") var fontString = "BodoniSvtyTwoOSITCTT-Book" {
        didSet {
            selectedFont = .custom(fontString, size: 38)
        }
    }
    
    // MARK: Properties
    
    @Published var selectedTheme: Theme = .longroadtraveled
    @Published var selectedFont: Font = .custom("BodoniSvtyTwoOSITCTT-Book", size: 38)
    
    
    init() {
        load()
    }
    
    var themes: [Theme] = Theme.all

    
    // MARK: Intent(s)
    
    func choose(_ theme: Theme) {
        self.selectedTheme = theme
        selectedTheme.setBackground(theme.backgroundImageString)
    }
    
    func choose(_ font: Font) {
        self.selectedFont = font
    }
    
    func setFontName(_ fontString: String) {
        self.fontString = fontString
    }
    
    func save() {
        guard let data = selectedTheme.encode() else { return }
        theme = data
    }
    
    func load()  {
        if let theme = Theme.decode(data: theme) {
            selectedTheme = theme
            selectedFont = .custom(fontString, size: 38)
        }
    }
}
