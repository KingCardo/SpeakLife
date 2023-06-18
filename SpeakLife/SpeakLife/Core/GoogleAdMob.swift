//
//  GoogleAdMob.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/29/23.
//
import SwiftUI
import GoogleMobileAds
import UIKit


final class InterstitialAdManager: NSObject {
    var interstitial: GADInterstitialAd?
    
    override init() {
        super.init()
        loadInterstitial()
    }
    
    func loadInterstitial() {
        GADInterstitialAd.load(withAdUnitID: "YOUR_AD_UNIT_ID",
                               request: GADRequest(),
                               completionHandler: { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
        })
    }
    
    func showAd() {
        if let interstitial = interstitial {
            interstitial.present(fromRootViewController: (UIApplication.shared.windows.first?.rootViewController)!)
        } else {
            print("Interstitial ad not ready yet.")
        }
    }
}

extension InterstitialAdManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitial()
    }
}



struct GoogleAdBannerView: UIViewRepresentable {
    private let adUnitID: String
    
    init(adUnitID: String = APP.Product.googleAdUnitBannerID) {
        self.adUnitID = adUnitID
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 50)))
        bannerView.adUnitID = adUnitID
        if let mainWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let windows = mainWindowScene.windows.filter { $0.isKeyWindow }
            if let mainWindow = windows.first {
                bannerView.rootViewController = mainWindow.rootViewController
            }
        }
        
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}

