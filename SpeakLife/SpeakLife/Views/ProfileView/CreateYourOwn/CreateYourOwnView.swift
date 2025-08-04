//
//  CreateYourOwnView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 6/17/22.
//

import SwiftUI
import FirebaseAnalytics

struct CreateYourOwnView: View {
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showShareSheet = false
    @State private var showFullScreenEntry = false
    @State private var editingDeclaration: Declaration?
    @State private var selectedDeclaration: Declaration?
    @State private var animate = false
    @State private var selectedContentType: ContentType = .affirmation
    
    private var filteredDeclarations: [Declaration] {
        declarationStore.createOwn.filter { $0.contentType == selectedContentType }
    }
    
    private var emptyStateTitle: String {
        switch selectedContentType {
        case .affirmation:
            return "You're just one affirmation away\nfrom breakthrough."
        case .journal:
            return "Start your spiritual journey\nwith journaling."
        }
    }
    
    private var emptyStateSubtitle: String {
        switch selectedContentType {
        case .affirmation:
            return "Speak what God says. See what God promised."
        case .journal:
            return "Record God's faithfulness and your growth."
        }
    }
    
    var body: some View {
        ZStack {
            Image(subscriptionStore.onboardingBGImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.4))
                )
            
            configureView()
            
        }
        .fullScreenCover(isPresented: $showFullScreenEntry) {
            FullScreenEntryView(
                contentType: selectedContentType,
                existingText: editingDeclaration?.text ?? "",
                isEditing: editingDeclaration != nil
            )
            .environmentObject(declarationStore)
            .onDisappear {
                editingDeclaration = nil
                declarationStore.refreshCreateOwn()
                declarationStore.requestReview.toggle()
            }
        }
        .onAppear()  {
            loadCreateOwn()
            Analytics.logEvent(Event.createYourOwnTapped, parameters: nil)
        }
    }
    
    @ViewBuilder
    func configureView() -> some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom SLBlue Segmented Control - Always visible
                HStack(spacing: 0) {
                    ForEach(ContentType.allCases, id: \.self) { contentType in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedContentType = contentType
                            }
                        }) {
                            Text(contentType.pluralDisplayName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(selectedContentType == contentType ? .white : .white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedContentType == contentType ? 
                                              Constants.SLBlue.opacity(0.9) : 
                                              Color.clear)
                                )
                                .animation(.easeInOut(duration: 0.2), value: selectedContentType)
                        }
                    }
                }
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Constants.SLBlue.opacity(0.3))
                        .shadow(color: Constants.SLBlue.opacity(0.2), radius: 2, x: 0, y: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // Content Area - conditionally show empty state or list
                if filteredDeclarations.isEmpty {
                    // Empty state for current tab
                    ZStack {
                        // Background gradient - same as list view
                        Gradients().speakLifeCYOCell
                            .ignoresSafeArea()
                        
                        VStack(spacing: 32) {
                            Spacer()
                                .frame(height: 40)
                            
                            ZStack {
                                Circle()
                                    .fill(Constants.DAMidBlue.opacity(0.15))
                                    .frame(width: 170, height: 170)
                                    .scaleEffect(animate ? 1.1 : 1)
                                    .opacity(animate ? 0.8 : 0.3)
                                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: animate)
                                
                                AppLogo(height: 100)
                            }
                            
                            VStack(spacing: 8) {
                                Text(emptyStateTitle)
                                    .font(.system(size: 20, weight: .semibold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .animation(.easeInOut(duration: 0.3), value: selectedContentType)
                                
                                Text(emptyStateSubtitle)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(0.8))
                                    .animation(.easeInOut(duration: 0.3), value: selectedContentType)
                            }
                            .padding(.horizontal)
                            
                            addAffirmationsButton
                            
                            Spacer()
                        }
                        .onAppear {
                            animate = true
                        }
                    }
                } else {
                    // List view for current tab
                    ZStack {
                        // Background gradient
                        Gradients().speakLifeCYOCell
                            .ignoresSafeArea()
                        
                        // Main List with transparent background
                        List {
                            ForEach(filteredDeclarations.reversed()) { declaration in
                                ContentRow(declaration, isEditable: true) { declarationString, delete in
                                    if delete {
                                        declarationStore.removeOwn(declaration: declaration)
                                    } else {
                                        editingDeclaration = declaration
                                        showFullScreenEntry = true
                                    }
                                } onSelect: {
                                    selectedDeclaration = declaration
                                }
                                .listRowBackground(Color.clear)
                            }
                            .onDelete { indexSet in
                                let reversed = declarationStore.createOwn.reversed()
                                for index in indexSet {
                                    let itemToDelete = Array(reversed)[index]
                                    declarationStore.removeOwn(declaration: itemToDelete)
                                }
                            }
                            Section {
                                HStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        AppLogo(height: 80)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .padding(.top, 12)
                                .padding(.bottom, 40)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        
                        // NavigationLink hidden trigger
                        NavigationLink(
                            destination:
                                AffirmationDetailView(affirmation: selectedDeclaration ?? declarationStore.createOwn.first!),
                            isActive: Binding(
                                get: { selectedDeclaration != nil },
                                set: { if !$0 { selectedDeclaration = nil } }
                            )
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    }
                }
            } // Close VStack
            .navigationTitle(selectedContentType.pluralDisplayName)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !filteredDeclarations.isEmpty {
                        Button(action: {
                            showFullScreenEntry = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .frame(width: 30, height: 30)
                                .foregroundColor(Constants.navBlue)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Constants.SLBlue.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    
    
    private func edit(_ declaration: String) {
        // This method is no longer used - editing is handled through the full-screen view
    }
    
    private func spacerView(_ height:  CGFloat)  -> some View  {
        Spacer()
            .frame(height: height)
    }
    
    private var addAffirmationsButton: some View {
        Button(action: {
            showFullScreenEntry = true
        }) {
            Text("Create your own")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Constants.DAMidBlue)
                .cornerRadius(14)
                .shadow(color: Constants.DAMidBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                .scaleEffect(1.02)
        }
        .padding(.horizontal, 32)
    }
    
    
    private func popToRoot()  {
        appState.rootViewId = UUID()
    }
    
    private func loadCreateOwn()  {
        declarationStore.refreshCreateOwn()
    }
}

struct TextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewWrapper
        
        init(_ parent: TextViewWrapper) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
    
    func makeUIView(context: Context) -> UITextView {
        let font = UIFont.systemFont(ofSize: 20, weight: .medium)
        let roundedFont = UIFont(descriptor: font.fontDescriptor.withDesign(.rounded)!, size: 20)
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.layer.cornerRadius = 4
        textView.font = roundedFont
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}

struct CreateYourOwnView_Previews: PreviewProvider {
    static var previews: some View {
        CreateYourOwnView()
            .environmentObject(DeclarationViewModel(apiService: LocalAPIClient()))
            .environmentObject(AppState())
        
    }
}



struct AffirmationDetailView: View {
    let affirmation: Declaration // Replace with your model
    
    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var timer: Timer?
    @State var animateGlow = false
    @State private var showCursor = true
    @State private var showCreateYourOwn = false
    
    
    var body: some View {
            ZStack() {
                // Background
                Gradients().speakLifeCYOCell
                    .ignoresSafeArea()
                
                // Pulsing Glow
                Circle()
                    .fill(Constants.DAMidBlue.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .blur(radius: 40)
                    .scaleEffect(animateGlow ? 1.05 : 1)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateGlow)
                    .offset(y: -100)
                
                // Content
                VStack(spacing: 20) {
                    
                    Text(affirmation.lastEdit?.toPrettyString() ?? "")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                        .padding(.top, 40)
                    
                    if showCreateYourOwn {
                        Text("Create Your Own")
                            .foregroundColor(Color.gray)
                            .font(.title3)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    ZStack(alignment: .topLeading) {
                       
                        if showCursor {
                            VStack {
                            Text(displayedText + "|")
                                .font(.system(size: dynamicFontSize, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(0.9)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                        .shadow(color: Color.white.opacity(0.1), radius: 6)
                                )
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showCursor)
                            Spacer()
                                .frame(height: UIScreen.main.bounds.height * 0.1)
                            AppLogo(height: 80)
                        }
                        } else {
                            VStack {
                                Text(displayedText)
                                    .font(.system(size: dynamicFontSize, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(12)
                                Spacer()
                                    .frame(height: UIScreen.main.bounds.height * 0.1)
                                AppLogo(height: 80)
                            }
                        }
                    }
                    Spacer()
                }
            }

        .onAppear {
            timer?.invalidate()
            displayedText = ""
            showCursor = true
            startTypingAnimation()
            animateGlow = true
            showCreateYourOwn = true
        }
    }
    
    private func startTypingAnimation() {
        let affirmation = affirmation.text
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard displayedText.count < affirmation.count else {
                timer?.invalidate()
                timer = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { showCursor = false }
                }
                return
            }
            
            let nextChar = affirmation[affirmation.index(affirmation.startIndex, offsetBy: displayedText.count)]
            displayedText.append(nextChar)
        }
    }
    
    private var dynamicFontSize: CGFloat {
        switch affirmation.text.count {
        case 0..<100: return 32
        case 100..<160: return 28
        default: return 24
        }
    }
    
    private func textWidth(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: dynamicFontSize, weight: .bold)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width
    }
}