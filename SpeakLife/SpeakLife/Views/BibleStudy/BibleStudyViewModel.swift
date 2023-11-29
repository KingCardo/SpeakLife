//
//  BibleStudyViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/28/23.
//

import SwiftUI

final class BibleStudyViewModel: ObservableObject {
    
    @Published var error: String = ""
    @Published var plans: [String] = []
    
    init() {
        let apiClient = BibleReadingPlanAPIClient(networkService: NetworkService())
        apiClient.fetchBibleReadingPlan { data, response, error in
            if let error = error {
                print(error)
//            } 
//            else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                
            } else if let data = data {
                
                
            }
        }
    }
}
