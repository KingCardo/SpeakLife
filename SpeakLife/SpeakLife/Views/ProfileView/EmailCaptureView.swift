//
//  EmailCaptureView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 6/27/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAnalytics

struct EmailCaptureView: View {
    @EnvironmentObject var appState: AppState
    @State private var email: String = ""
    @State private var message: String?
    @State private var isSubmitting: Bool = false
    @State private var showSuccess: Bool = false
    @State private var showAdvancedOptions: Bool = false
    
    private let emailService = EmailMarketingService.shared
    
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
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Provide specific error messages
        if trimmedEmail.isEmpty {
            withAnimation {
                message = "Please enter your email address"
                showSuccess = false
            }
            return
        }
        
        if !trimmedEmail.contains("@") {
            withAnimation {
                message = "Email must include @ symbol"
                showSuccess = false
            }
            return
        }
        
        if trimmedEmail.filter({ $0 == "@" }).count > 1 {
            withAnimation {
                message = "Email can only have one @ symbol"
                showSuccess = false
            }
            return
        }
        
        if !trimmedEmail.contains(".") || trimmedEmail.hasSuffix(".") {
            withAnimation {
                message = "Please include a valid domain (e.g., gmail.com)"
                showSuccess = false
            }
            return
        }
        
        guard isValidEmail(trimmedEmail) else {
            withAnimation {
                message = "Please enter a valid email address (e.g., name@example.com)"
                showSuccess = false
            }
            Analytics.logEvent("email_signup_invalid", parameters: [
                "source": "ios_app_profile"
            ])
            return
        }
        isSubmitting = true
        message = nil
        
        // Log attempt
        Analytics.logEvent("email_signup_attempt", parameters: [
            "source": "ios_app_profile"
        ])
        
        Task {
            do {
                // Add to email marketing service (Mailchimp, etc.) and Firebase
                try await emailService.addSubscriber(
                    email: trimmedEmail,
                    firstName: nil,
                    source: "ios_app_profile"
                )
                
                // Log success
                Analytics.logEvent("email_signup_success", parameters: [
                    "source": "ios_app_profile"
                ])
                
                await MainActor.run {
                    withAnimation {
                        showSuccess = true
                        message = "You're subscribed! 🎉 Check your email for confirmation."
                        appState.email = email
                        appState.needEmail = false
                        
                        // Clear form after successful submission
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            email = ""
                        }
                    }
                    isSubmitting = false
                }
            } catch {
                // Log failure
                Analytics.logEvent("email_signup_failed", parameters: [
                    "source": "ios_app_profile",
                    "error": error.localizedDescription
                ])
                
                await MainActor.run {
                    withAnimation {
                        if error.localizedDescription.contains("already") {
                            message = "You're already subscribed! ✅"
                            showSuccess = true
                        } else {
                            message = "Error: \(error.localizedDescription)"
                            showSuccess = false
                        }
                    }
                    isSubmitting = false
                }
                print("❌ Error subscribing email: \(error)")
                print("Error details: \(error.localizedDescription)")
            }
        }
    }
        
        private func isValidEmail(_ email: String) -> Bool {
            // More robust email validation
            let pattern = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
            let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check basic requirements
            guard !trimmed.isEmpty,
                  trimmed.count >= 5, // Minimum: a@b.c
                  trimmed.count <= 254, // RFC 5321 max email length
                  !trimmed.hasPrefix("."),
                  !trimmed.hasSuffix("."),
                  !trimmed.contains(".."),
                  trimmed.filter({ $0 == "@" }).count == 1 else {
                return false
            }
            
            return trimmed.range(of: pattern, options: .regularExpression) != nil
        }
    }
