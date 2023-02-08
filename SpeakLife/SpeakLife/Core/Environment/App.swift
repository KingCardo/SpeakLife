//
//  App.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/30/22.
//

import Foundation

struct APP {
    enum Version  {
        static var stringNumber: String {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        }
        
        static var sharedSecret: String {
            "437413ffc42448a28a4f6daa851c1820"
        }
    }
    
    enum Product {
        static var urlID: String {
            "https://apps.apple.com/app/id1617492998"
        }
        
        static var instagramURL: String {
            "https://www.instagram.com/speaklife_biblepromises"
        }
    }
}
