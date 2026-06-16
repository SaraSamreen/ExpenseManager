//
//  AddGoalViewController.swift
//  ExpenseManager
//
//  Created by Mac on 09/06/2026.
//

import UIKit

class AddGoalViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var contributionTextField: UITextField!
    @IBOutlet weak var deadlineTextField: UITextField!
    
    var selectedContributionType = "Yearly"
    var selectedDeadline = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Goal"
        setupUI()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)
        
        [titleTextField, amountTextField, contributionTextField, deadlineTextField].forEach {
            styleField($0!)
        }
        
        amountTextField.keyboardType = .decimalPad
        
        // Deadline
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        deadlineTextField.text = formatter.string(from: selectedDeadline)
        deadlineTextField.inputView = UIView()
        let deadlineTap = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
        deadlineTextField.addGestureRecognizer(deadlineTap)
        addRightIcon(to: deadlineTextField, systemName: "calendar")
        
        // Contribution
        contributionTextField.text = "Yearly"
        contributionTextField.inputView = UIView()
        let contributionTap = UITapGestureRecognizer(target: self, action: #selector(showContributionPicker))
        contributionTextField.addGestureRecognizer(contributionTap)
        addRightIcon(to: contributionTextField, systemName: "chevron.down")
    }
    
    func styleField(_ textField: UITextField) {
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor(white: 0.88, alpha: 1).cgColor
        textField.layer.borderWidth = 1
        textField.borderStyle = .none
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
        textField.leftView = padding
        textField.leftViewMode = .always
    }
    
    func addRightIcon(to textField: UITextField, systemName: String) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        let icon = UIImageView(image: UIImage(systemName: systemName))
        icon.tintColor = .systemBlue
        icon.frame = CGRect(x: 8, y: 12, width: 20, height: 20)
        icon.contentMode = .scaleAspectFit
        container.addSubview(icon)
        textField.rightView = container
        textField.rightViewMode = .always
    }
    
    @objc func backTapped() {
        dismiss(animated: true)
    }
    
    @objc func showContributionPicker() {
        let alert = UIAlertController(title: "Contribution Type", message: nil, preferredStyle: .actionSheet)
        ["Daily", "Weekly", "Monthly", "Yearly"].forEach { type in
            alert.addAction(UIAlertAction(title: type, style: .default) { [weak self] _ in
                self?.selectedContributionType = type
                self?.contributionTextField.text = type
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func showDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.date = selectedDeadline
        
        let alert = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        picker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8)
        ])
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.selectedDeadline = picker.date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            self?.deadlineTextField.text = formatter.string(from: picker.date)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func addGoalTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "Please enter a goal title")
            return
        }
        guard let amountText = amountTextField.text, !amountText.isEmpty else {
            showAlert(message: "Please enter an amount")
            return
        }
        guard let amount = Double(amountText) else {
            showAlert(message: "Amount must be a valid number")
            return
        }
        
        guard amount > 0 else {
            showAlert(message: "Amount must be greater than 0")
            return
        }
        
        guard amount <= 10_000_000 else {
            showAlert(message: "Amount seems too large. Please check and try again")
            return
        }
        guard selectedDeadline > Date() else {
            showAlert(message: "Deadline must be in the future")
            return
        }
        
        let icon = CoreDataManager.shared.iconName(for: title)
        CoreDataManager.shared.saveGoal(
            title: title,
            amount: amount,
            deadline: selectedDeadline,
            contributionType: selectedContributionType,
            icon: icon
        )
        dismiss(animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
