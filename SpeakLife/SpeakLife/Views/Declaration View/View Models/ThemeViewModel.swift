//
//  ThemeViewModel.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/7/22.
//

import SwiftUI
import Combine


final class ThemeViewModel: ObservableObject {
    
    @AppStorage("theme") var theme = Theme.moonlight2.encode()!
    @AppStorage("fontString") var fontString = "Cochin" {
        didSet {
            selectedFont = .custom(fontString, size: fontSize)
        }
    }
    let fontSize: CGFloat = 30
    @Published var selectedImage: UIImage? = nil
    @Published var backgroundImage: Image? = nil
    @Published var showUserSelectedImage = false
    
    private var cancellable: AnyCancellable?
    
    
    // MARK: Properties
    
    @Published var selectedTheme: Theme = .moonlight2
    @Published var selectedFont: Font = .custom("Cochin", size: 30) {
        didSet  {
            updateSelectedFontForBook()
        }
    }
    
    @Published var selectedFontForBook: Font?
    
    private func updateSelectedFontForBook() {
        selectedFontForBook = .custom(fontString, size: 18)
    }
    
    
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.theme = data
        }
    }
    
    func load()  {
        if let theme = Theme.decode(data: theme) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.selectedTheme = theme
                self.selectedFont = .custom(self.fontString, size: fontSize)
                self.selectedImage = theme.userSelectedImage
            }
        }
    }
}
