//
//  SceneDelegate.swift
//  ExpenseManager
//
//  Created by Mac on 21/05/2026.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private let minimumSplashDuration: TimeInterval = 3
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow(windowScene: windowScene)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        // For Testing
        //UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
        
        window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "SplashViewController")
        window?.makeKeyAndVisible()
        
        if !hasSeenOnboarding {
            // First time — show onboarding
            transition(to: "OnboardingViewController", storyboard: storyboard)
        } else if Auth.auth().currentUser != nil {
            // Already logged in — go to home
            AppOpenAdManager.shared.showAd(timeout: 8) { [weak self] in
                self?.transition(to: "MainTabBarController", storyboard: storyboard)
            }
        } else {
            // Seen onboarding but not logged in — show login
            transition(to: "LoginViewController", storyboard: storyboard)
        }
    }
    private func transition(to identifier: String, storyboard: UIStoryboard) {
        guard let window = window else { return }
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve) {
            window.rootViewController = vc
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }
}
