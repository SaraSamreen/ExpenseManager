

import GoogleMobileAds
import UIKit

class TransactionsViewController: UIViewController, NativeAdLoaderDelegate, AdLoaderDelegate {
    
    var nativeAd: NativeAd?
    var adLoader: AdLoader!
    
    @IBOutlet weak var tableView: UITableView!
    
    var typeBtn = UIButton(type: .system)
    var monthBtn = UIButton(type: .system)
    var clearFilterBtn = UIButton(type: .system)
    
    var allExpenses: [Expense] = []
    var expenses: [Expense] = []
    var selectedType: String = "All"
    var selectedDate: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        setupButtons()
        
        tableView.backgroundColor = UIColor.systemGray6
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        showEmptyStateIfNeeded()
    }
    
    //UI FOR THE NATIVE AD
    
    func makeNativeAdHeaderView() -> UIView? {
        guard let nativeAd = nativeAd else { return nil }
        
        let adView = NativeAdView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120))
        adView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        adView.layer.cornerRadius = 12
        adView.layer.masksToBounds = true
        
        // Icon
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = nativeAd.icon?.image
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        adView.addSubview(iconImageView)
        adView.iconView = iconImageView
        
        // Headline
        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 15)
        adView.addSubview(headlineLabel)
        adView.headlineView = headlineLabel
        
        // Body
        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = nativeAd.body
        bodyLabel.font = UIFont.systemFont(ofSize: 13)
        bodyLabel.textColor = .gray
        bodyLabel.numberOfLines = 2
        adView.addSubview(bodyLabel)
        adView.bodyView = bodyLabel
        
        // Call to action button
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
        
        // "Ad" label
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
        monthBtn.setTitle("Date ▾", for: .normal)
        monthBtn.setTitleColor(.label, for: .normal)
        monthBtn.backgroundColor = UIColor(white: 0.93, alpha: 1)
        monthBtn.layer.cornerRadius = 8
        monthBtn.layer.masksToBounds = true
        monthBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        monthBtn.addTarget(self, action: #selector(monthBtnTapped), for: .touchUpInside)
        monthBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(monthBtn)
        
        clearFilterBtn.setTitle("✕ Clear", for: .normal)
        clearFilterBtn.setTitleColor(.systemRed, for: .normal)
        clearFilterBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        clearFilterBtn.backgroundColor = UIColor(white: 0.93, alpha: 1)
        clearFilterBtn.layer.cornerRadius = 8
        clearFilterBtn.isHidden = true
        clearFilterBtn.addTarget(self, action: #selector(clearFilter), for: .touchUpInside)
        clearFilterBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearFilterBtn)
        
        NSLayoutConstraint.activate([
            clearFilterBtn.centerYAnchor.constraint(equalTo: monthBtn.centerYAnchor),
            clearFilterBtn.leadingAnchor.constraint(equalTo: monthBtn.trailingAnchor, constant: 12),
            clearFilterBtn.heightAnchor.constraint(equalToConstant: 36),
            clearFilterBtn.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Type button
            typeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            typeBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeBtn.widthAnchor.constraint(equalToConstant: 100),
            typeBtn.heightAnchor.constraint(equalToConstant: 36),
            
            // Month button
            monthBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
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
        
        if let selectedDate = selectedDate {
            filtered = filtered.filter {
                Calendar.current.isDate($0.date ?? Date(), inSameDayAs: selectedDate)
            }
        }
        
        expenses = filtered
        tableView.reloadData()
        showEmptyStateIfNeeded()
    }
    
    @objc func typeBtnTapped() {
        let alert = UIAlertController(title: "Filter by Type", message: nil, preferredStyle: .actionSheet)
        ["Income", "Expense"].forEach { type in
            alert.addAction(UIAlertAction(title: type, style: .default) { [weak self] _ in
                self?.selectedType = type
                self?.typeBtn.setTitle("\(type) ▾", for: .normal)
                self?.clearFilterBtn.isHidden = false
                self?.applyFilter()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func monthBtnTapped() {
        let alert = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
        ])
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            let selected = datePicker.date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            self?.monthBtn.setTitle("\(formatter.string(from: selected)) ▾", for: .normal)
            self?.selectedDate = selected
            self?.clearFilterBtn.isHidden = false
            self?.applyFilter()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func clearFilter() {
        selectedDate = nil
        selectedType = "All"
        monthBtn.setTitle("Date ▾", for: .normal)
        typeBtn.setTitle("Type ▾", for: .normal)
        clearFilterBtn.isHidden = true
        applyFilter()
    }}

    // MARK: - TableView
    extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
            // Delete Action
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                guard let self = self else { return }
                
                let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this transaction?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                    let expense = self.expenses[indexPath.row]
                    CoreDataManager.shared.deleteExpense(expense)
                    self.loadData()
                    completion(true)
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    completion(false)
                })
                
                self.present(alert, animated: true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            
            
            // Edit Action
            let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
                guard let self = self else { return }
                let expense = self.expenses[indexPath.row]
                let detailVC = TransactionDetailViewController()
                detailVC.expense = expense
                detailVC.onDismiss = { [weak self] in
                    self?.loadData()
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
                completion(true)
            }
            editAction.image = UIImage(systemName: "pencil")
            editAction.backgroundColor = .systemBlue
            
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return expenses.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 90
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let expense = expenses[indexPath.row]
            let detailVC = TransactionDetailViewController()
            detailVC.expense = expense
            detailVC.onDismiss = { [weak self] in
                self?.loadData()
            }
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
            let expense = expenses[indexPath.row]
            
            cell.titleLabel.text = expense.title
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            cell.dateLabel.text = formatter.string(from: expense.date ?? Date())
            
            cell.amountLabel.text = "\(CurrencyManager.shared.currencySymbol()) \(String(format: "%.2f", CurrencyManager.shared.convertAmount(expense.amount, from: expense.currency ?? "PKR")))"

            if expense.type == "income" {
                cell.amountLabel.textColor = .systemGreen
            } else {
                cell.amountLabel.textColor = .systemRed
            }
            return cell
        }
    }

