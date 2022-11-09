//
//  StoreObserver.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 3/20/22.
//

import Foundation
import StoreKit

protocol StoreObserverDelegate: AnyObject {
    /// Tells the delegate that the restore operation was successful.
    func storeObserverRestoreDidSucceed(isPremium: Bool)

    /// Provides the delegate with messages.
    func storeObserverDidReceiveMessage(_ message: String)
}

let PurchaseSuccess = NSNotification.Name("PurchaseSuccessNotification")
let PurchaseCancelled = NSNotification.Name("PurchaseCancelledNotification")

final class StoreObserver: NSObject {
    // MARK: - Types

    static let shared = StoreObserver()
    var productId: String?
    
#if DEBUG
    let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
#else
    let verifyReceiptURL = "https://buy.itunes.apple.com/verifyReceipt"
#endif

    // MARK: - Properties

    /**
    Indicates whether the user is allowed to make payments.
    - returns: true if the user is allowed to make payments and false, otherwise. Tell StoreManager to query the App Store when the user is
    allowed to make payments and there are product identifiers to be queried.
    */
    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }

    /// Keeps track of all purchases.
    var purchased = [SKPaymentTransaction]()

    /// Keeps track of all restored purchases.
    var restored = [SKPaymentTransaction]()

    /// Indicates whether there are restorable purchases.
    fileprivate var hasRestorablePurchases = false

    weak var delegate: StoreObserverDelegate?

    // MARK: - Initializer

    private override init() {}

    // MARK: - Submit Payment Request

    /// Create and add a payment request to the payment queue.
    func buySubscription(with id: String) {
        guard isAuthorizedForPayments else {
            //TO DO: post notification cant buy
            return
        }
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = id
            SKPaymentQueue.default().add(paymentRequest)
    }

    // MARK: - Restore All Restorable Purchases

    /// Restores all previously completed purchases.
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // MARK: - Handle Payment Transactions

    /// Handles successful purchase transactions.
    fileprivate func handlePurchased(_ transaction: SKPaymentTransaction, id: String?) {
        guard let id = id else {
            return
        }
        DispatchQueue.main.async {
             NotificationCenter.default.post(Notification(name: PurchaseSuccess))
        }
        setSubscriptionKey(id: id)
        
        print("\(Messages.deliverContent) \(transaction.payment.productIdentifier).")

        // Finish the successful transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    /// Handles failed purchase transactions.
    fileprivate func handleFailed(_ transaction: SKPaymentTransaction) {
        var message = "\(Messages.purchaseOf) \(transaction.payment.productIdentifier) \(Messages.failed)"

        if let error = transaction.error {
            message += "\n\(Messages.error) \(error.localizedDescription)"
            print("\(Messages.error) \(error.localizedDescription)")
        }
         DispatchQueue.main.async {
             NotificationCenter.default.post(Notification(name: PurchaseCancelled))
        }

        // Do not send any notifications when the user cancels the purchase.
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            DispatchQueue.main.async {
                self.delegate?.storeObserverDidReceiveMessage(message)
            }
        }
        // Finish the failed transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    /// Handles restored purchase transactions.
    fileprivate func handleRestored(_ transaction: SKPaymentTransaction) {
        
        let productIDsToRestore = InAppId.AppID.allCases.map { $0.id }

        if transaction.original != nil  {
            let originalID = transaction.original!.payment.productIdentifier
            if productIDsToRestore.contains(originalID) {
                setSubscriptionKey(id: originalID)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(Notification(name: PurchaseSuccess))
                    self.delegate?.storeObserverRestoreDidSucceed(isPremium: true)
                }
            }
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: PurchaseCancelled))
                self.delegate?.storeObserverRestoreDidSucceed(isPremium: false)
            }
        }
        
        // Finishes the restored transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func receiptValidation(id: String, completion: ((Bool) -> Void)?) {
        
        let receiptFileURL = Bundle.main.appStoreReceiptURL
        guard let receiptData = try? Data(contentsOf: receiptFileURL!) else { return }
        let receiptString = receiptData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let jsonDict: [String: AnyObject] = ["receipt-data" : receiptString as AnyObject, "password" : APP.Version.sharedSecret as AnyObject]
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            guard let storeURL = URL(string: verifyReceiptURL) else {  return }
            var storeRequest = URLRequest(url: storeURL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                         // print("=======>",jsonResponse)
                        if let date = self?.getExpirationDateFromResponse(jsonResponse as! NSDictionary) {
                            
                            let date = Calendar.current.dateComponents(in: .current, from: date).date
                            self?.updateSubscription(expDate: date, id: id) { didDelete in
                            completion?(didDelete)
                            }
                        }
                    } catch let parseError {
                        print(parseError)
                    }
                }
            })
            task.resume()
        } catch let parseError {
            print(parseError)
        }
    }
    
    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            if let expiresDate = lastReceipt["expires_date"] as? String {
                formatter.timeZone = TimeZone.current
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                guard let stringDate = formatter.date(from: expiresDate)  else { return nil }
                print(stringDate, "RWRW")
                return stringDate
            }
            return nil
        } else {
            return nil
        }
    }
    
    func checkForExpiredSubscriptions(completion: @escaping (Bool) -> Void) {
        
        let (_ , currentSubscriptionId) = StoreManager.shared.getPremiumAppState()
        if let currentSubscriptionId = currentSubscriptionId {
            receiptValidation(id: currentSubscriptionId) { didDelete in
                completion(didDelete)
                return
            }
        } else {
            completion(false)
            return
        }
    }
    
    private func updateSubscription(expDate: Date?, id: String, completion: @escaping(Bool) -> Void) {
        if let _ = UserDefaults.standard.data(forKey: id) {
            guard let expDate = expDate else {
                completion(false)
                return
            }
            let now = Date()
            print(expDate,  "RWRW exp")
            if now > expDate {
                UserDefaults.standard.removeObject(forKey: id)
                completion(true)
                return
            }
        }
        completion(false)
        return
    }
    
    private func setSubscriptionKey(id: String) {
        let encoder = JSONEncoder()
        let date = Calendar.current.dateComponents(in: .current, from: Date()).date!
        let data = try? encoder.encode(InAppId(purchaseDate: date, purchased: true))
        UserDefaults.standard.set(data, forKey: id)
    }
}

// MARK: - SKPaymentTransactionObserver

/// Extends StoreObserver to conform to SKPaymentTransactionObserver.
extension StoreObserver: SKPaymentTransactionObserver {
    /// Called when there are transactions in the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: break
            // Do not block your UI. Allow the user to continue using your app.
            case .deferred: print(Messages.deferred)
            // The purchase was successful.
            case .purchased: handlePurchased(transaction, id: productId)
            // The transaction failed.
            case .failed: handleFailed(transaction)
            // There are restored products.
            case .restored: handleRestored(transaction)
            @unknown default: break
            }
        }
    }

    /// Logs all transactions that have been removed from the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print ("\(transaction.payment.productIdentifier) \(Messages.removed)")
        }
    }

    /// Called when an error occur while restoring purchases. Notify the user about the error.
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError, error.code != .paymentCancelled {
            DispatchQueue.main.async {
                self.delegate?.storeObserverDidReceiveMessage(error.localizedDescription)
            }
        }
    }

    /// Called when all restorable transactions have been processed by the payment queue.
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {

        if !hasRestorablePurchases {
            DispatchQueue.main.async {
                self.delegate?.storeObserverDidReceiveMessage(Messages.noRestorablePurchases)
            }
        }
    }
}
