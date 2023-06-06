//
//  MailView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/27/22.
//

import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {
    enum Origin {
      case profile
      case review
    }

    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    @State var origin: Origin
    private let appVersion = "App version: \(APP.Version.stringNumber)"
    
    var title: String {
        switch origin {
        case .profile: return "Support for \(appVersion)"
        case .review: return "Feedback for SpeakLife - Daily Bible Promises(iOS app)"
        }
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(isShowing: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject(NSLocalizedString(title, comment: "mail title"))
        vc.setToRecipients(["speaklifebibleapp@gmail.com"])
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
