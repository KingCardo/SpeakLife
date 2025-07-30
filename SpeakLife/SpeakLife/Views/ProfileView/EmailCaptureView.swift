//
//  EmailCaptureView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 6/27/25.
//

import SwiftUI
import FirebaseFirestore

struct EmailCaptureView: View {
    @EnvironmentObject var appState: AppState
    @State private var email: String = ""
    @State private var message: String?
    @State private var isSubmitting: Bool = false
    @State private var showSuccess: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Join Our Weekly Emails")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Be the first to receive weekly encouragement, Scripture insights, and app updates.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Enter your email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .autocapitalization(.none)
            
            Button(action: submitEmail) {
                if isSubmitting {
                    ProgressView()
                } else {
                    Text("Subscribe")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isSubmitting || email.isEmpty)
            
            
            if let message = message {
                Text(message)
                    .foregroundColor(.green)
                    .font(.footnote)
            }
            if showSuccess {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .animation(.easeInOut, value: showSuccess)
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && isValidEmail(email)
    }
    
    private func submitEmail() {
        guard isValidEmail(email) else {
            withAnimation {
                message = "Please enter a valid email."
                showSuccess = false
            }
            return
        }
        isSubmitting = true
        message = nil
        
        let db = Firestore.firestore()
        let collection = db.collection("email_list")
        // Check for duplicate email
        collection.whereField("email", isEqualTo: email.lowercased())
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error checking duplicates: \(error.localizedDescription)")
                        withAnimation {
                            message = "Something went wrong. Please try again."
                            showSuccess = false
                            isSubmitting = false
                        }
                        return
                    }
                    
                    if let docs = snapshot?.documents, !docs.isEmpty {
                        withAnimation {
                            message = "You're already subscribed! ✅"
                            showSuccess = true
                            isSubmitting = false
                        }
                        return
                    }
                    
                    // No duplicate, add email
                    collection.addDocument(data: [
                        "email": email.lowercased(),
                        "timestamp": Timestamp(date: Date())
                    ]) { error in
                        DispatchQueue.main.async {
                            isSubmitting = false
                            if let error = error {
                                print("Error saving email: \(error.localizedDescription)")
                                withAnimation {
                                    message = "Something went wrong. Please try again."
                                    showSuccess = false
                                }
                            } else {
                                withAnimation {
                                    showSuccess = true
                                    message = "You're subscribed! 🎉"
                                    appState.email = email
                                    email = ""
                                    appState.needEmail = false
                                }
                            }
                        }
                    }
                }
            }
    }
        
        private func isValidEmail(_ email: String) -> Bool {
            let pattern = #"^\S+@\S+\.\S+$"#
            return email.range(of: pattern, options: .regularExpression) != nil
        }
    }
