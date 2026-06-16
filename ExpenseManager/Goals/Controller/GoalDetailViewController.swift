//
//  GoalDetailViewController.swift
//  ExpenseManager
//
//  Created by Mac on 10/06/2026.
//

import UIKit

class GoalDetailViewController: UIViewController {
    
    var goal: Goal?
    var onDismiss: (() -> Void)?
    
    let titleLabel = UILabel()
    let amountLabel = UILabel()
    let contributionLabel = UILabel()
    let deadlineLabel = UILabel()
    let titleField = UITextField()
    let amountField = UITextField()
    let contributionField = UITextField()
    let deadlineField = UITextField()
    let saveBtn = UIButton(type: .system)
    let deleteBtn = UIButton(type: .system)
    var selectedDeadline = Date()
    var selectedContributionType = "Yearly"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Edit Goal"
        setupUI()
        populateData()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func setupUI() {
        
        // Labels
        [titleLabel, amountLabel, contributionLabel, deadlineLabel].forEach {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .secondaryLabel
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        titleLabel.text = "Goal Title"
        amountLabel.text = "Amount"
        contributionLabel.text = "Contribution Type"
        deadlineLabel.text = "Deadline"
        
        // Title Field
        titleField.borderStyle = .roundedRect
        titleField.placeholder = "Goal Title"
        titleField.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount Field
        amountField.borderStyle = .roundedRect
        amountField.placeholder = "Amount"
        amountField.keyboardType = .decimalPad
        amountField.translatesAutoresizingMaskIntoConstraints = false
        
        // Contribution Field
        contributionField.borderStyle = .roundedRect
        contributionField.placeholder = "Contribution Type"
        contributionField.inputView = UIView()
        contributionField.translatesAutoresizingMaskIntoConstraints = false
        let arrow = UIImageView(image: UIImage(systemName: "chevron.down"))
        arrow.tintColor = .gray
        arrow.frame = CGRect(x: 0, y: 0, width: 35, height: 20)
        arrow.contentMode = .scaleAspectFit
        contributionField.rightView = arrow
        contributionField.rightViewMode = .always
        let tap = UITapGestureRecognizer(target: self, action: #selector(showContributionPicker))
        contributionField.addGestureRecognizer(tap)
        
        // Deadline Field
        deadlineField.borderStyle = .roundedRect
        deadlineField.placeholder = "Deadline"
        deadlineField.inputView = UIView()
        deadlineField.translatesAutoresizingMaskIntoConstraints = false
        let calContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        let calIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calIcon.tintColor = .gray
        calIcon.frame = CGRect(x: 4, y: 0, width: 24, height: 20)
        calIcon.contentMode = .scaleAspectFit
        calContainer.addSubview(calIcon)
        deadlineField.rightView = calContainer
        deadlineField.rightViewMode = .always
        let deadlineTap = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
        deadlineField.addGestureRecognizer(deadlineTap)
        
        // Save Button
        saveBtn.setTitle("Save Changes", for: .normal)
        saveBtn.backgroundColor = .systemBlue
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.layer.cornerRadius = 10
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        // Delete Button
        deleteBtn.setTitle("Delete Goal", for: .normal)
        deleteBtn.backgroundColor = .systemRed
        deleteBtn.setTitleColor(.white, for: .normal)
        deleteBtn.layer.cornerRadius = 10
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        view.addSubview(titleField)
        view.addSubview(amountField)
        view.addSubview(contributionField)
        view.addSubview(deadlineField)
        view.addSubview(saveBtn)
        view.addSubview(deleteBtn)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleField.heightAnchor.constraint(equalToConstant: 50),

            amountLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            amountField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 6),
            amountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            amountField.heightAnchor.constraint(equalToConstant: 50),

            contributionLabel.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 16),
            contributionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            contributionField.topAnchor.constraint(equalTo: contributionLabel.bottomAnchor, constant: 6),
            contributionField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contributionField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contributionField.heightAnchor.constraint(equalToConstant: 50),

            deadlineLabel.topAnchor.constraint(equalTo: contributionField.bottomAnchor, constant: 16),
            deadlineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            deadlineField.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor, constant: 6),
            deadlineField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deadlineField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deadlineField.heightAnchor.constraint(equalToConstant: 50),

            saveBtn.topAnchor.constraint(equalTo: deadlineField.bottomAnchor, constant: 30),
            saveBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveBtn.heightAnchor.constraint(equalToConstant: 50),

            deleteBtn.topAnchor.constraint(equalTo: saveBtn.bottomAnchor, constant: 16),
            deleteBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteBtn.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func populateData() {
        guard let goal = goal else { return }
        titleField.text = goal.title
        amountField.text = String(format: "%.0f", goal.amount)
        contributionField.text = goal.contributionType ?? "Yearly"
        selectedContributionType = goal.contributionType ?? "Yearly"
        selectedDeadline = goal.deadline ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        deadlineField.text = formatter.string(from: selectedDeadline)
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showContributionPicker() {
        let alert = UIAlertController(title: "Contribution Type", message: nil, preferredStyle: .actionSheet)
        ["Daily", "Weekly", "Monthly", "Yearly"].forEach { type in
            alert.addAction(UIAlertAction(title: type, style: .default) { [weak self] _ in
                self?.selectedContributionType = type
                self?.contributionField.text = type
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
        
        let alert = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
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
            self?.deadlineField.text = formatter.string(from: picker.date)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // savetapped
    @objc func saveTapped() {
        guard let goal = goal else { return }

        guard let title = titleField.text, !title.isEmpty else {
            showAlert(message: "Please enter a goal title")
            return
        }

        guard let amountText = amountField.text, !amountText.isEmpty else {
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

        goal.title = title
        goal.amount = amount
        goal.contributionType = selectedContributionType
        goal.deadline = selectedDeadline
        goal.icon = CoreDataManager.shared.iconName(for: title)
        CoreDataManager.shared.saveContext()
        onDismiss?()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteTapped() {
        let alert = UIAlertController(title: "Delete Goal", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let goal = self?.goal else { return }
            CoreDataManager.shared.deleteGoal(goal)
            self?.onDismiss?()
            self?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // alert helper
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
