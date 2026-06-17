//
//  AllGoalsViwController.swift
//  ExpenseManager
//
//  Created by Mac on 09/06/2026.
//

import UIKit

class AllGoalsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var goals: [Goal] = []
    var currentSavings: Double = 0
    var monthlySavings: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Your Goals"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.backgroundColor = UIColor.systemGray6
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addGoalTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
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
        
        goals = CoreDataManager.shared.fetchGoals()
        tableView.reloadData()
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
    
    @objc func addGoalTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AddGoalViewController") as? AddGoalViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func backTapped() {
        dismiss(animated: true)
    }
}

// MARK: - TableView
extension AllGoalsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = GoalDetailViewController()
        vc.goal = goals[indexPath.row]
        vc.onDismiss = { [weak self] in
            self?.loadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete Goal", message: "Are you sure you want to delete this goal?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                CoreDataManager.shared.deleteGoal(self.goals[indexPath.row])
                self.goals.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
}
