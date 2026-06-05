//
//  AddExpenseViewController.swift
//  ExpenseManager
//
//  Created by Mac on 02/06/2026.
//

import UIKit

class AddExpenseViewController: UIViewController {
    
    @IBOutlet weak var incomeBtn: UIButton!
    @IBOutlet weak var expenseBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedType = "income"
    var selectedDate = Date()
    var selectedCategory = ""
    
    var incomeCategories: [String] = []
    var expenseCategories: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        selectType("income")
        incomeBtn.layer.cornerRadius = 16
        expenseBtn.layer.cornerRadius = 16
        incomeBtn.clipsToBounds = true
        expenseBtn.clipsToBounds = true
        
        loadCategories()
    }
    
    func loadCategories() {
        incomeCategories = CoreDataManager.shared.fetchCategories(type: "income")
        expenseCategories = CoreDataManager.shared.fetchCategories(type: "expense")
    }

    func selectType(_ type: String) {
        selectedType = type
        if type == "income" {
            incomeBtn.backgroundColor = .systemBlue
            incomeBtn.setTitleColor(.white, for: .normal)
            expenseBtn.backgroundColor = .white
            expenseBtn.setTitleColor(.black, for: .normal)
        } else {
            expenseBtn.backgroundColor = .systemBlue
            expenseBtn.setTitleColor(.white, for: .normal)
            incomeBtn.backgroundColor = .white
            incomeBtn.setTitleColor(.black, for: .normal)
        }
        selectedCategory = ""
        tableView.reloadData()
    }

    @IBAction func incomeBtnTapped(_ sender: UIButton) {
        selectType("income")
    }

    @IBAction func expenseBtnTapped(_ sender: UIButton) {
        selectType("expense")
    }
}

// MARK: - TableView
extension AddExpenseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell") as! DatePickerCell
            cell.setDate(selectedDate)
            cell.onDateTapped = { [weak self] in
                self?.showDatePicker()
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! TextFieldCell
            cell.titleLabel.text = selectedType == "income" ? "Income Title" : "Expense Title"
            cell.textField.placeholder = selectedType == "income" ? "Enter income title" : "Enter expense title"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmountCell") as! TextFieldCell
            cell.titleLabel.text = "Amount"
            cell.textField.placeholder = "Enter amount"
            cell.textField.keyboardType = .decimalPad
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
            let cats = selectedType == "income" ? incomeCategories : expenseCategories
            let label = selectedType == "income" ? "Income Category" : "Expense Category"
            cell.configure(
                title: label,
                categories: cats,
                selected: selectedCategory,
                onAdd: { [weak self] in self?.addCategory() }
            ) { [weak self] category in
                self?.selectedCategory = category
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaveButtonCell") as! SaveButtonCell
            let title = selectedType == "income" ? "ADD INCOME" : "ADD EXPENSE"
            cell.saveButton.setTitle(title, for: .normal)
            cell.onSave = { [weak self] in self?.saveEntry() }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showDatePicker()
        }
    }
}

// MARK: - Save & Date
extension AddExpenseViewController {

    
    func addCategory() {
        let alert = UIAlertController(title: "Add Category", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "Category name" }
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            guard let self = self else { return }
            CoreDataManager.shared.saveCategory(name: name, type: self.selectedType)
            self.loadCategories()
            self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func showDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.date = selectedDate
        
        let alert = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8)
        ])
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.selectedDate = picker.date
            self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func saveEntry() {
        guard let titleCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TextFieldCell,
              let amountCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TextFieldCell,
              let title = titleCell.textField.text, !title.isEmpty,
              let amountText = amountCell.textField.text,
              let amount = Double(amountText) else {
            showAlert(message: "Please fill in all fields")
            return
        }

        CoreDataManager.shared.saveExpense(
            title: title,
            amount: amount,
            date: selectedDate,
            type: selectedType,
            category: selectedCategory
        )
        // Clear fields
            titleCell.textField.text = ""
            amountCell.textField.text = ""
            selectedCategory = ""
            selectedDate = Date()
            
            tableView.reloadData()
            showAlert(message: "Saved successfully!")
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
