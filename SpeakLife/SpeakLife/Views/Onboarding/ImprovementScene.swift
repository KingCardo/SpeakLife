//
//  ImprovementScene.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 1/9/24.
//

import SwiftUI
import FirebaseAnalytics

struct ImprovementScene: View {
    @EnvironmentObject var appState: AppState
    
    let size: CGSize
    let callBack: (() -> Void)
    @ObservedObject var viewModel: ImprovementViewModel
    
    var body: some  View {
        improvementView(size: size)
    }
    
    private func improvementView(size: CGSize) -> some View  {
        ScrollView {
            Spacer().frame(height: 30)
               
                VStack {
                    Text("What would you like to practice first?", comment: "Intro scene title label")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 24, relativeTo: .title))
                        .fontWeight(.semibold)
                        .foregroundColor(appState.onBoardingTest ? .white : Constants.DEABlack)
                        .padding()
                        .lineLimit(2)
                    
                    Spacer().frame(height: 16)
                    
                    VStack {
                        Text("Select as many as you like" , comment: "Intro scene instructions")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .body))
                            .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .lineLimit(nil)
                        
                        Spacer().frame(height: 24)
                        
                    }
                    .frame(width: size.width * 0.8)
                }
                Spacer()
                
                ImprovementSelectionListView(viewModel: viewModel)
                .frame(width: size.width * 0.9)
                Spacer()
                .frame(height: 200)
                
                Button(action: callBack) {
                    HStack {
                        Text("Transform me", comment: "Intro scene start label")
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
            .scrollIndicators(.hidden)
            .frame(width: size.width, height: size.height)
            .background(
                Image(appState.onBoardingTest ? onboardingBGImage : "declarationBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
            )
        
    }
    
    
}

class ImprovementViewModel: ObservableObject {
    @Published var selectedExperiences: [Improvements] = []
    
    var selectedCategories: String {
        var categories = selectedExperiences.map { $0.selectedCategory }
        if categories.contains("grace") {
            categories.append("guilt")
            categories.append("forgiveness")
        }
        
        if categories.contains("peace") {
            categories.append("rest")
        }
        
        if categories.contains("stress") {
            categories.append("rest")
            categories.append("peace")
        }
        if !categories.contains("destiny") {
            categories.append("destiny")
        }
        
        if categories.contains("gospel") {
            categories.append("matthew")
            categories.append("mark")
        }
        
        if categories.contains("psalms") {
            categories.append("psalms")
            categories.append("proverbs")
        }
        return categories.joined(separator: ",")
    }
    
    func selectExperience(_ experience: Improvements) {
        if selectedExperiences.contains(experience) {
            selectedExperiences.removeAll(where: { $0 == experience })
        } else {
            selectedExperiences.append(experience)
            Analytics.logEvent(experience.selectedCategory, parameters: nil)
        }
    }
}

enum Improvements: String, CaseIterable {
    
   // case joy = "Be happy and content"
    case gospel = "New Testament - Gospel"
    case psalms = "Psalms & Proverbs"
    case gratitude = "Gratitude"
    case stress = "Remove Stress & Anxiety"
   // case praise = "Magnify the Lord"
    case grace = "God's Grace"
    case love = "Jesus Love"
    case health = "Health"
    case destiny = "Destiny"
    case safety = "God's protection"
   // case guilt = "Be free from guilt and condemnation"
    case loneliness = "Feeling lonely"
  //  case wealth = "Wealth"
    case peace = "Peace"
    
    
    var selectedCategory: String {
        switch self {
        case .gospel:
            "gospel"
        case .psalms:
            "psalms"
        case .stress:
            "fear"
        case .grace:
            "grace"
        case .love:
            "love"
        case .destiny:
            "destiny"
        case .health:
            "health"
        case .safety:
            "godsprotection"
        case .gratitude:
            "gratitude"
        case .loneliness:
            "loneliness"
        case .peace:
            "peace"
        }
    }
}

struct ImprovementSelectionListView: View {
    @ObservedObject var viewModel: ImprovementViewModel
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    
    var body: some View {
        newBody
//        VStack {
//            
//            ForEach(Improvements.allCases, id: \.self) { experience in
//                Button(action: {
//                    impactMed.impactOccurred()
//                    viewModel.selectExperience(experience)
//                }) {
//                    HStack {
//                        Text(experience.rawValue)
//                            .foregroundColor(.white)
//                        Spacer()
//                        if viewModel.selectedExperiences.contains(experience) {
//                            Image(systemName: "checkmark")
//                                .foregroundColor(.white)
//                        }
//                    }
//                }
//                .padding()
//                .background(Constants.DAMidBlue.opacity(viewModel.selectedExperiences.contains(experience) ? 0.8 : 0.3))
//                .cornerRadius(10)
//            }
//        }
//        .padding()
    }
    
    var newBody: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(Improvements.allCases, id: \.self) { interest in
                    Text(interest.rawValue)
                        .font(.system(size: 14))
                        .padding(8)
                        .background(Constants.DAMidBlue.opacity(viewModel.selectedExperiences.contains(interest) ? 0.8 : 0.3))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .fixedSize(horizontal: true, vertical: false)
                        .onTapGesture {
                            viewModel.selectExperience(interest)
                        }
                }
            }
            .padding()
        }
    }
}


