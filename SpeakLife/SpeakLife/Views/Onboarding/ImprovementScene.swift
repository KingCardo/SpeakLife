//
//  ImprovementScene.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 1/9/24.
//

import SwiftUI
import FirebaseAnalytics

struct ImprovementScene: View {
    
    let size: CGSize
    let callBack: (() -> Void)
    @ObservedObject var viewModel: ImprovementViewModel
    
    var body: some  View {
        improvementView(size: size)
    }
    
    private func improvementView(size: CGSize) -> some View  {
        ScrollView {
            Spacer().frame(height: 45)
            //VStack {
               
                VStack {
                    Text("What would you like to improve first?", comment: "Intro scene title label")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 24, relativeTo: .title))
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.DEABlack)
                        .padding()
                        .lineLimit(2)
                    
                    Spacer().frame(height: 16)
                    
                    VStack {
                        Text("Select as many as you like" , comment: "Intro scene instructions")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .body))
                            .foregroundColor(Constants.DALightBlue)
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .lineLimit(nil)
                        
                        Spacer().frame(height: 24)
                        
                    }
                    .frame(width: size.width * 0.8)
                }
                Spacer()
                
                ImprovementSelectionListView(viewModel: viewModel)
                
                Button(action: callBack) {
                    HStack {
                        Text("Continue", comment: "Intro scene start label")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                            .fontWeight(.medium)
                            .frame(width: size.width * 0.91 ,height: 50)
                    }.padding()
                }
                .disabled(viewModel.selectedExperiences.isEmpty)
                .frame(width: size.width * 0.87 ,height: 50)
                .background(viewModel.selectedExperiences.isEmpty ? Constants.DAMidBlue.opacity(0.5) : Constants.DAMidBlue)
                
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(color: Constants.DAMidBlue, radius: 8, x: 0, y: 10)
                
                Spacer()
                    .frame(width: 5, height: size.height * 0.07)
            }
            .frame(width: size.width, height: size.height)
            .background(
                Image("declarationBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
      //  }
        
    }
    
    
}

class ImprovementViewModel: ObservableObject {
    @Published var selectedExperiences: [Improvements] = []
    
    var selectedCategories: String {
        let categories = selectedExperiences.map { $0.selectedCategory }
        return categories.joined(separator: ",")
    }
    
    func selectExperience(_ experience: Improvements) {
        print(experience.selectedCategory, "RWRW")
        if selectedExperiences.contains(experience) {
            selectedExperiences.removeAll(where: { $0 == experience })
        } else {
            selectedExperiences.append(experience)
            Analytics.logEvent(experience.selectedCategory, parameters: nil)
        }
    }
}

enum Improvements: String, CaseIterable { 
    case joy = "Be happy and content"
    case gratitude = "Grow in gratitude"
    case stress = "Reduce Stress & Anxiety"
    case grace = "Learn how forgiven you are"
    case love = "Bask in Jesus Love for you"
    case destiny = "Move closer to your destiny"
    case safety = "Protection and safety"
    case guilt = "Be free from guilt and condemnation"
    case loneliness = "Feeling alone"
    case wealth = "Wealth"
    case peace = "Remain and live in peace"
    
    var selectedCategory: String {
        switch self {
        case .stress:
            "fear"
        case .grace:
            "grace"
        case .love:
            "love"
        case .destiny:
            "destiny"
        case .safety:
            "godsprotection"
        case .guilt:
            "guilt"
        case .joy:
            "joy"
        case .gratitude:
            "gratitude"
        case .loneliness:
            "loneliness"
        case .wealth:
            "wealth"
        case .peace:
            "peace"
        }
    }
}

struct ImprovementSelectionListView: View {
    @ObservedObject var viewModel: ImprovementViewModel
    
    var body: some View {
        VStack {
            
            ForEach(Improvements.allCases, id: \.self) { experience in
                Button(action: {
                    viewModel.selectExperience(experience)
                }) {
                    HStack {
                        Text(experience.rawValue)
                            .foregroundColor(.white)
                        Spacer()
                        if viewModel.selectedExperiences.contains(experience) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Constants.DAMidBlue.opacity(viewModel.selectedExperiences.contains(experience) ? 0.8 : 0.3))
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

