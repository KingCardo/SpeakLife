//
//  PrayerView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/10/23.
//

import SwiftUI

//struct PrayerView: View {
//    
//    @EnvironmentObject var subscriptionStore: SubscriptionStore
//    @Environment(\.colorScheme) var colorScheme
//    @State var isPresentingManageSubscriptionView = false
//    
//    @StateObject var prayerViewModel = PrayerViewModel()
//    
//    var body: some View {
//        List {
//            ForEach(prayerViewModel.sectionData.indices, id: \.self) { index in
//                DisclosureGroup(isExpanded: $prayerViewModel.sectionData[index].isExpanded, content: {
//                    ForEach(prayerViewModel.sectionData[index].items, id: \.self) { prayer in
//                        if prayer.isPremium && !subscriptionStore.isPremium {
//                            Button {
//                                isPresentingManageSubscriptionView.toggle()
//                            } label: {
//                                prayerRow(prayer)
//                            }
//                        } else {
//                            NavigationLink(destination: PrayerDetailView(prayer: prayer.prayerText)) {
//                                prayerRow(prayer)
//                            }
//                        }
//                        
//                    }
//                }, label: {
//                    Text(prayerViewModel.sectionData[index].title.rawValue.uppercased())
//                })
//                .padding(.top)
//            }
//        }
//        .foregroundColor(colorScheme  == .dark ? .white : Constants.DAMidBlue)
//        .background(colorScheme  == .dark ? Color.black : Color.white)
//        .listStyle(GroupedListStyle())
//        .navigationBarTitle("Prayer List")
//        
//        .onAppear {
//            Task {
//                await prayerViewModel.fetchPrayers()
//            }
//        }
//        .sheet(isPresented: $isPresentingManageSubscriptionView) {
//            self.isPresentingManageSubscriptionView = false
//        } content: {
//            PremiumView()
//        }
//        
//        .alert(isPresented: $prayerViewModel.hasError, content: {
//            Alert(title: Text("Failed to load prayers"))
//        })
//        
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
//            self.isPresentingManageSubscriptionView = false
//        }
//    }
//    
//    private func prayerRow(_ prayer: Prayer) -> some View {
//        HStack {
//            if prayer.isPremium  {
//                Image(systemName: "star.fill")
//                    .foregroundColor(.yellow)
//            }
//            Text(prayer.prayerText)
//        }
//        .frame(maxHeight: 50)
//    }
//}
//
//struct PrayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PrayerView(prayerViewModel: PrayerViewModel())
//    }
//}
