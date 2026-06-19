//
//  AppOpenAdManager.swift
//  ExpenseManager
//
//  Created by Mac on 19/06/2026.
//

import GoogleMobileAds
import UIKit

@MainActor
class AppOpenAdManager: NSObject, FullScreenContentDelegate {
    
    static let shared = AppOpenAdManager()
    
    private var appOpenAd: AppOpenAd?
    private var isLoadingAd = false
    private var isShowingAd = false
    private var loadTime: Date?
    
    private let adUnitID = "ca-app-pub-3940256099942544/9257395921"
    
    func loadAd() {
        if isLoadingAd || isAdAvailable() { return }
        isLoadingAd = true
        
        let request = Request()
        AppOpenAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            Task { @MainActor in
                self.isLoadingAd = false
                if let error = error {
                    print("DEBUG: App open ad failed to load — \(error.localizedDescription)")
                    return
                }
                self.appOpenAd = ad
                self.appOpenAd?.fullScreenContentDelegate = self
                self.loadTime = Date()
                print("DEBUG: App open ad loaded")
            }
        }
    }
    
    private func isAdAvailable() -> Bool {
        guard appOpenAd != nil, let loadTime = loadTime else { return false }
        let fourHours: TimeInterval = 4 * 60 * 60
        return Date().timeIntervalSince(loadTime) < fourHours
    }
    
    func showAdIfAvailable() {
        if isShowingAd { return }
        
        guard isAdAvailable(), let ad = appOpenAd,
              let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController else {
            loadAd()
            return
        }
        
        isShowingAd = true
        ad.present(from: rootVC)
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = false
        appOpenAd = nil
        loadAd()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("DEBUG: App open ad failed to present — \(error.localizedDescription)")
        isShowingAd = false
        appOpenAd = nil
        loadAd()
    }
}
