//
//  ThemeViewModel.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/7/22.
//

import SwiftUI
import Combine


final class ThemeViewModel: ObservableObject {
    
    @AppStorage("theme") var theme = Theme.longroadtraveled.encode()!
    @AppStorage("fontString") var fontString = "AppleSDGothicNeo-Regular" {
        didSet {
            selectedFont = .custom(fontString, size: 38)
        }
    }
    
    @Published var selectedImage: UIImage? = nil
    @Published var backgroundImage: Image? = nil
    @Published var showUserSelectedImage = false
    
    private var cancellable: AnyCancellable?
    
    
    // MARK: Properties
    
    @Published var selectedTheme: Theme = .longroadtraveled
    @Published var selectedFont: Font = .custom("AppleSDGothicNeo-Regular", size: 38)
    
    
    init() {
        load()
        cancellable = $selectedImage
            .sink { [weak self] image in
                guard let self = self else { return }
                if let image = image {
                    self.selectedTheme.setUserSelectedImage(image: image)
                    self.showUserSelectedImage = true
                } else {
                    self.showUserSelectedImage = false
                }
            }
    }
    
    var themes: [Theme] = Theme.all
    
    
    // MARK: Intent(s)
    
    func choose(_ theme: Theme) {
        self.selectedTheme = theme
        showUserSelectedImage = false
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
            selectedImage = theme.userSelectedImage
        }
    }
}
