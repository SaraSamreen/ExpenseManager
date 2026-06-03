//
//  HomeViewController.swift
//  ExpenseManager
//
//  Created by Mac on 01/06/2026.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutBtnClicked(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            // Go back to login
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        } catch {
            print("Error signing out: \(error)")
        }
    }
}
