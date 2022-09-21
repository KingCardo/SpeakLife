//
//  FontPickerController.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/9/22.
//

import UIKit
import SwiftUI

struct FontChooser: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    var selectedFontChosen: (Font, String) -> ()
    
    // MARK: - Methods
    
    func makeUIViewController(context: Context) -> UIFontPickerViewController {
        let configuration = UIFontPickerViewController.Configuration()
        configuration.includeFaces = true
        
        let vc = UIFontPickerViewController(configuration: configuration)
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIFontPickerViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIFontPickerViewController
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self) { fontDescriptor in
            
            let uiFont = UIFont(descriptor: fontDescriptor, size: 38)
            let font = Font(uiFont)
            selectedFontChosen(font, uiFont.fontName)
        }
    }
    
    class Coordinator: NSObject, UIFontPickerViewControllerDelegate {
        
        var parent: FontChooser
        private let onFontPick: (UIFontDescriptor) -> Void
        
        init(_ parent: FontChooser, onFontPick: @escaping(UIFontDescriptor) -> Void) {
            self.parent = parent
            self.onFontPick = onFontPick
        }
        
        
        func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            guard let descriptor = viewController.selectedFontDescriptor else { return }
            onFontPick(descriptor)
        }
        
        func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
            
        }
    }
}

