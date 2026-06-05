import UIKit

class TransactionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var typeBtn = UIButton(type: .system)
    var monthBtn = UIButton(type: .system)
    
    var allExpenses: [Expense] = []
    var expenses: [Expense] = []
    var selectedType: String = "All"
    var selectedMonth: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func setupButtons() {
        // Type button
        typeBtn.setTitle("Type ▾", for: .normal)
        typeBtn.setTitleColor(.label, for: .normal)
        typeBtn.backgroundColor = UIColor(white: 0.93, alpha: 1)
        typeBtn.layer.cornerRadius = 8
        typeBtn.layer.masksToBounds = true
        typeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        typeBtn.addTarget(self, action: #selector(typeBtnTapped), for: .touchUpInside)
        typeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typeBtn)
        
        // Month button
        monthBtn.setTitle("Month ▾", for: .normal)
        monthBtn.setTitleColor(.label, for: .normal)
        monthBtn.backgroundColor = UIColor(white: 0.93, alpha: 1)
        monthBtn.layer.cornerRadius = 8
        monthBtn.layer.masksToBounds = true
        monthBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        monthBtn.addTarget(self, action: #selector(monthBtnTapped), for: .touchUpInside)
        monthBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(monthBtn)
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Type button
            typeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            typeBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeBtn.widthAnchor.constraint(equalToConstant: 100),
            typeBtn.heightAnchor.constraint(equalToConstant: 36),
            
            // Month button
            monthBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            monthBtn.leadingAnchor.constraint(equalTo: typeBtn.trailingAnchor, constant: 12),
            monthBtn.widthAnchor.constraint(equalToConstant: 100),
            monthBtn.heightAnchor.constraint(equalToConstant: 36),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: typeBtn.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func loadData() {
        allExpenses = CoreDataManager.shared.fetchExpenses()
        applyFilter()
    }
    
    func applyFilter() {
        var filtered = allExpenses
        
        if selectedType != "All" {
            filtered = filtered.filter { $0.type == selectedType.lowercased() }
        }
        
        if selectedMonth != 0 {
            filtered = filtered.filter {
                let month = Calendar.current.component(.month, from: $0.date ?? Date())
                return month == selectedMonth
            }
        }
        
        expenses = filtered
        tableView.reloadData()
    }
    
    @objc func typeBtnTapped() {
        let alert = UIAlertController(title: "Filter by Type", message: nil, preferredStyle: .actionSheet)
        ["All", "Income", "Expense"].forEach { type in
            alert.addAction(UIAlertAction(title: type, style: .default) { [weak self] _ in
                self?.selectedType = type
                self?.typeBtn.setTitle("\(type) ▾", for: .normal)
                self?.applyFilter()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func monthBtnTapped() {
        let alert = UIAlertController(title: "Filter by Month", message: nil, preferredStyle: .actionSheet)
        let months = ["All", "January", "February", "March", "April", "May", "June",
                      "July", "August", "September", "October", "November", "December"]
        months.enumerated().forEach { index, month in
            alert.addAction(UIAlertAction(title: month, style: .default) { [weak self] _ in
                self?.selectedMonth = index
                self?.monthBtn.setTitle("\(month) ▾", for: .normal)
                self?.applyFilter()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - TableView
extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        let expense = expenses[indexPath.row]
        
        cell.titleLabel.text = expense.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        cell.dateLabel.text = formatter.string(from: expense.date ?? Date())
        
        let prefix = expense.type == "income" ? "+" : "-"
        cell.amountLabel.text = "\(prefix)Rs \(String(format: "%.2f", expense.amount))"
        cell.amountLabel.textColor = .label
        return cell
    }
}
