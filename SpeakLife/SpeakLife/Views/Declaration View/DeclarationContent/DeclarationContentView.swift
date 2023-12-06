//
//  DeclarationContentView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/4/22.
//

import SwiftUI
import FirebaseAnalytics

struct DeclarationContentView: View {
    
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    
    @ObservedObject var themeViewModel: ThemeViewModel
    @ObservedObject var viewModel: DeclarationViewModel
    @State private var isFavorite: Bool = false
    @State private var showShareSheet = false
    @State private var image: UIImage?
    @State private var showAnimation = false
    @State private var selectedTab = 0
    @State private var fadeInOpacity = 0.0
    @State private var discountCounter = 0
    @State private var reviewCounter = 0
    
    private let degrees: Double = 90
    
    init(themeViewModel: ThemeViewModel,
         viewModel: DeclarationViewModel) {
        self.themeViewModel  = themeViewModel
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selectedTab) {
                ForEach(Array(viewModel.declarations.enumerated()), id: \.element) { index, declaration in
                    ZStack {
                        quoteLabel(declaration, geometry)
                            .opacity(fadeInOpacity)
                           
                            .padding()
                            .rotationEffect(Angle(degrees: -degrees))
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            
                           
                        
                        if !showShareSheet {
                            intentVstack(declaration: declaration, geometry)
                                .rotationEffect(Angle(degrees: -degrees))
                        }
                        
                        if isFavorite {
                            withAnimation(.spring(response: 0.34, dampingFraction: 0.8, blendDuration: 0.5)) {
                                HeartView()
                                    .scaleEffect(1.2)
                                    .transition(.scale)
                            }
                            
                            .rotationEffect(Angle(degrees: -degrees))
                            .onAppear {
                                let delay = RunLoop.SchedulerTimeType(.init(timeIntervalSinceNow: 0.3))
                                RunLoop.main.schedule(after: delay) {
                                    withAnimation {
                                        self.isFavorite = false
                                    }
                                }
                            }
                        }
                    }
                    
                    .tag(index)
                    .sheet(isPresented: $showShareSheet) {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        }
                        ShareSheet(activityItems: [image as Any])
                    }
                    
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: selectedTab) { newIndex in
                    fadeInOpacity = 0.0
                askForReview()
                offerDiscountSubscription()
                withAnimation(.easeOut(duration: 1.0)) {
                    fadeInOpacity = 1.0
                }
            }
            .frame(width: geometry.size.height, height: geometry.size.width)
            .rotationEffect(.degrees(90), anchor: .topLeading)
            .offset(x: geometry.size.width)
           
            .onAppear {
                fadeInOpacity = 1.0
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.showShareSheet = false
            }
        }
    }
    
    private func askForReview() {
        reviewCounter += 1
        if reviewCounter == 3 || reviewCounter == 15 {
            viewModel.requestReview = true 
        }
    }
    
    private func offerDiscountSubscription() {
        discountCounter += 1
        if (discountCounter % 9 == 0), appState.discountOfferedTries <= 2, !subscriptionStore.isPremium {
            viewModel.showDiscountView = true
            appState.discountOfferedTries += 1
        }
    }
    
    
    private func intentVstack(declaration: Declaration, _ geometry: GeometryProxy) -> some View {
        VStack {
            
            screenshotLabel()
            
            Spacer()
            intentStackButtons(declaration: declaration)
            Spacer()
                .frame(height: horizontalSizeClass == .compact ? geometry.size.height * 0.15 : geometry.size.height * 0.30)
        }
        
        
    }
    
    @ViewBuilder
    private func screenshotLabel() -> some View {
        if appState.showScreenshotLabel, !subscriptionStore.isPremium {
            Text("@speaklife.bibleapp")
                .font(.caption)
                .foregroundColor(Color.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                .transition(.opacity)
        }
        
    }
    
    
    private func quoteLabel(_ declaration: Declaration, _ geometry: GeometryProxy) -> some View  {
        
        VStack {
            Spacer()
            
            QuoteLabel(themeViewModel: themeViewModel, quote: declaration.text)
                .frame(width: geometry.size.width * 0.98, height:  geometry.size.height * 0.40)
                .shadow(color: .black, radius: themeViewModel.selectedTheme.blurEffect ? 10 : 0)
            
            Text(declaration.book ?? "")
                .foregroundColor(.white)
                .font(themeViewModel.selectedFontForBook ?? .caption)
                .shadow(color: .black, radius: themeViewModel.selectedTheme.blurEffect ? 10 : 0)
            
            Spacer()
                .frame(height: (horizontalSizeClass == .compact && verticalSizeClass == .compact) ? geometry.size.height * 0.15 : geometry.size.height * 0.35)
        }.onAppear {
            Analytics.logEvent(Event.swipe_affirmation, parameters: nil)
        }
    }
    
    @ViewBuilder
    private func intentStackButtons(declaration: Declaration) -> some View  {
        if !appState.showScreenshotLabel {
            HStack(spacing: 24) {
                
                CapsuleImageButton(title: "tray.and.arrow.up") {
                    viewModel.setCurrent(declaration)
                    withAnimation {
                        appState.showScreenshotLabel = true
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            if let window = windowScene.windows.first {
                                image = window.rootViewController?.view.toImage()
                            }
                        }
                        self.showShareSheet = true
                    }
                    
                    Analytics.logEvent(Event.shareTapped, parameters: nil)
                    Selection.shared.selectionFeedback()
                    // Hide the label after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        appState.showScreenshotLabel = false
                        viewModel.requestReview.toggle()
                    }
                }
                
                
                CapsuleImageButton(title: declaration.isFavorite ? "heart.fill" : "heart") {
                    favorite(declaration)
                    self.isFavorite = declaration.isFavorite ? false : true
                    Analytics.logEvent(Event.favoriteTapped, parameters: nil)
                    Selection.shared.selectionFeedback()
                }
            }
            .foregroundColor(.white)
        }
    }
    private func setCurrentDelcaration(declaration: Declaration) {
        viewModel.setCurrent(declaration)
    }
    
    
    private func favorite(_ declaration: Declaration) {
        viewModel.favorite(declaration: declaration)
        viewModel.requestReview.toggle()
    }
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct DeclarationContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        DeclarationContentView(themeViewModel: ThemeViewModel(), viewModel: DeclarationViewModel(apiService: APIClient()))
        
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}
