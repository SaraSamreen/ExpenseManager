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

    // MARK: - Ad properties
    var rewardedAd: RewardedAd?
    var didEarnReward = false
    var loadingIndicator: UIActivityIndicatorView?

    // MARK: - Outlets
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

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemBlue

        let savedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "PKR"
        currencyValueLabel.text = savedCurrency

        let cloudSyncEnabled = UserDefaults.standard.bool(forKey: "cloudSyncEnabled")
        cloudSwitch.isOn = cloudSyncEnabled
        cloudSwitch.isEnabled = !cloudSyncEnabled
        cloudSyncStatusLabel.text = cloudSyncEnabled ? "Enabled" : "Disabled"
        
        if let user = Auth.auth().currentUser {
            nameLabel.text = user.displayName ?? user.email ?? "User"
        }

        setupUI()
        loadRewardedAd()
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Ad loading
    func loadRewardedAd() {
        let request = Request()
        RewardedAd.load(
            with: "ca-app-pub-3940256099942544/1712485313",
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                print("DEBUG: Rewarded ad failed to load — \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            print("DEBUG: Rewarded ad loaded successfully")
        }
    }

    func showExportLoadingIndicator() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        loadingIndicator = indicator
    }

    func hideExportLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
    }

    // MARK: - UI setup
    func setupUI() {
        // Profile image circle
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor

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

    // MARK: - Cloud Sync
    @IBAction func switchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "cloudSyncEnabled")
        FirestoreManager.shared.saveSyncPreference(enabled: sender.isOn)

        if sender.isOn {
            FirestoreManager.shared.syncAll()
            showSyncAlert()
            cloudSyncStatusLabel.text = "Enabled"
            sender.isEnabled = false
        } else {
            cloudSyncStatusLabel.text = "Disabled"
        }
    }

    func showSyncAlert() {
        let alert = UIAlertController(
            title: "Cloud Sync",
            message: "Your data is being synced to cloud!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Currency
    @IBAction func currencyTapped(_ sender: Any) {
        let currencies = [
            ("USD", "US Dollar"),
            ("EUR", "Euro"),
            ("PKR", "Pakistani Rupee"),
            ("INR", "Indian Rupee"),
            ("AED", "UAE Dirham")
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

    // MARK: - Logout
    @IBAction func logoutTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })

        present(alert, animated: true)
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
            let errorAlert = UIAlertController(
                title: "Error",
                message: "Failed to log out: \(signOutError.localizedDescription)",
                preferredStyle: .alert
            )
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(errorAlert, animated: true)
        }
    }

    // MARK: - Export (rewarded-ad gated)
    @IBAction func exportTapped(_ sender: Any) {
        requestRewardThenExport()
    }

    func requestRewardThenExport() {
        showExportLoadingIndicator()

        if let rewardedAd = rewardedAd {
            // Ad already loaded, present
            presentRewardedAd(rewardedAd)
            return
        }

        var didTimeOut = false

        let timeoutWork = DispatchWorkItem { [weak self] in
            didTimeOut = true
            self?.hideExportLoadingIndicator()

            let alert = UIAlertController(
                title: "Ad Not Ready",
                message: "Try Again",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: timeoutWork)

        let request = Request()
        RewardedAd.load(
            with: "ca-app-pub-3940256099942544/1712485313",
            request: request
        ) { [weak self] ad, error in
            timeoutWork.cancel()
            guard !didTimeOut else { return }

            if let error = error {
                print("DEBUG: Rewarded ad failed to load — \(error.localizedDescription)")
                self?.hideExportLoadingIndicator()

                let alert = UIAlertController(
                    title: "Ad Not Ready",
                    message: "Please try again in a moment.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
                return
            }

            guard let ad = ad, let self = self else { return }
            self.rewardedAd = ad
            self.presentRewardedAd(ad)
        }
    }

 
    func presentRewardedAd(_ rewardedAd: RewardedAd) {
        didEarnReward = false
        rewardedAd.fullScreenContentDelegate = self

        rewardedAd.present(from: self) { [weak self] in
            let reward = rewardedAd.adReward
            print("DEBUG: User earned reward: \(reward.amount) \(reward.type)")
            self?.didEarnReward = true
        }

        hideExportLoadingIndicator()
    }

    func exportAllEntriesCSV() {
        let allEntries = CoreDataManager.shared.fetchExpenses()

        guard !allEntries.isEmpty else {
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

        let rowDateFormatter = DateFormatter()
        rowDateFormatter.dateFormat = "yyyy-MM-dd"

        for entry in allEntries {
            let title = entry.title ?? ""
            let amount = String(entry.amount)
            let type = entry.type ?? ""
            let category = entry.category ?? ""
            let currency = entry.currency ?? ""
            let date = rowDateFormatter.string(from: entry.date ?? Date())

            csvText.append("\"\(title)\",\(amount),\"\(type)\",\"\(category)\",\"\(currency)\",\"\(date)\"\n")
        }

        let fileDateFormatter = DateFormatter()
        fileDateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStamp = fileDateFormatter.string(from: Date())
        let fileName = "ExpenseManager_AllEntries_\(dateStamp).csv"

        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)

            let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
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
}

// MARK: - FullScreenContentDelegate
extension SettingsViewController: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        loadRewardedAd()

        if didEarnReward {
            exportAllEntriesCSV()
        } else {
            let alert = UIAlertController(
                title: "Ad Skipped",
                message: "Please watch the full ad to unlock export.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("DEBUG: Rewarded ad failed to present — \(error.localizedDescription)")

        let alert = UIAlertController(
            title: "Ad Error",
            message: "Couldn't show the ad right now. Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)

        loadRewardedAd()
    }
}
