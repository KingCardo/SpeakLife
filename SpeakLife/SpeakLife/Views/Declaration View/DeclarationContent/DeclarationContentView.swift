//
//  DeclarationContentView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/4/22.
//

import SwiftUI


struct DeclarationContentView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var themeViewModel: ThemeViewModel
    @ObservedObject var viewModel: DeclarationViewModel
    @State private var isFavorite: Bool = false
    @State private var showShareSheet = false
    
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
                            ShareSheet(activityItems: ["\(declaration.text) \nSpeakLife App: \(APP.Product.urlID)"])
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
        
    }
    
    
    private func quoteLabel(_ declaration: Declaration, _ geometry: GeometryProxy) -> some View  {
        VStack {
            Spacer()
            
            QuoteLabel(themeViewModel: themeViewModel, quote: declaration.text)
                .frame(width: geometry.size.width * 0.98, height:  geometry.size.height * 0.40)
                .shadow(color: .black, radius: themeViewModel.selectedTheme.blurEffect ? 10 : 0)
            
            Text(declaration.book)
                .foregroundColor(.white)
                .font(.callout)
                .shadow(color: .black, radius: themeViewModel.selectedTheme.blurEffect ? 10 : 0)
//            QuoteLabel(themeViewModel: themeViewModel, quote: declaration.book)
//                .shadow(color: .black, radius: themeViewModel.selectedTheme.blurEffect ? 10 : 0)
            
            Spacer()
        }
    }
    
    
    private func intentStackButtons(declaration: Declaration) -> some View  {
        HStack(spacing: 24) {

            CapsuleImageButton(title: "tray.and.arrow.up") {
                Selection.shared.selectionFeedback()
                self.showShareSheet = true
                //share(declaration)
            }
            
            CapsuleImageButton(title: declaration.isFavorite ? "heart.fill" : "heart") {
                Selection.shared.selectionFeedback()
                favorite(declaration)
                self.isFavorite = declaration.isFavorite ? false : true
            }

        }
        .foregroundColor(.white)
    }
    
    // MARK: - Intent(s)
    
    
    //  MARK: - TO DO - fix with uiViewControllerRepresentable
//    private func share(_  declaration: Declaration) {
//        let activityVC = UIActivityViewController(activityItems: [declaration.text as NSString, "\nRevamp App: https://www.apple.com"], applicationActivities: nil)
//        let scenes = UIApplication.shared.connectedScenes
//        let windowScene = scenes.first  as? UIWindowScene
//        let window = windowScene?.windows.first
//        window?.rootViewController?.present(activityVC, animated: true, completion: nil)
//    }
    
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
