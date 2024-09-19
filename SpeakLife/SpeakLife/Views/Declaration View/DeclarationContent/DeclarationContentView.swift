//
//  DeclarationContentView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/4/22.
//

import SwiftUI
import FirebaseAnalytics
import UIKit
import AVFoundation

struct DeclarationContentView: View {
    
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
    @State private var reviewCounter = 0
    
    private let degrees: Double = 90
    
    //@StateObject private var coordinator = SpeechCoordinator()
    @State private var isMenuExpanded = false
    @State private var rotationAngle: Double = 0
    @State private var buttonVisibilities: [Bool] = [false, false]
    @State private var numberOfItems: Int = 2
    
    
    init(themeViewModel: ThemeViewModel,
         viewModel: DeclarationViewModel) {
        self.themeViewModel  = themeViewModel
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $viewModel.selectedTab) {
                ForEach(Array(viewModel.declarations.enumerated()), id: \.element.id) { index, declaration in
                    ZStack {
                        quoteLabel(declaration, geometry)
                            .padding()
                            .rotationEffect(Angle(degrees: -degrees))
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .offset(x: isMenuExpanded ? -geometry.size.width * 0.3 : 0)
                            .animation(.easeInOut, value: isMenuExpanded)
                        
                        
                        if !showShareSheet {
                            intentVstack(declaration: declaration, geometry)
                                .rotationEffect(Angle(degrees: -degrees))
                        }
                        
                        if isMenuExpanded {
                            VStack(spacing: 2) {
                                Spacer()
                                    .frame(height:geometry.size.height * 0.2)
                                ForEach(buttonVisibilities.indices, id: \.self) { index in
                                    if buttonVisibilities[index] {
                                        getButton(for: index, declaration: declaration)
                                            .transition(.move(edge: .bottom).combined(with: .opacity))
                                    }
                                }
                            }
                            .rotationEffect(Angle(degrees: -degrees))
                            .frame(
                                width: geometry.size.width * 0.4,
                                height: geometry.size.height * 0.1
                            )
                            .transition(.move(edge: .trailing))
                        }
                        
                        if isFavorite {
                            withAnimation(.spring(response: 0.34, dampingFraction: 0.8, blendDuration: 0.5)) {
                                HeartView()
                                    .scaleEffect(1.4)
                                    .rotationEffect(.degrees(360))
                                    .transition(.scale)
                                    .shadow(color: .red.opacity(0.7), radius: 10, x: 0, y: 0)
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
                        ShareSheet(activityItems: prepareShareItems())
                    }
                    
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: viewModel.selectedTab) { newIndex in
                askForReview()
                let declaration = viewModel.declarations[newIndex]
                viewModel.setCurrent(declaration)
            }
            .frame(width: geometry.size.height, height: geometry.size.width)
            .rotationEffect(.degrees(90), anchor: .topLeading)
            .offset(x: geometry.size.width)
           
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.showShareSheet = false
            }
        }
    }
    
    func getButtonVisibility(declaration: Declaration) {
        print("Updated buttonVisibilities previous count: \(buttonVisibilities.count) RWRW")
        numberOfItems = 2 // Default
            if declaration.bibleVerseText != nil {
                numberOfItems += 1 // Add the "VERSE" button
            }
        buttonVisibilities = Array(repeating: false, count: numberOfItems)
        print("Updated buttonVisibilities count: \(buttonVisibilities.count) RWRW")
    }
    
    func prepareShareItems() -> [Any] {
        guard let image = image else { return [] }
        let message = "Check out SpeakLife - Bible Meditation and email speaklife@diosesaqui.com for a 30-day free pass. \n\(APP.Product.urlID)"
        return [image, message]
    }

    
    func requestReview() {
        viewModel.requestReview = true
        appState.helpUsGrowCount += 1
    }
    
    private func askForReview() {
        reviewCounter += 1
        if reviewCounter % 7 == 0 {
            viewModel.requestReview = true
        }
    }
    
    
    private func intentVstack(declaration: Declaration, _ geometry: GeometryProxy) -> some View {
        VStack {
            
            screenshotLabel()
            
            Spacer()
            //  intentStackButtons(declaration: declaration)
            CapsuleImageButton(title: isMenuExpanded ? "xmark" : "plus") {
                withAnimation(.easeInOut) {
                    if isMenuExpanded {
                        hideButtonsInSequence() // Ensure buttons are hidden before collapsing
                    } else {
                        getButtonVisibility(declaration: declaration)// Update button visibilities before showing
                        showButtonsInSequence()
                    }
                    isMenuExpanded.toggle()
                    rotationAngle = isMenuExpanded ? 135 : 0
                }
            }
            .rotationEffect(.degrees(rotationAngle))
            .animation(.easeInOut, value: rotationAngle)

            Spacer()
                .frame(height: horizontalSizeClass == .compact ? geometry.size.height * 0.10 : geometry.size.height * 0.25)
        }
    }
    
    func showButtonsInSequence() {
            for index in buttonVisibilities.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) { // Adjust the delay as needed
                    withAnimation {
                        print("Animating button at index: \(index) RWRW")
                        buttonVisibilities[index] = true
                    }
                }
            }
        }
        
        // Hide buttons one by one with delay
        func hideButtonsInSequence() {
            for index in buttonVisibilities.indices.reversed() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) { // Adjust the delay as needed
                    withAnimation(.easeInOut) {
                        print("Hiding button at index: \(index) RWRW")
                        buttonVisibilities[index] = false
                    }
                }
            }
        }
        
    func getButton(for index: Int, declaration: Declaration) -> some View {
        var buttons:[AnyView] = [
            AnyView(DeclarationMenuButton(iconName: "square.and.arrow.up", label: "SHARE") {
                withAnimation(.easeInOut) {
                    isMenuExpanded = false
                }
            shareTapped(declaration: declaration) }),
            AnyView(DeclarationMenuButton(iconName:  declaration.isFavorite ? "heart.fill" : "heart", label: "FAVORITE") { favoriteTapped(declaration: declaration) }),
           // AnyView(DeclarationMenuButton(iconName: "speaker.wave.2.fill", label: "SPEAK") { speakTapped(declaration: declaration)})
        ]
        
        if declaration.bibleVerseText != nil {
            buttons.append(AnyView(DeclarationMenuButton(iconName: viewModel.showVerse ? "arrowshape.zigzag.forward" : "arrowshape.zigzag.right.fill", label: "VERSE") { showVerse(declaration: declaration) }))
        }
        if index < buttons.count {
               return buttons[index]
           } else {
               return AnyView(EmptyView())
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
            
            QuoteLabel(themeViewModel: themeViewModel, quote: viewModel.showVerse ? declaration.text : declaration.bibleVerseText ?? "")
                .foregroundColor(themeViewModel.selectedTheme.fontColor)
                .frame(width: geometry.size.width * 0.98, height:  geometry.size.height * 0.25)
                .shadow(color: .black, radius: themeViewModel.selectedTheme.blurEffect ? 10 : 0)
            
            Text(declaration.book ?? "")
                .foregroundColor(.white.opacity(0.9))
                .font(themeViewModel.selectedFontForBook ?? .caption)
                .shadow(color: .black, radius: themeViewModel.selectedTheme.blurEffect ? 10 : 0)
            
            Spacer()
                .frame(height: geometry.size.height * 0.50)//(horizontalSizeClass == .compact && verticalSizeClass == .compact) ? geometry.size.height * 0.30 : geometry.size.height * 0.50)
        }.onAppear {
            Analytics.logEvent(Event.swipe_affirmation, parameters: nil)
        }
    }
    
    private func shareTapped(declaration: Declaration) {
        viewModel.setCurrent(declaration)
        withAnimation {
            appState.showScreenshotLabel = true
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first {
                    image = window.rootViewController?.view.toImage()
                    self.showShareSheet = true
                }
            }
            
        }
        
        Analytics.logEvent(Event.shareTapped, parameters: ["share": declaration.text])
        Selection.shared.selectionFeedback()
        // Hide the label after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            appState.showScreenshotLabel = false
            viewModel.requestReview.toggle()
        }
    }
    
//    private func speakTapped(declaration: Declaration) {
//        affirm(declaration, isAffirmation: viewModel.showVerse)
//        Analytics.logEvent(Event.speechTapped, parameters: ["declaration": declaration.text])
//        Selection.shared.selectionFeedback()
//    }
    
    private func showVerse(declaration: Declaration) {
        withAnimation {
            toggleDeclaration(declaration)
        }
        Selection.shared.selectionFeedback()
    }
    
    private func favoriteTapped(declaration: Declaration) {
        favorite(declaration)
        self.isFavorite = declaration.isFavorite ? false : true
        Analytics.logEvent(Event.favoriteTapped, parameters: ["declaration": declaration.text])
        Selection.shared.selectionFeedback()
    }
    
    @ViewBuilder
    private func intentStackButtons(declaration: Declaration) -> some View  {
        if !appState.showScreenshotLabel {
            HStack(spacing: 24) {
                
                CapsuleImageButton(title: "tray.and.arrow.up") {
                    shareTapped(declaration: declaration)
                }
                
                
//                CapsuleImageButton(title: "speaker.wave.2.fill") {
//                    speakTapped(declaration: declaration)
//                }
    
                
                if declaration.bibleVerseText != nil {
                    CapsuleImageButton(title: viewModel.showVerse ? "arrowshape.zigzag.forward" : "arrowshape.zigzag.right.fill") {
                        showVerse(declaration: declaration)
                    }
                }
                
                CapsuleImageButton(title: declaration.isFavorite ? "heart.fill" : "heart") {
                    favoriteTapped(declaration: declaration)
                }
            }
            .foregroundColor(.white)
        }
    }
    
//    private func affirm(_ declaration: Declaration, isAffirmation: Bool) {
//        AudioPlayerService.shared.pauseMusic()
//        let text = isAffirmation ? "Repeat after me, \(declaration.text)" : declaration.bibleVerseText
//        coordinator.speakText(text!)
//    }
    
    private func setCurrentDelcaration(declaration: Declaration) {
        viewModel.setCurrent(declaration)
    }
    
    private func toggleDeclaration(_ declaration: Declaration) {
        viewModel.toggleDeclaration(declaration)
    }
    
    
    private func favorite(_ declaration: Declaration) {
        viewModel.favorite(declaration: declaration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            viewModel.requestReview.toggle()
        }
    }
    
    private func dislike(_ declaration: Declaration) {
        viewModel.dislike(declaration: declaration)
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


