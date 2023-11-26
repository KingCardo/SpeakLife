//
//  HomeView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 12/17/22.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var themeStore: ThemeViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var devotionalViewModel: DevotionalViewModel
//    @State private var selectedTab = 0
//    @State private var isTabBarVisible = true
//    @State private var time = 0
//    @State private var tabOffset = CGSize.zero
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
        var body: some View {
            if appState.isOnboarded {
                TabView {
                    DeclarationView(viewModel: _declarationStore, themeViewModel: _themeStore)
                        .id(appState.rootViewId)
                        .tabItem {
                            Image(systemName: "house.fill")
                                .renderingMode(.original)
                            Text("Home")
                        }
    
                    DevotionalView(viewModel:devotionalViewModel)
                        .tabItem {
                            if #available(iOS 17, *) {
                                Image(systemName: "book.pages.fill")
                                    .renderingMode(.original)
                            } else {
                                Image(systemName: "book.fill")
                                    .renderingMode(.original)
                            }
                            Text("Devotionals")
                        }
                    
//                    PodcastsListView()
//                        .tabItem {
//                            Image(systemName: "headphones")
//                                .renderingMode(.original)
//                            Text("Listen")
//                        }
    
                    CreateYourOwnView()
                        .tabItem {
                            Image(systemName: "plus.bubble.fill")
                                .renderingMode(.original)
                            Text("Yours")
                        }
    
//                    NavigationStack {
//                        LazyView(PrayerView())
//                    }
//                        .tabItem {
//                            if #available(iOS 17, *) {
//                                Image(systemName: "hands.and.sparkles.fill")
//                                    .renderingMode(.original)
//                            } else {
//                                Image(systemName: "hands.clap.fill")
//                                    .renderingMode(.original)
//                            }
//                            Text("Prayers")
//                        }
    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "line.3.horizontal")
                                .renderingMode(.original)
                            Text("More")
                        }
                }
                .accentColor(Constants.DAMidBlue)
            } else {
                OnboardingView()
            }
        }
    
//    var body: some View {
//        if appState.isOnboarded {
//            ZStack(alignment: .bottom) {
//                // Content Views
//                Group {
//                    switch selectedTab {
//                    case 0:
//                        DeclarationView(viewModel: _declarationStore, themeViewModel: _themeStore)
//                    case 1:
//                        DevotionalView(viewModel:devotionalViewModel)
//                    case 2:
//                        CreateYourOwnView()
//                    case 3:
//                        ProfileView()
//                    default:
//                        DeclarationView(viewModel: _declarationStore, themeViewModel: _themeStore)
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .onTapGesture {
//                    withAnimation {
//                        tabOffset = tabOffset == .zero ? CGSize(width: 0, height: 100) : .zero
//                        isTabBarVisible = true
//                    }
//                }
//                
//                // Custom Tab Bar
//                if isTabBarVisible {
//                    tabBarView
//                }
//            }
//            .onReceive(timer) { _ in
//                           time += 1
//                if time > 5, isTabBarVisible {
//                    time = 0
//                    withAnimation(.easeInOut) {
////                        isTabBarVisible = false
//                        
//                    }
//                }
//                       }
//             // .edgesIgnoringSafeArea(.bottom)
//            
//        } else {
//            OnboardingView()
//        }
//    }
//    
//    var tabBarView: some View {
//        HStack {
//            Button(action: {
//                self.selectedTab = 0
//            }) {
//                VStack {
//                    Image(systemName: "house.fill")
//                        .renderingMode(.original)
//                    //  Text("Home")
//                }
//            }
//            Spacer()
//            Button(action: {
//                self.selectedTab = 1
//            }) {
//                VStack {
//                    if #available(iOS 17, *) {
//                        Image(systemName: "book.pages.fill")
//                            .renderingMode(.original)
//                    } else {
//                        Image(systemName: "book.fill")
//                            .renderingMode(.original)
//                    }
//                    //   Text("Devotionals")
//                }
//            }
//            
//            Spacer()
//            Button(action: {
//                self.selectedTab = 2
//            }) {
//                VStack {
//                    Image(systemName: "plus.circle.fill")
//                    // .renderingMode(.original)
//                    //  Text("Yours")
//                }
//            }
//            Spacer()
//            Button(action: {
//                self.selectedTab = 3
//            }) {
//                VStack {
//                    Image(systemName: "person.fill")
//                        .renderingMode(.original)
//                    //  Text("Settings")
//                }
//            }
//        }
//        
//        .padding()
//        .background(Color.clear)
//        .offset(y: tabOffset.height)
//       // .frame(maxWidth: .infinity)
//       // .accentColor(selectedTab ? Constants.DAMidBlue : .white)
//    }
//    
//    func setSelectedTab(tab: Int) {
//        
//    }
}
