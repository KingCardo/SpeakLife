//
//  FontChooserView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/9/22.
//

import SwiftUI


struct FontChooserView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var themeViewModel: ThemeViewModel
    
    var hideFontPicker: ((Bool) -> Void)
    
    var body: some View {
            FontChooser() { selectedFont, fontName in
                themeViewModel.setFontName(fontName)
                themeViewModel.choose(selectedFont)
                withAnimation {
                hideFontPicker(true)
                }
            }
    }
}
