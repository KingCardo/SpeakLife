//
//  SpeechSynthesizer.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/7/23.
//

import Foundation
import AVFoundation

final class SpeechSynthesizer: ObservableObject {
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func speakText(_ text: String, language: String = "en-US") {
       
        let speechUtterance = AVSpeechUtterance(string: text)
        "com.apple.eloquence.de-DE.Grandpa"
        
        // Set the voice to Siri's voice
        if let voice = AVSpeechSynthesisVoice(language: "com.apple.speech.synthesis.voice.Zarvox") {
            speechUtterance.voice = voice
        }
        
        // Set the speech rate and volume (optional)
        speechUtterance.rate = 0.5
        speechUtterance.volume = 0.8
        
        // Start speaking the text
        speechSynthesizer.speak(speechUtterance)
    }
}






