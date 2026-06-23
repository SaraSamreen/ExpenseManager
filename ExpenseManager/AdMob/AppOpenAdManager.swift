//
//  AppOpenAdManager.swift
//  ExpenseManager
//
//  Created by Mac on 19/06/2026.
//


import GoogleMobileAds
import UIKit
import JGProgressHUD

@MainActor
final class AppOpenAdManager: NSObject, FullScreenContentDelegate {

    static let shared = AppOpenAdManager()

    private var appOpenAd: AppOpenAd?
    private var isLoadingAd = false
    private var isShowingAd = false
    private var loadTime: Date?

    /// Called exactly once after the ad is dismissed, fails to present, or never becomes available.
    /// Use this to drive navigation that should happen regardless of ad outcome.
    private var onFinished: (() -> Void)?

    private let adUnitID = "ca-app-pub-3940256099942544/9257395921"
    private static let adAvailabilityWindow: TimeInterval = 4 * 60 * 60 // 4 hours

    // MARK: - Loading

    func loadAd(timeout: TimeInterval? = nil, completion: ((Bool) -> Void)? = nil) {
        if isAdAvailable() {
            completion?(true)
            return
        }
        if isLoadingAd {
            completion?(false)
            return
        }

        var didComplete = false
        let finish: (Bool) -> Void = { success in
            guard !didComplete else { return }
            didComplete = true
            completion?(success)
        }

        isLoadingAd = true
        let request = Request()

        AppOpenAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            Task { @MainActor in
                self.isLoadingAd = false

                if let error = error {
                    print("DEBUG: App open ad failed to load — \(error.localizedDescription)")
                    finish(false)
                    return
                }

                self.appOpenAd = ad
                self.appOpenAd?.fullScreenContentDelegate = self
                self.loadTime = Date()
                print("DEBUG: App open ad loaded")
                finish(true)
            }
        }

        if let timeout = timeout {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                finish(false)
            }
        }
    }

    private func isAdAvailable() -> Bool {
        guard appOpenAd != nil, let loadTime = loadTime else { return false }
        return Date().timeIntervalSince(loadTime) < Self.adAvailabilityWindow
    }

    // MARK: - Showing

    /// Loads (if needed, with `timeout`), shows the ad if it becomes available, and
    /// calls `completion` exactly once when the flow is fully finished — whether the
    /// ad was shown and dismissed, failed to present, or never loaded in time.
    func showAd(timeout: TimeInterval = 8, completion: @escaping () -> Void) {
        guard !isShowingAd else {
            completion()
            return
        }

        onFinished = completion

        loadAd(timeout: timeout) { [weak self] success in
            guard let self = self else { return }
            guard success, self.presentAdIfPossible() else {
                self.finish()
                return
            }
        }
    }

    /// Presents the ad if available. Returns false if it could not be presented
    /// (no ad, or no root view controller to present from).
    @discardableResult
    private func presentAdIfPossible() -> Bool {
        
        print("Ad Available:", isAdAvailable())
        print("Root VC:", topViewController() as Any)
        
        guard isAdAvailable(), let ad = appOpenAd, let rootVC = topViewController() else {
            return false
        }

        isShowingAd = true
        ad.present(from: rootVC)
        return true
    }

    private func topViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }

    private func finish() {
        let callback = onFinished
        onFinished = nil
        callback?()
    }

    // MARK: - FullScreenContentDelegate

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = false
        appOpenAd = nil
        finish()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("DEBUG: App open ad failed to present — \(error.localizedDescription)")
        isShowingAd = false
        appOpenAd = nil
        finish()
    }
}
