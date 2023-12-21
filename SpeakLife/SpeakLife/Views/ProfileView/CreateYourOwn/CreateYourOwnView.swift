//
//  CreateYourOwnView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 6/17/22.
//

import SwiftUI
import FirebaseAnalytics

struct AlertView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var shown: Bool
    @Binding var alertText: String
    @State var closure: (() -> Void)?
    private var disabled: Bool {
        alertText.count < 3
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: dismissX) {
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Constants.DAMidBlue)
                }
            }
            Text("Add an affirmation. These are private to you.", comment: "own affirmations alert")
                .font(.callout)
                .foregroundStyle(Constants.DAMidBlue)
                .multilineTextAlignment(.center)
            
            TextEditor(text: $alertText)
                .font(.custom("HelveticaNeue", size: 13))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .cornerRadius(10)
            
            Button(action: dismiss) {
                Text("Save", comment: "save")
                    .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .foregroundColor(.white)
                    .background(disabled ? Constants.DAMidBlue.opacity(0.2) : Constants.DAMidBlue)
                    .cornerRadius(100)
            }
            .disabled(disabled)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width-50, height: 300)
        
        .background(colorScheme == .dark ? .white : Constants.DEABlack)
        .cornerRadius(12)
        //.border(Constants.DAMidBlue)
        .clipped()
        
    }
    
    private func dismissX() {
        withAnimation {
            shown.toggle()
        }
    }
    
    private func dismiss() {
        withAnimation {
            shown.toggle()
        }
        closure?()
    }
}
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
              //  .foregroundColor(colorScheme == .dark ? .white : .black)
               // .navigationBarTitle(Text("Add your own affirmation", comment: "add your own title"))
               // .navigationBarTitleDisplayMode(.inline)
             //   .background(Color.clear)
            
            if showAlert {
                AlertView(shown: $showAlert, alertText: $alertText) {
                    self.save()
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
        if declarationStore.createOwn.isEmpty  {
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
                        NavigationLink(destination: PrayerDetailView(prayer: declaration.text)) {
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

struct CreateYourOwnView_Previews: PreviewProvider {
    static var previews: some View {
        CreateYourOwnView()
            .environmentObject(DeclarationViewModel(apiService: APIClient()))
            .environmentObject(AppState())
            
    }
}
