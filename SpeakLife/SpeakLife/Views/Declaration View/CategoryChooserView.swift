//
//  CategoryChooserView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/13/22.
//

import SwiftUI
import FirebaseAnalytics

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

struct CategoryCell: View  {
    
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @Environment(\.colorScheme) var colorScheme
    
    let size: CGSize
    var category: DeclarationCategory
    
    var body: some View {
        categoryCell(size: size)
    }
    
    @ViewBuilder
    private func categoryCell(size: CGSize) -> some View  {
        
        let dimension =  size.width *  0.4
        
        ZStack {
            colorScheme == .dark ? Constants.DEABlack : Color.white
            
            VStack {
                ZStack(alignment: .topTrailing) {
                    if assetExists(named: category.imageString) {
                        Image(category.imageString)
                            .resizable().scaledToFill()
                            .frame(width: dimension, height: dimension)
                            .clipped()
                            .cornerRadius(4)
                        
                        lockIcon
                        
                    } else {
                        Gradients().random
                            .scaledToFill()
                            .frame(width: dimension, height: dimension)
                            .clipped()
                            .cornerRadius(4)
                        lockIcon
                    }
                }
        
                
                Text(category.categoryTitle)
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 20))
                    .foregroundColor( colorScheme == .dark ? .white : Constants.DEABlack)
                
            }
        }
        .frame(width: dimension + 16, height: size.width * 0.52)
        .cornerRadius(6)
        .shadow(color: Constants.lightShadow, radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    var lockIcon: some View {
        if category.isPremium && !subscriptionStore.isPremium {
            ZStack {
                VisualEffectBlur(blurStyle: .systemMaterial)
                    .frame(width: 32, height: 32)
                
                    .padding(20)
                    .blur(radius: 8)
                   
                Image(systemName: "lock.fill")
                    .font(.title)
                    .frame(width: 25, height: 25)
          
            }
            
        }
    }
}

struct CategoryChooserView: View {
    
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: DeclarationViewModel
    @State private var presentPremiumView  = false
    
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    Spacer()
                    
                        Text("Select one of the following categories to get powerful promises focused on your needs.", comment: "category reminder selection")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 18))
                            .foregroundColor(colorScheme == .dark ?  .white : Constants.DALightBlue)
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .lineLimit(2)
                            .padding()
                            .background(BlurView(style: .systemUltraThinMaterial))
                            .cornerRadius(8)
                            
                    
                    categoryList(geometry: geometry)
                    
                }
                .background(
                    Image(onboardingBGImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    self.presentPremiumView = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            }.onAppear  {
                UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Constants.DAMidBlue)]
            }.alert(viewModel.errorMessage ?? "Error", isPresented: $viewModel.showErrorMessage) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private func categoryList(geometry: GeometryProxy) -> some View {
      
        LazyVGrid(columns: twoColumnGrid, spacing: 16) {
            ForEach(viewModel.allCategories) { category in
                
                CategoryCell(size: geometry.size, category: category)
                    .onTapGesture {
                        if category.isPremium && !subscriptionStore.isPremium {
                            presentPremiumView = true
                        } else {
                            viewModel.choose(category) { success in
                                if success {
                                    Analytics.logEvent(Event.categoryChooserTapped, parameters: ["category": category.rawValue])
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $presentPremiumView) {
                        PremiumView()
                    }
            }
        }.padding()
    }
}
