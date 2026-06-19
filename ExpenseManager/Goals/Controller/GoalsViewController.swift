//
//  GoalsViewController.swift
//  ExpenseManager
//
//  Created by Mac on 09/06/2026.
//

import UIKit
import GoogleMobileAds


class GoalsViewController: UIViewController, NativeAdLoaderDelegate, AdLoaderDelegate {
    
    @IBOutlet weak var savingsCardView: UIView!
    @IBOutlet weak var savingsAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var goals: [Goal] = []
    var currentSavings: Double = 0
    var monthlySavings: Double = 0
    var nativeAd: NativeAd?
    var adLoader: AdLoader!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.backgroundColor = UIColor.systemGray6
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        savingsCardView.layer.cornerRadius = 20
        savingsCardView.layer.shadowColor = UIColor.black.cgColor
        savingsCardView.layer.shadowOpacity = 0.08
        savingsCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        savingsCardView.layer.shadowRadius = 8
        savingsCardView.layer.masksToBounds = false
        
        loadNativeAd()
    }
    
    func loadNativeAd() {
        adLoader = AdLoader(
            adUnitID: "ca-app-pub-3940256099942544/3986624511",
            rootViewController: self,
            adTypes: [.native],
            options: nil
        )
        adLoader.delegate = self
        adLoader.load(Request())
    }

    func adLoader(_ adLoader: AdLoader,
                  didFailToReceiveAdWithError error: Error) {
        print("Failed to load ad: \(error.localizedDescription)")
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        print("DEBUG: Native ad loaded ")
        tableView.tableHeaderView = makeNativeAdHeaderView()
    }
    
    func makeNativeAdHeaderView() -> UIView? {
        guard let nativeAd = nativeAd else { return nil }
        
        let adView = NativeAdView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120))
        adView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        adView.layer.cornerRadius = 12
        adView.layer.masksToBounds = true
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = nativeAd.icon?.image
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        adView.addSubview(iconImageView)
        adView.iconView = iconImageView
        
        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 15)
        adView.addSubview(headlineLabel)
        adView.headlineView = headlineLabel
        
        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = nativeAd.body
        bodyLabel.font = UIFont.systemFont(ofSize: 13)
        bodyLabel.textColor = .gray
        bodyLabel.numberOfLines = 2
        adView.addSubview(bodyLabel)
        adView.bodyView = bodyLabel
        
        let ctaButton = UIButton(type: .system)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.setTitle(nativeAd.callToAction, for: .normal)
        ctaButton.backgroundColor = .systemBlue
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.layer.cornerRadius = 8
        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        ctaButton.isUserInteractionEnabled = false
        adView.addSubview(ctaButton)
        adView.callToActionView = ctaButton
        
        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "Ad"
        adBadge.font = UIFont.boldSystemFont(ofSize: 10)
        adBadge.textColor = .white
        adBadge.backgroundColor = .systemOrange
        adBadge.textAlignment = .center
        adBadge.layer.cornerRadius = 3
        adBadge.layer.masksToBounds = true
        adView.addSubview(adBadge)

        let adChoicesView = AdChoicesView()
        adChoicesView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(adChoicesView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            iconImageView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            adChoicesView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 4),
            adChoicesView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -4),
            adChoicesView.widthAnchor.constraint(equalToConstant: 30),
            adChoicesView.heightAnchor.constraint(equalToConstant: 30),
            
            adBadge.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            adBadge.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor),
            adBadge.widthAnchor.constraint(equalToConstant: 30),
            adBadge.heightAnchor.constraint(equalToConstant: 16),
            
            headlineLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            headlineLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
            headlineLabel.trailingAnchor.constraint(equalTo: ctaButton.leadingAnchor, constant: -10),
            
            bodyLabel.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
            bodyLabel.trailingAnchor.constraint(equalTo: headlineLabel.trailingAnchor),
            
            ctaButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            ctaButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            ctaButton.widthAnchor.constraint(equalToConstant: 90),
            ctaButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        adView.adChoicesView = adChoicesView
        adView.layoutIfNeeded()
        adView.nativeAd = nativeAd
        
        return adView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        showEmptyStateIfNeeded()
    }
    
    func showEmptyStateIfNeeded() {
        if goals.isEmpty {
            let label = UILabel()
            label.text = "No goals added yet"
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .gray
            label.font = UIFont.systemFont(ofSize: 16)

            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
    
    
    func loadData() {
        let allExpenses = CoreDataManager.shared.fetchExpenses()
        
        let totalIncome = allExpenses.filter { $0.type == "income" }.reduce(0) {
            $0 + CurrencyManager.shared.convertToBase($1.amount, from: $1.currency ?? "PKR")
        }
        let totalExpense = allExpenses.filter { $0.type == "expense" }.reduce(0) {
            $0 + CurrencyManager.shared.convertToBase($1.amount, from: $1.currency ?? "PKR")
        }
        currentSavings = max(0, totalIncome - totalExpense)
        
        // This month's savings rate
        let calendar = Calendar.current
        let now = Date()
        let thisMonthExpenses = allExpenses.filter {
            calendar.isDate($0.date ?? now, equalTo: now, toGranularity: .month)
        }
        let monthlyIncome = thisMonthExpenses.filter { $0.type == "income" }.reduce(0) {
            $0 + CurrencyManager.shared.convertToBase($1.amount, from: $1.currency ?? "PKR")
        }
        let monthlyExpense = thisMonthExpenses.filter { $0.type == "expense" }.reduce(0) {
            $0 + CurrencyManager.shared.convertToBase($1.amount, from: $1.currency ?? "PKR")
        }
        monthlySavings = max(0, monthlyIncome - monthlyExpense)
        
        // Convert only for display here
        let symbol = CurrencyManager.shared.currencySymbol()
        let displaySavings = CurrencyManager.shared.convertAmount(currentSavings, from: "PKR")
        savingsAmountLabel.text = "\(symbol) \(String(format: "%.2f", displaySavings))"
        
        goals = Array(CoreDataManager.shared.fetchGoals().prefix(3))
        tableView.reloadData()
    }
    
    
    @IBAction func addGoalTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AddGoalViewController") as? AddGoalViewController else { return }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @IBAction func showAllGoalsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AllGoalsViewController") as? AllGoalsViewController else {
            return
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
    
// MARK: - TableView
extension GoalsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath) as! GoalCell
        cell.configure(goal: goals[indexPath.row], currentSavings: currentSavings, monthlySavings: monthlySavings)
        return cell
    }
}
