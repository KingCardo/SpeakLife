//
//  ProfileView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/16/22.
//

import SwiftUI
import MessageUI
import FirebaseAnalytics

struct LazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}

struct ProfileView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var appState: AppState
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    private let appVersion = "App version: \(APP.Version.stringNumber)"
    
    // MARK: - Properties
    
    @State var isPresentingManageSubscriptionView = false
    @State var isPresentingContentView = false
    
    
    init() {
        Analytics.logEvent(Event.profileTapped, parameters: nil)
    }
    
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
                            List {
            Section(header: Text("Premium".uppercased()).font(.caption)) {
                subscriptionRow
                bookLink
            }
            
            Section(header: Text("Yours").font(.caption)) {
//                HStack {
//                    trackerRow
//                    if appState.newTrackerAdded {
//                        Badge()
//                    }
//                }
                
                HStack {
                    AbbasLoveRow
                    if appState.abbasLoveAdded {
                        Badge()
                    }
                }
                
                HStack {
                    tipsRow
                    if appState.newSettingsAdded {
                        Badge()
                    }
                }
                prayerRow
                remindersRow
                favoritesRow
                createYourOwnRow
            }
            
            Section(header: Text("SUPPORT").font(.caption)) {
                followUs
                shareRow
                reviewRow
                feedbackRow
            }
            
            Section(header: Text("Other".uppercased()).font(.caption)) {
                privacyPolicyRow
                termsConditionsRow
            }
            
            Section(footer: VStack {
                copyrightView
                Spacer()
                    .frame(height: 6)
                Text(appVersion).font(.caption2).font(.caption)
            }) {
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
            Analytics.logEvent(Event.manageSubscriptionTapped, parameters: nil)
        }
    }
    
    @MainActor
    private var remindersRow: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink("Reminder", destination: LazyView(ReminderView(reminderViewModel: ReminderViewModel())))
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
        // TO DO: - add back after add widget functionality
        EmptyView()
    }
    
    @MainActor
    private var prayerRow: some View {
        HStack {
            Image(systemName: "hands.sparkles.fill")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink(LocalizedStringKey("Prayers"), destination: LazyView(PrayerView()))
                .opacity(0)
                .background(
                    HStack {
                        Text("Prayer", comment:  "Prayers row title")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundColor(Constants.DAMidBlue)
                    })
        }
    }
    
    @MainActor
    private var tipsRow: some View {
        HStack {
            Image(systemName: "exclamationmark.shield.fill")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink(LocalizedStringKey("Tips to be Victorious"), destination: LazyView(TipsView(tips: tips)))
                .opacity(0)
                .background(
                    HStack {
                        Text("Tips on how to use SpeakLife", comment:  "Tips row title")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundColor(Constants.DAMidBlue)
                    })
        }
    }
    
    @MainActor
    private var AbbasLoveRow: some View {
        HStack {
            Image(systemName: "bolt.heart.fill")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink(LocalizedStringKey("Heavenly Father's Love"), destination: LazyView(AbbasLoveView()))
                .opacity(0)
                .background(
                    HStack {
                        Text("Father's Love Letter", comment:  "Love row title")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundColor(Constants.DAMidBlue)
                    })
        }
    }
    
    @MainActor
    private var favoritesRow: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink(LocalizedStringKey("Favorites"), destination: LazyView(FavoritesView()))
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
    
    @MainActor
    private var createYourOwnRow: some View {
        HStack {
            Image(systemName: "doc.fill.badge.plus")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink(LocalizedStringKey("Create Your Own"), destination: LazyView(CreateYourOwnView()))
                .opacity(0)
                .background(
                    HStack {
                        Text("My Own", comment: "create your own title")
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
        SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "square.and.arrow.up.fill", title: "Share SpeakLife", viewToPresent: EmptyView()) {
            shareApp()
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
    
    @MainActor
    private var trackerRow: some View {
        HStack {
            Image(systemName: "hourglass")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink(LocalizedStringKey("Tracker"), destination: LazyView(TrackerView()))
                .opacity(0)
                .background(
                    HStack {
                        Text("Meditation Tracker", comment:  "Prayers row title")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundColor(Constants.DAMidBlue)
                    })
        }
    }
    
    @MainActor
    @ViewBuilder
    private var feedbackRow: some View {
        if MFMailComposeViewController.canSendMail() {
            SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "square.grid.3x1.folder.fill.badge.plus", title: "Prayer Request", viewToPresent: LazyView(MailView(isShowing: $isPresentingContentView, result: self.$result, origin: .profile))) {
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
    
    @MainActor
    private var bookLink: some  View {
        HStack {
            Image(systemName:"book.fill")
                .foregroundColor(Constants.DAMidBlue)
            Link(destination: URL(string: "https://books.apple.com/us/book/100-days-of-power-declarations/id1616288315")!, label: {
                Text("100 Days of Power Declarations", comment: "")
            })
        }
    }
    private var copyrightView: some  View {
        Text("Scripture quotations marked (NLT) are taken from the Holy Bible, New Living Translation, copyright ©1996, 2004, 2015 by Tyndale House Foundation. Used by permission of Tyndale House Publishers, Carol Stream, Illinois 60188. All rights reserved.")
    }
    
    // MARK: - Private methods
    
    @MainActor
    private func presentContentView() {
        self.isPresentingContentView = true
    }
    
    private func shareApp() {
        guard let url = URL(string:  "\(APP.Product.urlID)")else { return }
        
        let activityVC = UIActivityViewController(activityItems: ["Check out SpeakLife - Bible Verses app that'll transform your life!", url], applicationActivities: nil)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.presentedViewController?.present(activityVC, animated: true)
    }
}

extension UIView {
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
}
