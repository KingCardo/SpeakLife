//
//  SelectionFeedback.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/14/22.
//

import SwiftUI

struct Selection {
    
    static var shared = Selection()
    
    private var generator = UISelectionFeedbackGenerator()
    
    private init() {
        generator.prepare()
    }
    
    func selectionFeedback() {
        generator.selectionChanged()
    }
}


