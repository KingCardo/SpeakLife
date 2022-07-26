//
//  ProfileView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/16/22.
//

import SwiftUI
import MessageUI

struct ProfileView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    private let appVersion = "App version: \(APP.Version.stringNumber)"
    
    
    // MARK: - Properties
    
    @State var isPresentingContentView: Bool = false
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Premium".uppercased())
                        .font(.caption)
                    subscriptionRow
                    
                }
                Section {
                    Text("SETTINGS")
                        .font(.caption)
                    remindersRow
                    
                    //widgetsRow
                    favoritesRow
                    
                    createYourOwnRow
                }
                
                
                Section {
                    Text("SUPPORT")
                        .font(.caption)
                    
                    shareRow
                    
                    reviewRow
                    
                    feedbackRow
                    
                }
                
                Section {
                    Text("Other".uppercased())
                        .font(.caption)
                    
                    privacyPolicyRow
                    termsConditionsRow
                    
                }
                
                Section {
                    Text(appVersion)
                        .font(.caption)
                }
            }
            
            .foregroundColor(colorScheme == .dark ? .white : .black)
            
            .navigationBarTitle(Text("Revamp"))
            
        }
    }
    
    
    private var subscriptionRow:  some View {
        SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "crown.fill", title: "Manage Subscription", viewToPresent: PremiumView()) {
            presentContentView()
        }
    }
    
    private var remindersRow: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink("Reminders", destination: ReminderView(reminderViewModel: ReminderViewModel()))
                .opacity(0)
                .background(
                    HStack {
                        Text("Reminders", comment: "Reminder row title")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundColor(Constants.DAMidBlue)
                    })
        }
    }
    
    
    private var widgetsRow: some View {
        //TO DO: - add back after add widget functionality
        SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "square.split.2x2.fill", title: "Widgets", viewToPresent: PremiumView()) {
           
        }
    }
    
    private var favoritesRow: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink(LocalizedStringKey("Favorites"), destination: FavoritesView())
                .opacity(0)
                .background(
                    HStack {
                        Text("Favorites", comment:  "Favorites row title")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundColor(Constants.DAMidBlue)
                    })
        }
    }
    
    private var createYourOwnRow: some View {
        HStack {
            Image(systemName: "doc.fill.badge.plus")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink(LocalizedStringKey("Create Your Own"), destination: CreateYourOwnView())
                .opacity(0)
                .background(
                    HStack {
                        Text("Create Your Own", comment: "create your own title")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundColor(Constants.DAMidBlue)
                    })
        }
    }
    
    private var shareRow: some View {
        SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "square.and.arrow.up.fill", title: "Share Revamp", viewToPresent: EmptyView()) {
            shareApp()
        }
    }
    
    private var reviewRow: some View  {
        SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "star.bubble.fill", title: "Leave us a Review", viewToPresent: EmptyView(), url: "\(APP.Product.urlID)?action=write-review") {
        }
    }
    
    @ViewBuilder
    private var feedbackRow: some View {
        if MFMailComposeViewController.canSendMail() {
            SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "square.grid.3x1.folder.fill.badge.plus", title: "Report Feedback", viewToPresent: MailView(isShowing: $isPresentingContentView, result: self.$result)) {
                presentContentView()
            }
        }
    }
    
    private var privacyPolicyRow: some View {
        
        ZStack {
            Text("Privacy Policy", comment: "privacy policy")
            Link("", destination: URL(string: "https://www.revampdailyaffirmations.com/home")!)
        }
    }
    
    private var termsConditionsRow: some View {
        
        ZStack {
            Text("Terms and Conditions", comment: "terms n conditions")
            Link("", destination: URL(string: "https://www.revampdailyaffirmations.com/home")!)
        }
    }
    
    
    
    
    
    // MARK: - Private methods
    
    private func presentContentView() {
        self.isPresentingContentView = true
    }
    
    private func shareApp() {
        let string = LocalizedStringKey("Check out Revamp - Daily Affirmations app that'll transform your life!")
        let url = URL(string:  "\(APP.Product.urlID)")!
        
        let activityVC = UIActivityViewController(activityItems: [string, url], applicationActivities: nil)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.presentedViewController?.present(activityVC, animated: true)
    }
}
