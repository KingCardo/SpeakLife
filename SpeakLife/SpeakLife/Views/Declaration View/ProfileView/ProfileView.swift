//
//  ProfileView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/16/22.
//

import SwiftUI
import MessageUI
import FirebaseAnalytics

struct ProfileView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    private let appVersion = "App version: \(APP.Version.stringNumber)"
    
    
    // MARK: - Properties
    
    @State var isPresentingManageSubscriptionView = false
    @State var isPresentingContentView = false
    
    @ViewBuilder
    private func navigationStack<Content: View>(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                content
            }
        } else {
            NavigationView {
                content
            }
        }
    }
    
    private var profileView: some View {
        navigationStack(content:
                            Form {
            Section {
                Text("Premium".uppercased())
                    .font(.caption)
                subscriptionRow
                bookLink
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
                
                followUs
                
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
                copyrightView
                
                Text(appVersion)
                    .font(.caption2)
                    .font(.caption)
            }
        }
                        
            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
            .navigationBarTitle(Text("SpeakLife"))
        )
    }
    
    
    var body: some View {
        profileView
            .onAppear {
                Analytics.logEvent(Event.profileTapped, parameters: nil)
            }
    }
    
    
    private var subscriptionRow:  some View {
        SettingsRow(isPresentingContentView: $isPresentingManageSubscriptionView, imageTitle: "crown.fill", title: "Manage Subscription", viewToPresent: PremiumView()) {
            isPresentingManageSubscriptionView.toggle()
        }.onAppear {
            Analytics.logEvent(Event.manageSubscriptionTapped, parameters: nil)
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
        }.onAppear {
            Analytics.logEvent(Event.remindersTapped, parameters: nil)
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
        }.onAppear {
            Analytics.logEvent(Event.createYourOwnTapped, parameters: nil)
        }
    }
    
    private var shareRow: some View {
        SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "square.and.arrow.up.fill", title: "Share SpeakLife", viewToPresent: EmptyView()) {
            shareApp()
        }.onAppear {
            Analytics.logEvent(Event.shareSpeakLifeTapped, parameters: nil)
        }
    }
    
    private var followUs: some View {
        SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "flame.fill", title: "Follow us on Instagram", viewToPresent: EmptyView(), url: APP.Product.instagramURL) {
        }
    }
    
    private var reviewRow: some View  {
        SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "star.bubble.fill", title: "Leave us a Review", viewToPresent: EmptyView(), url: "\(APP.Product.urlID)?action=write-review") {
        }
    }
    
    @ViewBuilder
    private var feedbackRow: some View {
        if MFMailComposeViewController.canSendMail() {
            SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "square.grid.3x1.folder.fill.badge.plus", title: "Suggest New Categories - Feedback", viewToPresent: MailView(isShowing: $isPresentingContentView, result: self.$result)) {
                presentContentView()
            }
        }
    }
    
    private var privacyPolicyRow: some View {
        
        ZStack {
            Text("Privacy Policy", comment: "privacy policy")
            Link("", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        }
    }
    
    private var termsConditionsRow: some View {
        
        ZStack {
            Text("Terms and Conditions", comment: "terms n conditions")
            Link("", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        }
    }
    
    private var bookLink: some  View {
        ZStack {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(Constants.DAMidBlue)
                Text("100 Days of Power Declarations", comment: "")
            }
            Link("", destination: URL(string: "https://books.apple.com/us/book/100-days-of-power-declarations/id1616288315")!)
        }.onAppear {
            Analytics.logEvent(Event.powerDeclarationsTapped, parameters: nil)
        }
    }
    
    private var copyrightView: some  View {
        Text("Scripture quotations marked (NLT) are taken from the Holy Bible, New Living Translation, copyright ©1996, 2004, 2015 by Tyndale House Foundation. Used by permission of Tyndale House Publishers, Carol Stream, Illinois 60188. All rights reserved.")
    }
    
    
    
    
    
    // MARK: - Private methods
    
    private func presentContentView() {
        self.isPresentingContentView = true
    }
    
    private func shareApp() {
        let string = LocalizedStringKey("Check out SpeakLife - Daily Bible Promises app that'll transform your life!")
        let url = URL(string:  "\(APP.Product.urlID)")!
        
        let activityVC = UIActivityViewController(activityItems: [string, url], applicationActivities: nil)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.presentedViewController?.present(activityVC, animated: true)
    }
}
