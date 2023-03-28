//
//  DeclarationContentView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/4/22.
//

import SwiftUI
import FirebaseAnalytics

struct DeclarationContentView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var themeViewModel: ThemeViewModel
    @ObservedObject var viewModel: DeclarationViewModel
    @State private var isFavorite: Bool = false
    @State private var showShareSheet = false
    @State private var image: UIImage?
    
    private let degrees: Double = 90
    
    init(themeViewModel: ThemeViewModel,
         viewModel: DeclarationViewModel) {
        self.themeViewModel  = themeViewModel
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    var body: some View {
        GeometryReader { geometry in
            
            TabView {
                ForEach(viewModel.declarations) { declaration in
                    ZStack {
    
                        quoteLabel(declaration, geometry)
                        .padding()
                        .rotationEffect(Angle(degrees: -degrees))
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                    
                        .sheet(isPresented: $showShareSheet) {
                            if let image = image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                        }
                            ShareSheet(activityItems: [image, "\(declaration.text) \nSpeakLife App: \(APP.Product.urlID)"])
                        }
                        
                        if !showShareSheet {
                            VStack {
                                Spacer()
                                intentStackButtons(declaration: declaration)
                                Spacer()
                                    .frame(height: horizontalSizeClass == .compact ? geometry.size.height * 0.15 : geometry.size.height * 0.30)
                            }
                            .rotationEffect(Angle(degrees: -degrees))
                        }
                        
                        if isFavorite {
                            
                            withAnimation {
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
                }
            }
            .frame(width: geometry.size.height, height: geometry.size.width)
            .rotationEffect(.degrees(90), anchor: .topLeading)
            .offset(x: geometry.size.width)
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.showShareSheet = false
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
                .font(.callout)
                .shadow(color: .black, radius: themeViewModel.selectedTheme.blurEffect ? 10 : 0)
            
            Spacer()
        }.onAppear {
            Analytics.logEvent(Event.swipe_affirmation, parameters: nil)
        }
    }
    
    
    private func intentStackButtons(declaration: Declaration) -> some View  {
        HStack(spacing: 24) {

            CapsuleImageButton(title: "tray.and.arrow.up") {
                image = UIApplication.shared.windows.first?.rootViewController?.view.toImage()
                self.showShareSheet = true
                Analytics.logEvent(Event.shareTapped, parameters: nil)
                Selection.shared.selectionFeedback()
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

    
    private func favorite(_ declaration: Declaration) {
        viewModel.favorite(declaration: declaration)
        
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
