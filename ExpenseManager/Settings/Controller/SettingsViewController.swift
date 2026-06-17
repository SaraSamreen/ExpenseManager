//
//  SettingsViewController.swift
//  ExpenseManager
//
//  Created by Mac on 16/06/2026.
//

import FirebaseAuth
import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var currencyIconBack: UIView!
    @IBOutlet weak var cloudIconBack: UIView!
    @IBOutlet weak var cloudSwitch: UISwitch!
    @IBOutlet weak var currencyValueLabel: UILabel!
    @IBOutlet weak var cloudSyncStatusLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saved = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "PKR"
        currencyValueLabel.text = "\(saved)"
        
        cloudSwitch.isOn = UserDefaults.standard.bool(forKey: "cloudSyncEnabled")
        
        if let user = Auth.auth().currentUser {
            nameLabel.text = user.displayName ?? user.email ?? "User"
        }
        
        setupUI()
    }

   func setupUI() {
        // Profile image circle
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true

        // Card shadow
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 6
        cardView.layer.masksToBounds = false

        // Icon backgrounds
        currencyIconBack.layer.cornerRadius = 10
        currencyIconBack.clipsToBounds = true
        cloudIconBack.layer.cornerRadius = 10
        cloudIconBack.clipsToBounds = true
        
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
       
       // Logout button styling
       logoutButton.layer.cornerRadius = 12
       logoutButton.clipsToBounds = true
       logoutButton.backgroundColor = UIColor(red: 0.95, green: 0.25, blue: 0.3, alpha: 1)
       logoutButton.setTitleColor(.white, for: .normal)
       logoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

       logoutButton.layer.shadowColor = UIColor.black.cgColor
       logoutButton.layer.shadowOpacity = 0.1
       logoutButton.layer.shadowOffset = CGSize(width: 0, height: 2)
       logoutButton.layer.shadowRadius = 4
       logoutButton.layer.masksToBounds = false
        
        view.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1)
    }

    @IBAction func switchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "cloudSyncEnabled")
    
        FirestoreManager.shared.saveSyncPreference(enabled: sender.isOn)
        
        if sender.isOn {
            FirestoreManager.shared.syncAll()
            showSyncAlert()
            cloudSyncStatusLabel.text = "Enabled"
        } else {
            cloudSyncStatusLabel.text = "Disabled"
        }
    }
    
    func showSyncAlert() {
        let alert = UIAlertController(title: "Cloud Sync", message: "Your data is being synced to cloud!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func currencyTapped(_ sender: Any) {
        let currencies = [
            ("USD", "US Dollar"),
            ("EUR", "Euro"),
            ("PKR", "Pakistani Rupee"),
            ("INR", "Indian Rupee"),
            ("AED", "UAE Dirham"),
        ]
        
        let alert = UIAlertController(title: "Select Currency", message: nil, preferredStyle: .actionSheet)
        
        for (code, name) in currencies {
            alert.addAction(UIAlertAction(title: "\(code) - \(name)", style: .default) { [weak self] _ in
                self?.currencyValueLabel.text = "\(code) (\(name))"
                UserDefaults.standard.set(code, forKey: "selectedCurrency")
                FirestoreManager.shared.saveCurrencyPreference(currency: code)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    func performLogout() {
        do {
            try Auth.auth().signOut()
            
            UserDefaults.standard.removeObject(forKey: "selectedCurrency")
            UserDefaults.standard.removeObject(forKey: "cloudSyncEnabled")
            
            if let storyboard = self.storyboard {
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
            }
            
        } catch let signOutError as NSError {
            let errorAlert = UIAlertController(title: "Error", message: "Failed to log out: \(signOutError.localizedDescription)", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(errorAlert, animated: true)
        }
    }
}
