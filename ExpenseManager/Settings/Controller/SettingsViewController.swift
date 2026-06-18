//
//  SettingsViewController.swift
//  ExpenseManager
//
//  Created by Mac on 16/06/2026.
//

import GoogleMobileAds
import FirebaseAuth
import UIKit

class SettingsViewController: UIViewController {
    
    var rewardedAd: RewardedAd?

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var currencyIconBack: UIView!
    @IBOutlet weak var cloudIconBack: UIView!
    @IBOutlet weak var cloudSwitch: UISwitch!
    @IBOutlet weak var currencyValueLabel: UILabel!
    @IBOutlet weak var cloudSyncStatusLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var downloadIconBack: UIView!
    @IBOutlet weak var downloadentrieslbl: UILabel!
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saved = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "PKR"
        currencyValueLabel.text = "\(saved)"
        
        cloudSwitch.isOn = UserDefaults.standard.bool(forKey: "cloudSyncEnabled")
        
        if let user = Auth.auth().currentUser {
            nameLabel.text = user.displayName ?? user.email ?? "User"
        }
        
        setupUI()
        loadRewardedAd()
    }
    
    func loadRewardedAd() {
        let request = Request()
        RewardedAd.load(
            with: "ca-app-pub-3940256099942544/1712485313", // TEST ID for now
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                print("DEBUG: Rewarded ad failed to load — \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            print("DEBUG: Rewarded ad loaded successfully ✅")
        }
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
    
    @IBAction func exportTapped(_ sender: Any) {
        
        let alert = UIAlertController(
            title: "Export Data",
            message: "What do you want to export?",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Expenses", style: .default, handler: { [weak self] _ in
            self?.requestRewardThenExport(type: "expense")
        }))

        alert.addAction(UIAlertAction(title: "Income", style: .default, handler: { [weak self] _ in
            self?.requestRewardThenExport(type: "income")
        }))

        alert.addAction(UIAlertAction(title: "Both", style: .default, handler: { [weak self] _ in
            self?.requestRewardThenExport(type: "both")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func requestRewardThenExport(type: String) {
        guard let rewardedAd = rewardedAd else {
            let alert = UIAlertController(
                title: "Ad Not Ready",
                message: "Please try again in a moment.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
            loadRewardedAd() // try loading again for next time
            return
        }
        
        rewardedAd.present(from: self) { [weak self] in
            let reward = rewardedAd.adReward
            print("DEBUG: User earned reward: \(reward.amount) \(reward.type)")
            
            self?.exportCSV(type: type)
            self?.loadRewardedAd() // load the next one for next time
        }
    }
    
    
    func exportCSV(type: String) {

        var expenses: [Expense] = []

        switch type {
        case "expense":
            expenses = CoreDataManager.shared.fetchExpenses()

        case "income":
            expenses = CoreDataManager.shared.fetchIncome()

        case "both":
            expenses = CoreDataManager.shared.fetchExpenses()
            expenses += CoreDataManager.shared.fetchIncome()

        default:
            break
        }

        guard !expenses.isEmpty else {

            let alert = UIAlertController(
                title: "No Data",
                message: "There are no entries to export.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)

            return
        }

        var csvText = "Title,Amount,Type,Category,Currency,Date\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for expense in expenses {

            let title = expense.title ?? ""
            let amount = String(expense.amount)
            let type = expense.type ?? ""
            let category = expense.category ?? ""
            let currency = expense.currency ?? ""
            let date = formatter.string(from: expense.date ?? Date())

            let row = "\"\(title)\",\(amount),\"\(type)\",\"\(category)\",\"\(currency)\",\"\(date)\"\n"

            csvText.append(row)
        }

        let fileName = "ExpenseReport.csv"

        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)

        do {

            try csvText.write(
                to: path,
                atomically: true,
                encoding: .utf8
            )

            let activityVC = UIActivityViewController(
                activityItems: [path],
                applicationActivities: nil
            )

            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self.view
            }

            present(activityVC, animated: true)

        } catch {

            let alert = UIAlertController(
                title: "Export Failed",
                message: error.localizedDescription,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func performLogout() {
        do {
            try Auth.auth().signOut()
            
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
