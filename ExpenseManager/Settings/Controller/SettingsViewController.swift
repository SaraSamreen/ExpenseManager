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
}
