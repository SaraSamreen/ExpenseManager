//
//  HomeViewController.swift
//  ExpenseManager
//
//  Created by Mac on 01/06/2026.
//

import UIKit
import FirebaseAuth

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    let cards = ["Total Income", "Total Expense"]
    var expenses: [Expense] = []
    var totalIncome: Double = 0
    var totalExpense: Double = 0
    var selectedCardIndex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1)
        tableView.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1)
        collectionView.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 20
            layout.minimumLineSpacing = 20
            
            selectedCardIndex = 0
        }
        
        tableView.backgroundColor = UIColor.systemGray6
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.separatorStyle = .none
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    @objc func openSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadData() {
        let allExpenses = CoreDataManager.shared.fetchExpenses()
        totalIncome = allExpenses.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
        totalExpense = allExpenses.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
        
        if selectedCardIndex == 0 {
            expenses = Array(allExpenses.filter { $0.type == "income" }.prefix(3))
        } else if selectedCardIndex == 1 {
            expenses = Array(allExpenses.filter { $0.type == "expense" }.prefix(3))
        } else {
            expenses = Array(allExpenses.prefix(3))
        }
        
        collectionView.reloadData()
        tableView.reloadData()
        showEmptyStateIfNeeded()
    }
    func showEmptyStateIfNeeded() {
        if expenses.isEmpty {
            let label = UILabel()
            label.text = "No entries found"
            label.textAlignment = .center
            label.textColor = .gray
            label.font = UIFont.systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundView = label
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
            ])
        } else {
            tableView.backgroundView = nil
        }
    }
}

// MARK: - CollectionView
extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseCardCell", for: indexPath) as! ExpenseCardCell
        cell.titleLabel.text = cards[indexPath.row]
        cell.amountLabel.text = indexPath.row == 0 ? "\(CurrencyManager.shared.currencySymbol()) \(String(format: "%.2f", CurrencyManager.shared.convertAmount(totalIncome)))" : "\(CurrencyManager.shared.currencySymbol()) \(String(format: "%.2f", CurrencyManager.shared.convertAmount(totalExpense)))"
        cell.configure(isSelected: selectedCardIndex == indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedCardIndex == indexPath.row {
            selectedCardIndex = nil
        } else {
            selectedCardIndex = indexPath.row
        }
        loadData()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let padding: CGFloat = 16 * 2
        let spacing: CGFloat = 20

        let width = (collectionView.frame.width - padding - spacing) / 2

        return CGSize(width: width, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

// MARK: - TableView
extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseEntryCell", for: indexPath) as! ExpenseEntryCell
        let expense = expenses[indexPath.row]
        
        cell.titleLabel.text = expense.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        cell.dateLabel.text = formatter.string(from: expense.date ?? Date())
        
        cell.amountLabel.text = "\(CurrencyManager.shared.currencySymbol()) \(String(format: "%.2f", CurrencyManager.shared.convertAmount(expense.amount)))"

        if expense.type == "income" {
            cell.amountLabel.textColor = .systemGreen
        } else {
            cell.amountLabel.textColor = .systemRed
        }
        
        return cell
    }
}
