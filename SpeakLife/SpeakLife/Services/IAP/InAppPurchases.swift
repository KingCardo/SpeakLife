//
//  InAppPurchases.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 3/20/22.
//

import Foundation

struct InAppId: Codable {
    
    var purchaseDate: Date?
    var purchased = false
    
    enum AppID: String, Identifiable, CaseIterable {
        var id: String {
            self.rawValue
        }
        
        case speakLife1YR99 = "SpeakLife1YR99"
        case speakLife1YR49 = "SpeakLife1YR49"
        case speakLife1YR39 = "SpeakLife1YR39"
        case speakLife1YR19 = "SpeakLife1YR19"
        case speakLife1MO9 = "SpeakLife1MO9"
        case speakLife1MO4 = "SpeakLife1MO4"
        case speakLife1MO2 = "SpeakLife1MO2"
        
        var currentPrice: String {
            switch self {
            case .speakLife1YR99: return "$99.99"
            case .speakLife1YR49: return "$49.99"
            case .speakLife1YR39: return "$39.99"
            case .speakLife1YR19: return "$19.99"
            case .speakLife1MO9: return "$9.99"
            case .speakLife1MO4: return "$4.99"
            case .speakLife1MO2: return "$2.99"
            }
        }
        
        var title: String {
            switch self {
            case .speakLife1YR99: return "$99.99/year"
            case .speakLife1YR49: return "$49.99/year"
            case .speakLife1YR39: return "$39.99/year"
            case .speakLife1YR19: return "$19.99/year"
            case .speakLife1MO9: return "$9.99/month"
            case .speakLife1MO4: return "$4.99/month"
            case .speakLife1MO2: return "$2.99/month"
            }
        }
    }
    

//    static let all: [String] = [speakLife1YR99, speakLife1YR49, speakLife1YR39, speakLife1YR19, speakLife1MO9, speakLife1MO4, speakLife1MO2]
}

struct Messages {
    #if os (iOS)
    static let cannotMakePayments = "\(notAuthorized) \(installing)"
    #else
    static let cannotMakePayments = "In-App Purchases are not allowed."
    #endif
    static let couldNotFind = "Could not find resource file:"
    static let deferred = "Allow the user to continue using your app."
    static let deliverContent = "Deliver content for"
    static let emptyString = ""
    static let error = "Error: "
    static let failed = "failed."
    static let installing = "In-App Purchases may be restricted on your device."
    static let invalidIndexPath = "Invalid selected index path"
    static let noRestorablePurchases = "There are no restorable purchases.\n\(previouslyBought)"
    static let noPurchasesAvailable = "No purchases available."
    static let notAuthorized = "You are not authorized to make payments."
    static let okButton = "OK"
    static let previouslyBought = "Only previously bought non-consumable products and auto-renewable subscriptions can be restored."
    static let productRequestStatus = "Product Request Status"
    static let purchaseOf = "Purchase of"
    static let purchaseStatus = "Purchase Status"
    static let removed = "was removed from the payment queue."
    static let restorable = "All restorable transactions have been processed by the payment queue."
    static let restoreContent = "Restore content for"
    static let status = "Status"
    static let unableToInstantiateAvailableProducts = "Unable to instantiate an AvailableProducts."
    static let unableToInstantiateInvalidProductIds = "Unable to instantiate an InvalidProductIdentifiers."
    static let unableToInstantiateMessages = "Unable to instantiate a MessagesViewController."
    static let unableToInstantiateNavigationController = "Unable to instantiate a navigation controller."
    static let unableToInstantiateProducts = "Unable to instantiate a Products."
    static let unableToInstantiatePurchases = "Unable to instantiate a Purchases."
    static let unableToInstantiateSettings = "Unable to instantiate a Settings."
    static let unknownDefault = "Unknown payment transaction case."
    static let unknownDestinationViewController = "Unknown destination view controller."
    static let unknownDetail = "Unknown detail row:"
    static let unknownPurchase = "No selected purchase."
    static let unknownSelectedSegmentIndex = "Unknown selected segment index: "
    static let unknownSelectedViewController = "Unknown selected view controller."
    static let unknownTabBarIndex = "Unknown tab bar index:"
    static let unknownToolbarItem = "Unknown selected toolbar item: "
    static let updateResource = "Update it with your product identifiers to retrieve product information."
    static let useStoreRestore = "Use Store > Restore to restore your previously bought non-consumable products and auto-renewable subscriptions."
    static let viewControllerDoesNotExist = "The main content view controller does not exist."
    static let windowDoesNotExist = "The window does not exist."
}
