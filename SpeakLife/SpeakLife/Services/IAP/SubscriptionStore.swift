//
//  SubscriptionStore.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 12/17/22.
//

import Foundation
import StoreKit
import Combine
import FirebaseAnalytics
import FacebookCore


import StoreKit
import Combine

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}

let currentYearlyID = "SpeakLife1YR29"
let currentMonthlyID = "SpeakLife1MO4"
let currentMonthlyPremiumID = "SpeakLife1MO9"
let currentPremiumID = "SpeakLife1YR49"
let lifetimeID = "SpeakLifeLifetime"
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
   
    
    var updateListenerTask: Task<Void, Error>? = nil
    var cancellable: AnyCancellable?

    init() {
        // Initialize the lists
        subscriptions = []
        nonConsumables = []
      
        // Start a transaction listener as close to app launch as possible
        updateListenerTask = listenForTransactions()

        Task {
            // During store initialization, request products from the App Store
            await requestProducts()

            // Deliver products that the customer purchases
            await updateCustomerProductStatus()
        }
        
        cancellable = Publishers.CombineLatest3($subscriptionGroupStatus, $purchasedNonConsumables, $purchasedSubscriptions)
            .sink { [weak self] subscriptionStatus, nonConsumables, purchasedSubscriptions in
                guard let self = self else { return }
                // Update isPremium based on subscription state and purchased non-consumables
                self.isPremium = (subscriptionStatus == .subscribed) || !nonConsumables.isEmpty
                self.isPremiumAllAccess = (purchasedSubscriptions.first(where: { $0.id ==  currentPremiumID }) != nil) || (purchasedSubscriptions.first(where: { $0.id ==  currentMonthlyPremiumID }) != nil) || !nonConsumables.isEmpty
            }
        
    }

    deinit {
        updateListenerTask?.cancel()
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
                    if product.id == currentYearlyID {
                        currentOfferedYearly = product
                        print("Yearly set RWRW")
                    }
                    if product.id == currentMonthlyID {
                        currentOfferedMonthly = product
                        print("Monthly set RWRW")
                    }
                    
                    if product.id == currentMonthlyPremiumID {
                        currentOfferedPremiumMonthly = product
                        print("Monthly set RWRW")
                    }
                    
                    if product.id == currentPremiumID {
                        currentOfferedPremium = product
                        print("Monthly set RWRW")
                    }
                case .nonConsumable:
                    if product.id == lifetimeID {
                        currentOfferedLifetime = product
                    }
                    newNonConsumables.append(product) // Handle non-consumables
                default:
                    print("Unknown product type")
                }
            }

            // Sort products by price
            subscriptions = sortByPrice(newSubscriptions)
            nonConsumables = sortByPrice(newNonConsumables) 

// Set non-consumables
        } catch {
            print("Failed product request from the App Store server: \(error)")
        }
    }
    
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
            return "7 days free then \(displayPrice)/year."
        } else if id == currentPremiumID {
            return "Full access, 7 days free then \(displayPrice)/year."
        } else {
            return "\(displayPrice)/month. Cancel anytime."
        }
    }
    
    var ctaDurationTitle: String {
        if id == lifetimeID {
            return "Lifetime"
        } else if id == currentYearlyID {
            return "Pro - Save 50%"
        } else if id == currentPremiumID {
                return "Annual - 7 days free then \(displayPrice)/yr."
        } else if id == currentMonthlyPremiumID {
            return "Monthly"
        } else {
           return "Pro Monthly"
        }
    }
    
    var ctaButtonTitle: String {
        if id == currentYearlyID {
            return "Start My Free Trial Now"
        } else if id == currentPremiumID {
                return "Start My Free Trial Now"
        } else {
           return "Subscribe"
        }
    }
    
    
    
    var subTitle: String {
        if id == lifetimeID {
            return "One time fee of \(displayPrice) for lifetime access."
        } else if id == currentYearlyID {
           return "7 days free then \(displayPrice)/yr."
        } else if id == currentPremiumID {
                return "Save 70% with the Annual Plan."
        } else {
           return "billed monthly at \(displayPrice). Cancel anytime."
        }
    }
    
    var costDescription: String {
        return "No commitment. Cancel anytime."
//        if id == currentYearlyID {
//            return "7 days free then \(displayPrice)/year."
//        } else if id == currentPremiumID {
//            
//        } else {
//            return "\(displayPrice)/month. Cancel anytime."
//        }
    }
}
