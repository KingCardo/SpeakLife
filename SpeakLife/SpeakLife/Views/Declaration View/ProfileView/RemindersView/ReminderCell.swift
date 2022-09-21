//
//  ReminderCell.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/16/22.
//

import SwiftUI

final class ReminderCellViewModel: ObservableObject,  Identifiable {
    let reminder: Reminder
    
    
    init(_ reminder: Reminder) {
        self.reminder = reminder
    }
}


struct ReminderCell: View  {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
   
    private let reminderVM: ReminderCellViewModel
    
    init(_ reminderVM: ReminderCellViewModel) {
        self.reminderVM = reminderVM
    }
    var body: some View  {
        VStack {
            Toggle("",  isOn: appState.$notificationEnabled)
                .toggleStyle(ColoredToggleStyle(label: "Daily Declaration Reminder",
                                                onColor: Constants.DAMidBlue))
                .padding([.bottom, .top])
                .foregroundColor(Constants.DAMidBlue)
                .padding(6)
            
    
            StepperNotificationCountView(appState.notificationCount) { valueCount in
                appState.notificationCount = valueCount
                
            }
            .padding(6)
            .padding([.leading, .trailing])
            .foregroundColor(colorScheme == .dark ? .white : Constants.DEABlack)
            
            TimeNotificationCountView(value: appState.startTimeIndex) {
                Text("Start_time" , comment: "start time reminder cell title")
                
            } valueTime:  { valueTime in
                appState.startTimeNotification = valueTime
            } valueIndex: { valueIndex in
                appState.startTimeIndex = valueIndex
            }
            
            .padding(6)
            .padding([.leading, .trailing])
            .foregroundColor(colorScheme == .dark ? .white : Constants.DEABlack)
            
            TimeNotificationCountView(value: appState.endTimeIndex) {
                Text("End_time", comment: "end time reminder cell title")
            } valueTime: { valueTime in
                appState.endTimeNotification = valueTime
            } valueIndex: { valueIndex in
                appState.endTimeIndex = valueIndex
            }
            .padding(6)
            .padding([.leading, .trailing])
            .foregroundColor(colorScheme == .dark ? .white : Constants.DEABlack)
            
            CategoryButtonRow()
                .padding(6)
                .padding([.leading, .trailing])
                .foregroundColor(colorScheme == .dark ? .white : Constants.DEABlack)
            
        }
        .padding()
    }
}

