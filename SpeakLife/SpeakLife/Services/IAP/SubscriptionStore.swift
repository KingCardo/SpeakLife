//
//  SubscriptionStore.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 12/17/22.
//

import StoreKit
import Combine
import FirebaseAnalytics
import FacebookCore
import SwiftUI

import StoreKit
import Combine

import Firebase
import FirebaseRemoteConfig

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}
var yearlyID = ""
let currentYearlyID = "SpeakLife1YR19"
let currentMonthlyID = "SpeakLife1MO4"
let currentMonthlyPremiumID = "SpeakLife1MO9"
let currentPremiumID = "SpeakLife1YR29"
let lifetimeID = "SpeakLifeLifetime"
let devotionals = "Devotionals30SL"
final class SubscriptionStore: ObservableObject {

    @Published var isPremium: Bool = false
    @Published var isPremiumAllAccess: Bool = false
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var nonConsumables: [Product] = [] // New list for non-consumables
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var purchasedNonConsumables: [Product] = [] // New list for purchased non-consumables
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    @Published var currentOfferedYearly: Product? = nil
    @Published var currentOfferedLifetime: Product? = nil
    @Published var currentOfferedMonthly: Product? = nil
    @Published var currentOfferedPremium: Product? = nil
    @Published var currentOfferedPremiumMonthly: Product? = nil
    @Published var currentOfferedDevotionalPremium: Product? = nil
    @Published var isInDevotionalPremium = false
    @Published var testGroup = 0//Int.random(in: 0...1)
    @AppStorage("lastDevotionalPurchase") var lastDevotionalPurchaseDate: Date?
    
    @Published var showDevotionalSubscription = false
    @Published var showOneTimeSubscription = false
    
    @Published var yearlySubscription = ""
    @Published var discountSubscription = ""
   
    private var remoteConfig = RemoteConfig.remoteConfig()
    var updateListenerTask: Task<Void, Error>? = nil
    var cancellable: AnyCancellable?

    init() {
        // Initialize the lists
        subscriptions = []
        nonConsumables = []
      
        // Start a transaction listener as close to app launch as possible
        updateListenerTask = listenForTransactions()
        
        fetchRemoteConfig() { [weak self] in
            
            Task {
                // During store initialization, request products from the App Store
                await self?.requestProducts()
                
                // Deliver products that the customer purchases
                await self?.updateCustomerProductStatus()
            }
        }
        
        cancellable = Publishers.CombineLatest3($subscriptionGroupStatus, $purchasedNonConsumables, $purchasedSubscriptions)
            .sink { [weak self] subscriptionStatus, nonConsumables, purchasedSubscriptions in
                guard let self = self else { return }
                // Update isPremium based on subscription state and purchased non-consumables
                self.isInDevotionalPremium = checkIsDevotionalActive(nonConsumables: nonConsumables)
                self.isPremium = (subscriptionStatus == .subscribed) || nonConsumables.contains( where: { $0 == self.currentOfferedLifetime })
            }
        
    }

    deinit {
        updateListenerTask?.cancel()
    }
    
    func fetchRemoteConfig(completion: @escaping() -> Void) {
        
        remoteConfig.fetchAndActivate { [weak self] status, error in
            guard let self = self else { return }
            if let error = error {
                print("Remote Config fetch failed: \(error.localizedDescription)")
                completion()
                return
            }
            
            self.updateConfigValues(completion: completion)
        }
    }
    
    private func updateConfigValues(completion: @escaping() -> Void) {
        showDevotionalSubscription = remoteConfig["showDevotionalSubscription"].boolValue
        showOneTimeSubscription = remoteConfig["showOneTimeSubscription"].boolValue
        yearlySubscription = remoteConfig["currentPremiumID"].stringValue
        discountSubscription = remoteConfig["discountID"].stringValue
        yearlyID = yearlySubscription
        print(discountSubscription, "RWRW")
        print(yearlySubscription, "RWRW")
        completion()

    }
    
    func checkIsDevotionalActive(nonConsumables: [Product]) -> Bool {
        if nonConsumables.contains( where: { $0 == self.currentOfferedDevotionalPremium }), let purchaseDate = lastDevotionalPurchaseDate {
            return isWithin30Days(from: purchaseDate)
        }
        return false
    }
    
    private func isWithin30Days(from date: Date) -> Bool {
        // Get the current date
        let currentDate = Date()
        
        // Calculate the date 30 days ago
        guard let date30DaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: currentDate) else {
            return false
        }
        
        // Check if the given date is after or on the date 30 days ago
        return date >= date30DaysAgo
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Deliver products to the user
                    await self.updateCustomerProductStatus()

                    // Always finish a transaction
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification; don't deliver content
                    print("Transaction failed verification")
                }
            }
        }
    }

    @MainActor
    func requestProducts() async {
        do {
            // Request products from the App Store using the identifiers defined in InAppId
            let storeProducts = try await Product.products(for: InAppId.all)

            var newSubscriptions: [Product] = []
            var newNonConsumables: [Product] = [] // New list for non-consumables

            // Filter the products into categories based on their type
            for product in storeProducts {
                switch product.type {
                case .autoRenewable:
                    newSubscriptions.append(product)
                    if product.id == discountSubscription {
                        currentOfferedYearly = product
                        print("Yearly set RWRW")
                    }
                    if product.id == currentMonthlyID {
                        currentOfferedMonthly = product
                        print("Monthly set RWRW")
                    }
                    
                    if product.id == currentMonthlyPremiumID {
                        currentOfferedPremiumMonthly = product
                        print("currentMonthlyPremiumID set RWRW")
                    }
                    
                    if product.id == yearlySubscription {
                        currentOfferedPremium = product
                        print("currentPremiumID set RWRW")
                    }
                case .nonConsumable:
                    if product.id == lifetimeID {
                        currentOfferedLifetime = product
                    }
                    if product.id == devotionals {
                        currentOfferedDevotionalPremium = product
                    }
                    newNonConsumables.append(product) // Handle non-consumables
                default:
                    print("Unknown product type")
                }
            }

            // Sort products by price
            subscriptions = sortByPrice(newSubscriptions)
            nonConsumables = sortByPrice(newNonConsumables)
            
         //   setDiscountOff()

// Set non-consumables
        } catch {
            print("Failed product request from the App Store server: \(error)")
        }
    }
    
//    func setDiscountOff() {
//        if currentOfferedPremium?.type.rawValue == "SpeakLife1YR39" {
//            discountOFF = "50% off"
//        } else if currentOfferedPremium?.type.rawValue == "SpeakLife1YR49" {
//            discountOFF = "60% off"
//        }
//    }
    
    func purchaseWithID(_ ids: [String]) async throws -> Transaction? {
        guard let id = ids.first else { return nil }
        let productFromID = await products(for: [id])
        guard let product = productFromID?.first else { return nil }
        let transaction = try await purchase(product)
        return transaction
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        //Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            //Check whether the transaction is verified. If it isn't,
            //this function rethrows the verification error.
            let transaction = try checkVerified(verification)
            
            //The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()
            
            AppEvents.shared.logPurchase(amount: Double(product.displayPrice) ?? Double(0), currency: "")
            Analytics.logEvent(Event.premiumSucceded, parameters: ["product": product.displayPrice])


            //Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }

    func isPurchased(_ product: Product) async throws -> Bool {
        // Determine whether the user purchased a given product
        switch product.type {
        case .autoRenewable:
            return purchasedSubscriptions.contains(product)
        case .nonConsumable:
            return purchasedNonConsumables.contains(product) // Check for non-consumables
        default:
            return false
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification
        switch result {
        case .unverified:
            print("Transaction verification failed")
            throw StoreError.failedVerification
        case .verified(let safe):
            print("Transaction verified")
            return safe
        }
    }

    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSubscriptions: [Product] = []
        var purchasedNonConsumables: [Product] = [] // New list for purchased non-consumables

        // Iterate through all of the user's purchased products
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified
                let transaction = try checkVerified(result)

                // Handle the transaction based on product type
                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        purchasedSubscriptions.append(subscription)
                    }
                case .nonConsumable:
                    if let nonConsumable = nonConsumables.first(where: { $0.id == transaction.productID }) {
                        purchasedNonConsumables.append(nonConsumable)
                    }
                default:
                    break
                }
            } catch {
                print("Transaction verification failed")
            }
        }

        // Update store properties
        self.purchasedSubscriptions = purchasedSubscriptions
        self.purchasedNonConsumables = purchasedNonConsumables
        
        subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state

        // Update isPremium flag
        //self.isPremium = !purchasedSubscriptions.isEmpty || !purchasedNonConsumables.isEmpty
    }
    
    func products(for ids: [String]) async -> [Product]? {
        do {
            let products = try await Product.products(for: ids)
            return products
        } catch {
            print("Failed product request from the App Store server: \(error)")
        }
        return nil
    }

    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
    
    func restore() async {
        await updateCustomerProductStatus()
    }
}

extension Product {
    
    var title: String {
        if id == lifetimeID {
            return "One time fee of \(displayPrice) for lifetime access."
        } else if id == currentYearlyID {
            return "$\(price/12)/mo."
        } else if id == currentPremiumID {
            return "$\(price/12)/mo."
        } else {
            return "\(displayPrice)/month. Cancel anytime."
        }
    }
    
    var ctaDurationTitle: String {
        if id == lifetimeID {
            return "Lifetime"
        } else if id == currentYearlyID {
            return "Pro - Save 50%"
        } else if id == yearlyID {
                return "Yearly"
        } else if id == currentMonthlyPremiumID {
            return "Monthly"
        } else {
           return "Pro Monthly"
        }
    }
    
    var ctaButtonTitle: String {
        if id == currentYearlyID {
            return "Start My Free Trial Now"
        } else if id == yearlyID {
                return "Try Free & Subscribe"
        } else {
           return "Subscribe"
        }
    }
    
    
    
    var subTitle: String {
        if id == lifetimeID {
            return "One time fee of \(displayPrice) for lifetime access."
        } else if id == currentYearlyID {
           return "7 days free then \(displayPrice)/yr."
        } else if id == yearlyID {
            let twelve = Double(12)
            let floatDecimal: Double = 100
            let priceDouble = NSDecimalNumber(decimal: price).doubleValue

            // Convert Float16 to Decimal

            // Perform Decimal calculation
            let priceDivided = priceDouble / twelve
            let truncatedPrice = (priceDivided * floatDecimal).rounded(.down) / floatDecimal

            // Convert to Double only after rounding down
            let price = (truncatedPrice as Double)
            let roundedPrice = String(format: "%.2f", price)
                return "$\(roundedPrice)/mo."
        } else {
           return "\(displayPrice)/mo."
        }
    }
    
    
    var costDescription: String {
        if id == yearlyID {
            return "7 days free, then \(displayPrice) per year. Cancel anytime."
        } else if id == lifetimeID {
            return "Pay once, own it for life!"
        } else {
            return "Just \(displayPrice) per month. Cancel anytime."
        }
    }
        
//        var discountOff: String {
//            if id == "SpeakLife1YR39" {
//                return "50%"
//            } else if id == "SpeakLife1YR49" {
//                return "60%"
//            } else {
//                return ""
//            }
  //  }
}
