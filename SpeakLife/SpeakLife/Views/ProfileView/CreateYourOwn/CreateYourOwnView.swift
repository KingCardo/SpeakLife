//
//  CreateYourOwnView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 6/17/22.
//

import SwiftUI
import FirebaseAnalytics

struct CreateYourOwnView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showShareSheet = false
    @State private var showAlert = false
    @State private var alertText = ""
    
    
    var body: some View {
        ZStack {
            AnyView(Gradients().goldCyan)
            configureView()
            
            if showAlert {
                AffirmationAlertView(affirmationText: $alertText, showAlert: $showAlert) {
                    self.save()
                    declarationStore.requestReview.toggle()
                }
            }
        }
        .onAppear()  {
            loadCreateOwn()
            Analytics.logEvent(Event.createYourOwnTapped, parameters: nil)
        }
    }
    
    @ViewBuilder
    func configureView() -> some View {
        if declarationStore.createOwn.isEmpty {
            VStack {
                spacerView(32)
                    .background(Color.clear)
                
                Image(systemName: "doc.fill.badge.plus")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Constants.DAMidBlue)
                
                spacerView(16)
                
                Text("You haven't added any affirmations you would like to manifest.", comment: "add your own, none yet text")
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 20))
                    .lineLimit(nil)
                
                spacerView(32)
                
                addAffirmationsButton
                
            }.padding()
            
        } else {
                NavigationView {
                    List(declarationStore.createOwn) { declaration in
                        NavigationLink(destination: PrayerDetailView(declaration: declaration, isCreatedOwn: true) { Gradients().cyan }) {
                            ContentRow(declaration, isEditable: true) { declarationString, delete in
                                if delete {
                                    declarationStore.removeOwn(declaration: declaration)
                                } else {
                                    edit(declarationString)
                                }
                            }
                        }
                        
                        
                    }
                   
                    .navigationBarTitle("Affirmations")
                }
                VStack {
                    Spacer()
                    addAffirmationsButton
                        .padding()
                }
        }
    }

    
    private func edit(_ declaration: String) {
        alertText = declaration
        showAffirmationAlert()
        declarationStore.editMyOwn(declaration)
    }
    
    private func spacerView(_ height:  CGFloat)  -> some View  {
        Spacer()
            .frame(height: height)
    }
    
    private var addAffirmationsButton: some View {
        Button(action: showAffirmationAlert) {
            Text("Add an affirmation", comment: "add your own affirmation")
                .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                .foregroundColor(.white)
                .background(Constants.DAMidBlue)
                .cornerRadius(100)
            
        }
    }
    
    private func showAffirmationAlert() {
        withAnimation {
            showAlert.toggle()
        }
    }
    private func save() {
        declarationStore.createDeclaration(alertText)
        alertText = ""
        Analytics.logEvent(Event.addYourOwnSaved, parameters: nil)
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
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.layer.cornerRadius = 4
        textView.font = UIFont(name: "HelveticaNeue", size: 20)
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


struct AffirmationAlertView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var affirmationText: String
    @Binding var showAlert: Bool
    @State var closure: (() -> Void)?
    
    private var disabled: Bool {
        affirmationText.count < 3
    }
    
    var body: some View {
        ZStack {
            Gradients().cyanGold
                .edgesIgnoringSafeArea(.all)
            
            // Alert card
            VStack(spacing: 20) {
                Text("Add an Affirmation")
                    .font(.system(size: 24, weight: .semibold)) // Custom font size and weight
                    .foregroundColor(Color(#colorLiteral(red: 0.255, green: 0.518, blue: 0.576, alpha: 1))) // Darker shade for contrast
                
                TextViewWrapper(text: $affirmationText)
                    .foregroundColor(.black)
                    .shadow(radius: 5)
                
                HStack(spacing: 10) {
        
                    Button(action: {
    
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(disabled ? Constants.DAMidBlue.opacity(0.2) : Constants.DAMidBlue)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .disabled(disabled)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3)) // A lighter background for the cancel button
                    .foregroundColor(Color.black) // Dark text for contrast
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding()
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(20)
        }
    }
    
//    private func dismissX() {
//        withAnimation {
//            showAlert.toggle()
//        }
//    }
    
    private func dismiss() {
        withAnimation {
            showAlert.toggle()
        }
        closure?()
    }
}
