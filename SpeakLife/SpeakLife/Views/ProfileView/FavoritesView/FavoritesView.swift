//
//  FavoritesView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/26/22.
//

import SwiftUI

struct ContentRow: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showShareSheet = false
    var isEditable: Bool
    var declaration: Declaration
    var callback: ((String, _ delete: Bool) -> Void)?
    
    init(_ favorite: Declaration, isEditable: Bool = false, callback: ((String, Bool) -> Void)? = nil) {
        self.declaration = favorite
        self.isEditable = isEditable
        self.callback = callback
    }
    
    var body: some View {
        HStack {
            Text(declaration.text)
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 20))
               // .lineLimit(2)
            Spacer()
            
            Image(systemName: "ellipsis.circle.fill")
                .contextMenu {
                    Button(action: share) {
                        Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up.fill")
                    }
                    
                    
                    if isEditable {
                        Button {
                            edit(declaration.text)
                        } label: {
                            Label(LocalizedStringKey("Edit"), systemImage: "pencil.circle.fill")
                        }
                    }
                    
                    Button {
                        delete(declaration.text)
                    } label: {
                        Label(LocalizedStringKey("Delete"), systemImage: "delete.backward.fill")
                    }
                }
                .sheet(isPresented: $showShareSheet, content: {
                    ShareSheet(activityItems: ["\(declaration.text) \nSpeakLife App:", APP.Product.urlID])
                })
                .foregroundColor(colorScheme  == .dark ? .white : Constants.DAMidBlue)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    self.showShareSheet = false
                }
        }
        .padding()
    }
    
    func delete(_ declaration: String, delete: Bool = true) {
        callback?(declaration, delete)
    }
    
    private func share() {
        showShareSheet = true
    }
    
    func edit(_ declaration: String) {
        callback?(declaration, false)
    }
}

struct FavoritesView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showingOptions = false
    
    
    var body: some View {
        configureView()
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .navigationBarTitle(Text(LocalizedStringKey("Favorites")))
        
    }
    
    @ViewBuilder
    func configureView() -> some View  {
        if declarationStore.favorites.isEmpty {
            VStack {
                
                Image(systemName: "heart.text.square")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Constants.DAMidBlue)
                
                Spacer()
                    .background(Color.clear)
                    .frame(height: 16)
                
                Text("You have no declarations favorited.", comment: "no declarations favorited")
                    .font(.callout)
                    .lineLimit(nil)
                
                
                
            }.padding()
            
        } else {
            Spacer()
                .background(Color.clear)
                .frame(height: 16)
            List {
                ForEach(declarationStore.favorites) { favorite in
                    ContentRow(favorite)
                        .onTapGesture {
                            withAnimation {
                                declarationStore.choose(favorite)
                                popToRoot()
                            }
                            
                        }
                }
                .onDelete { offsets in
                    declarationStore.removeFavorite(at: offsets)
                }
            }
            .onAppear()  {
                loadFavorites()
            }
        }
    }
    
    private func popToRoot()  {
        appState.rootViewId = UUID()
    }
    
    
    private func loadFavorites() {
        declarationStore.refreshFavorites()
    }
}



struct FavoritesView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        FavoritesView()
            .environmentObject(DeclarationViewModel(apiService: APIClient()))
    }
}

