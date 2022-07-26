//
//  TimeNotificationStepper.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/8/22.
//

import SwiftUI


struct StepperNotificationCountView: View {
    
    @State private var value: Int
    
    let step = 1
    let range = 1...15
    var valueCount: (Int) -> Void
    
    init(_ value: Int, valueCount: @escaping(Int) -> Void) {
        self.value = value
        self.valueCount = valueCount
    }
    
    func incrementStep() {
        guard value < 15 else { return }
        value += 1
        valueCount(value)
    }
    
    func decrementStep() {
        guard value > 1 else { return }
        value -= 1
        valueCount(value)
    }
    
    var body: some View {
        Stepper {
            HStack {
                Text("Alerts per day", comment: "alert count per day")
                Spacer()
                Text("\(value)X")
                    .fontWeight(.light)
                Spacer()
                    .frame(width: 5, height: 1)
            }
            
        } onIncrement: {
            incrementStep()
            Selection.shared.selectionFeedback()
        } onDecrement: {
            decrementStep()
            Selection.shared.selectionFeedback()
        }
    
    
        .accentColor(Constants.DALightBlue)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Constants.DAMidBlue, lineWidth: 1))

    }
    
}

// Start and End time Stepper


struct TimeNotificationCountView<Content: View> : View {
    @Environment(\.colorScheme) var colorScheme
    @State var value: Int
    let content: () -> Content
    var valueTime: (String) -> Void
    var valueIndex: (Int) -> Void
    let timeSlots = TimeSlots.getTimeSlots()
    
    
    func incrementStep() {
        value += 1
        if value >= timeSlots.count { value = 0 }
    }
    
    func decrementStep() {
        value -= 1
        if value < 0 { value = timeSlots.count - 1 }
    }
    
    var body: some View {
        Stepper {
            HStack {
                content()
                
                Spacer()
                Text("\(timeSlots[value])")
                    .fontWeight(.light)
                
                Spacer()
                    .frame(width: 5, height: 1)
            }
            
        } onIncrement: {
            incrementStep()
            valueTime(timeSlots[value])
            valueIndex(value)
            Selection.shared.selectionFeedback()
        } onDecrement: {
            decrementStep()
            valueTime(timeSlots[value])
            valueIndex(value)
            Selection.shared.selectionFeedback()
        }
        
        .accentColor(Constants.DALightBlue)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Constants.DAMidBlue, lineWidth: 1))
        
    }
}
