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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow(windowScene: windowScene)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        // For Testing
        UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")

        
        if !hasSeenOnboarding {
            // First time — show onboarding
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController")
        } else if Auth.auth().currentUser != nil {
            // Already logged in — go to home
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        } else {
            // Seen onboarding but not logged in — show login
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        }
        
        window?.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }
}
