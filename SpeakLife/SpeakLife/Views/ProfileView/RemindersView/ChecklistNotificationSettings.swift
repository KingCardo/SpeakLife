//
//  ChecklistNotificationSettings.swift
//  SpeakLife
//
//  Settings view for daily checklist notifications
//

import SwiftUI

struct ChecklistNotificationSettings: View {
    @EnvironmentObject var appState: AppState
    @Binding var showConfirmation: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Checklist Reminders")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Smart notifications for your spiritual journey")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                
                Toggle("", isOn: $appState.checklistNotificationsEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: Constants.SLBlue))
                    .onChange(of: appState.checklistNotificationsEnabled) { _ in
                        triggerConfirmation()
                    }
            }
            
            if appState.checklistNotificationsEnabled {
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    // Morning Reminder Settings
                    VStack(spacing: 12) {
                        HStack {
                            Text("🌅 Morning Motivation")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: $appState.morningReminderEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: Constants.SLBlue))
                                .onChange(of: appState.morningReminderEnabled) { _ in
                                    triggerConfirmation()
                                }
                        }
                        
                        if appState.morningReminderEnabled {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Time:")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                TimePickerCompact(
                                    hour: $appState.morningReminderHour,
                                    minute: $appState.morningReminderMinute,
                                    onChange: triggerConfirmation
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // Evening Check-in Settings
                    VStack(spacing: 12) {
                        HStack {
                            Text("🌙 Evening Check-in")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: $appState.eveningCheckInEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: Constants.SLBlue))
                                .onChange(of: appState.eveningCheckInEnabled) { _ in
                                    triggerConfirmation()
                                }
                        }
                        
                        if appState.eveningCheckInEnabled {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Time:")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                TimePickerCompact(
                                    hour: $appState.eveningCheckInHour,
                                    minute: $appState.eveningCheckInMinute,
                                    onChange: triggerConfirmation
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func triggerConfirmation() {
        withAnimation {
            showConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showConfirmation = false
            }
        }
        
        // Schedule notifications with new settings
        NotificationManager.shared.scheduleChecklistNotifications()
    }
}

struct TimePickerCompact: View {
    @Binding var hour: Int
    @Binding var minute: Int
    let onChange: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Hour Picker
            VStack(spacing: 4) {
                Text("Hour")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                
                Picker("Hour", selection: $hour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(String(format: "%02d", hour))
                            .foregroundColor(.white)
                            .tag(hour)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 80)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                )
                .onChange(of: hour) { _ in onChange() }
            }
            
            Text(":")
                .foregroundColor(.white)
                .font(.title2)
                .fontWeight(.semibold)
            
            // Minute Picker
            VStack(spacing: 4) {
                Text("Minute")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                
                Picker("Minute", selection: $minute) {
                    ForEach([0, 15, 30, 45], id: \.self) { minute in
                        Text(String(format: "%02d", minute))
                            .foregroundColor(.white)
                            .tag(minute)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 80)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                )
                .onChange(of: minute) { _ in onChange() }
            }
        }
        .padding(.horizontal, 8)
    }
}

#if DEBUG
struct ChecklistNotificationSettings_Previews: PreviewProvider {
    @State static var showConfirmation = false
    
    static var previews: some View {
        ChecklistNotificationSettings(showConfirmation: $showConfirmation)
            .environmentObject(AppState())
            .background(Color.black)
    }
}
#endif