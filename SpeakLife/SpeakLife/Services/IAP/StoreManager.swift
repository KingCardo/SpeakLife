//
//  StoreManager.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 3/20/22.
//

import Foundation
import StoreKit

protocol StoreManagerDelegate: AnyObject {
    /// Provides the delegate with the error encountered during the product request.
    func storeManagerDidReceiveMessage(_ message: String)
}


final class StoreManager: NSObject, ObservableObject {
    // MARK: - Types

    static let shared = StoreManager()

    // MARK: - Properties

    /// Keeps track of all valid products. These products are available for sale in the App Store.
    //fileprivate var availableProducts: [String?] = InAppId.AppID.allCases

    weak var delegate: StoreManagerDelegate?

    // MARK: - Initializer

    private override init() {}

    // MARK: - Request Product Information
    
    func isPurchased(with id: String) -> Bool {
        if let _ = UserDefaults.standard.data(forKey: id) {
            return true
        }
        return false
    }

    /// Starts the product request with the specified identifiers.
    func startProductRequest(with identifiers: String) {
        StoreObserver.shared.buySubscription(with: identifiers)
    }
    
    func getPremiumAppState() -> (Bool, String?) {
        for id in InAppId.AppID.allCases {
            let success = isPurchased(with: id.rawValue)
            if success {
                return (success, id.rawValue)
            }
        }
        return (false, nil)
    }
}


// MARK: - SKRequestDelegate

/// Extends StoreManager to conform to SKRequestDelegate.
extension StoreManager: SKRequestDelegate {
    /// Called when the product request failed.
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.delegate?.storeManagerDidReceiveMessage(error.localizedDescription)
        }
    }
}
