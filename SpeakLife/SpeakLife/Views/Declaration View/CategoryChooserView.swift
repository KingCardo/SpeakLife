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
    
    let size: CGSize
    var category: DeclarationCategory
    
    var body: some View {
        categoryCell(size: size)
    }
    
    
    @ViewBuilder
    private func categoryCell(size: CGSize) -> some View  {
        
        let dimension =  size.width *  0.44
        
        ZStack {
            
            ZStack(alignment: .topTrailing) {
                if category.isBibleBook {
                    ZStack {
                        Image("JesusOnCross")
                            .resizable().scaledToFill()
                            .frame(width: dimension, height: size.height * 0.22)
                            .clipped()
                            .cornerRadius(4)
                        
                        Gradients().clearGradient
                        lockIcon
                    }
                } else {
                    Gradients().speakLifeBlueCell
                        .scaledToFill()
                        .frame(width: dimension, height: size.height * 0.22)
                        .clipped()
                        .cornerRadius(4)
                    lockIcon
                }
            }
            
            VStack {
                    Spacer()
                    Text(category.categoryTitle)
                    .font(Font.custom("AppleSDGothicNeo-Bold", size: 22))
                                  .foregroundColor(.white)
                                  .multilineTextAlignment(.center) // Ensures text wraps properly
                                  .padding(.horizontal, 8) // Avoids text clipping
                                  .frame(width: dimension * 0.9) // Ensures text fits inside the frame
                                  .cornerRadius(4)
                                  .padding(.bottom, 5)
            }
        }
        .frame(width: dimension, height: size.height * 0.22)
        .cornerRadius(6)
        .shadow(color: Constants.lightShadow, radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    var lockIcon: some View {
        if category.isPremium && !subscriptionStore.isPremium {
            ZStack {
                VisualEffectBlur(blurStyle: .systemMaterial)
                    .frame(width: 18, height: 18)
                
                    .padding(10)
                    .blur(radius: 8)
                
                Image(systemName: "lock.fill")
                    .font(.body)
                    .frame(width: 12, height: 12)
                
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
                    VStack {
                        Text("Select one of the following categories to get powerful promises focused on your needs.", comment: "category reminder selection")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .lineLimit(2)
                            .padding()
                            .background(BlurView(style: .systemUltraThinMaterialDark))
                            .cornerRadius(8)
                        
                        generalList(geometry: geometry)
                        categoryList(geometry: geometry)
                        bibleBookList(geometry: geometry)
                    }
                    .frame(maxWidth: .infinity, alignment: .top) // Keeps everything at the top
                }
                .background(
                    Image(subscriptionStore.onboardingBGImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea(.all, edges: .bottom) // Fixes white space issue
                )
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    self.presentPremiumView = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle()) // Fixes NavigationView extra padding
            .onAppear {
                UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Constants.DAMidBlue)]
            }
            .alert(viewModel.errorMessage ?? "Error", isPresented: $viewModel.showErrorMessage) {
                Button("OK", role: .cancel) { }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Ensures proper layout
    }
    
    private func bibleBookList(geometry: GeometryProxy) -> some View {
        Section(header: Text("Bible Book Affirmation's").font(Font.custom("AppleSDGothicNeo-Regular", size: 18))) {
            LazyVGrid(columns: twoColumnGrid, spacing: 16) {
                ForEach(viewModel.bibleCategories) { category in
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
    
    private func generalList(geometry: GeometryProxy) -> some View {
        Section(header: Text("Yours").font(Font.custom("AppleSDGothicNeo-Regular", size: 18))) {
            LazyVGrid(columns: twoColumnGrid, spacing: 16) {
                ForEach(viewModel.generalCategories) { category in
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
    
    private func categoryList(geometry: GeometryProxy) -> some View {
        Section(header: Text("SpeakLife Category Affirmation's").font(Font.custom("AppleSDGothicNeo-Regular", size: 18))) {
            LazyVGrid(columns: twoColumnGrid, spacing: 16) {
                ForEach(viewModel.speaklifeCategories) { category in
                    
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
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var int: UInt64 = 0
        scanner.scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
