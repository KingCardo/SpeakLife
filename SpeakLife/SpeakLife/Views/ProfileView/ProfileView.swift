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
    @EnvironmentObject var streakViewModel: StreakViewModel
    @EnvironmentObject var appState: AppState
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    private let appVersion = "App version: \(APP.Version.stringNumber)"
    
    // MARK: - Properties
    
    @State var isPresentingManageSubscriptionView = false
    @State var isPresentingContentView = false
    @State var isPresentingBottomSheet = false
    @State private var showShareSheet = false
    let url = URL(string:APP.Product.urlID)
    
    
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
                streakRow
    
                HStack {
                    AbbasLoveRow
                    if appState.abbasLoveAdded {
                        Badge()
                    }
                }
               // createYourOwnRow
            
                remindersRow
                favoritesRow
                soundsRow
            }
            
            Section(header: Text("SUPPORT").font(.caption)) {
                shareRow
                reviewRow
                feedbackRow
              //  prayerRow
                //newFeaturesRow
            }
            .sheet(isPresented: $showShareSheet, content: {
                ShareSheet(activityItems: ["Check out SpeakLife - Bible Affirmations app that'll transform your life!", url])
            })
            
            Section(header: Text("Other".uppercased()).font(.caption)) {
                privacyPolicyRow
                termsConditionsRow
            }
            
            Section(footer: VStack {
                Text(appVersion).font(.footnote)//.font(.caption)
            }) {
            }
        }
            .onChange(of: declarationStore.backgroundMusicEnabled) { newValue in
            if newValue {
                AudioPlayerService.shared.playSound(files: resources)
            } else {
                AudioPlayerService.shared.pauseMusic()
            }
        }
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .navigationBarTitle(Text("SpeakLife"))
        )
        .alert(isPresented: $declarationStore.errorAlert) {
            Alert(
                title: Text("Error", comment: "notifications not enough"),
                message: Text("Failed to register notifications", comment: "go to settings"),
                dismissButton: .default(Text("Try again", comment: "settings alert"), action: {})
            )
        }
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
    
//    @MainActor
//    private var prayerRow: some View {
//        HStack {
//            Image(systemName: "hands.sparkles.fill")
//                .foregroundColor(Constants.DAMidBlue)
//            NavigationLink(LocalizedStringKey("Prayers"), destination: LazyView(PrayerView()))
//                .opacity(0)
//                .background(
//                    HStack {
//                        Text("Prayer", comment:  "Prayers row title")
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 8)
//                            .foregroundColor(Constants.DAMidBlue)
//                    })
//        }
//    }
    
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
    private var streakRow: some View {
        ZStack {
            Button("") {
                isPresentingBottomSheet = true
            }
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(Constants.DAMidBlue)
                
                Text("Streak")
                
            }
        }.sheet(isPresented: $isPresentingBottomSheet) {
            StreakSheet(isShown: $isPresentingBottomSheet, streakViewModel: streakViewModel)
                .presentationDetents([.medium, .fraction(0.4)])
                .preferredColorScheme(.light)
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
            SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "square.grid.3x1.folder.fill.badge.plus", title: "Report an issue", viewToPresent: LazyView(MailView(isShowing: $isPresentingContentView, result: self.$result, origin: .review))) {
                presentContentView()
            }
        }
    }
    
//    @MainActor
//    @ViewBuilder
//    private var prayerRow: some View {
//        if MFMailComposeViewController.canSendMail() {
//            SettingsRow(isPresentingContentView: $isPresentingContentView, imageTitle: "highlighter", title: "Prayer Request", viewToPresent: LazyView(MailView(isShowing: $isPresentingContentView, result: self.$result, origin: .profile))) {
//                presentContentView()
//            }
//        }
//    }
    
    private var warriorView: some View {
        HStack {
            Image(systemName: "bolt.shield.fill")
                .foregroundColor(Constants.DAMidBlue)
            NavigationLink(LocalizedStringKey("WarriorView"), destination: LazyView(WarriorView()))
              //  .navigationBarTitle("Warrior's Prayer", displayMode: .inline)
                .opacity(0)
                .background(
                    HStack {
                        Text("Warrior's Prayer", comment: "pp")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundColor(Constants.DAMidBlue)
                    })
        }
    }
    
    private var privacyPolicyRow: some View {
        NavigationLink(LocalizedStringKey("Privay Policy"), destination: LazyView(PrivacyPolicyView()))
            .opacity(0)
            .background(
                HStack {
                    Text("Privacy Policy", comment: "pp")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 8)
                        .foregroundColor(Constants.DAMidBlue)
                })
    }
    
    private var termsConditionsRow: some View {
        ZStack {
            Text("Terms and Conditions", comment: "terms n conditions")
            Link("", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        }
    }
    
    private var soundsRow: some View {
        ZStack {
            HStack {
                Text("Background Music", comment: "terms n conditions")
                Spacer()
                Toggle("", isOn: declarationStore.$backgroundMusicEnabled)
                        .padding()
            }
        
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
        showShareSheet.toggle()
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

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Privacy Policy for SpeakLife: Bible Affirmations")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Last Updated: 12-05-2023")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Welcome to SpeakLife ('we', 'us', 'our'). We are committed to protecting your privacy. This Privacy Policy explains how we handle and treat your data when you use SpeakLife: Bible Affirmations ('App')")
                    .font(.body)
                
                Text("1. Information We Collect")
                    .font(.subheadline)
                Text("* As a policy, our App does not collect, store, or process any personal data from our users. We believe in your right to privacy and have designed our App accordingly.")
                    .font(.body)
                
                Text("2. Data Usage")
                    .font(.subheadline)
                Text("* Since we do not collect any personal data, there is no usage of such data.")
                    .font(.body)
                
                Text("3. Third-Party Services")
                    .font(.subheadline)
                Text("* The following data may be collected but is not linked to your identity: App Installs, product interaction.")
                    .font(.body)
                
                
                Text("4. Changes to Our Privacy Policy")
                    .font(.subheadline)
                Text("* We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the 'Last Updated' date.")
                    .font(.body)
                
                Text("5. Contact Us")
                    .font(.subheadline)
                Text("* If you have any questions about our Privacy Policy, please contact us at speaklife@diosesaqui.com.")
                    .font(.body)
                   
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}
