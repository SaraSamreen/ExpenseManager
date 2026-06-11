//
//  GoalsViewController.swift
//  ExpenseManager
//
//  Created by Mac on 09/06/2026.
//

import UIKit


class GoalsViewController: UIViewController {
    
    @IBOutlet weak var savingsCardView: UIView!
    @IBOutlet weak var savingsAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var goals: [Goal] = []
    var currentSavings: Double = 0
    var monthlySavings: Double = 0
    
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
        let totalIncome = allExpenses.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
        let totalExpense = allExpenses.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
        currentSavings = max(0, totalIncome - totalExpense)
        
        // This month's savings rate
        let calendar = Calendar.current
        let now = Date()
        let thisMonthExpenses = allExpenses.filter {
            calendar.isDate($0.date ?? now, equalTo: now, toGranularity: .month)
        }
        let monthlyIncome = thisMonthExpenses.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
        let monthlyExpense = thisMonthExpenses.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
        monthlySavings = max(0, monthlyIncome - monthlyExpense)
        
        savingsAmountLabel.text = "Rs \(String(format: "%.2f", currentSavings))"
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
