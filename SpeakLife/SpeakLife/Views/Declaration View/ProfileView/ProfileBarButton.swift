//
//  ProfileBarView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/2/22.
//

import SwiftUI


struct ProfileBarButton: View {
    
    // MARK: - Properties
    
    @State private var isPresentingProfileView = false
    
    
    var body: some View {
        
        HStack {
            Spacer()
            CapsuleImageButton(title: "person.crop.circle") {
                profileButtonTapped()
            }.sheet(isPresented: $isPresentingProfileView, onDismiss: {
                self.isPresentingProfileView = false
            }, content: {
                ProfileView()
            })
            .foregroundColor(.white)
            
            
        }.padding()
    }
    
    // MARK: - Intent(s)
    
    private func profileButtonTapped() {
        self.isPresentingProfileView = true
    }
}

struct ProfileBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileBarButton()
    }
}

