//
//  ChartViewController.swift
//  ExpenseManager
//
//  Created by Mac on 05/06/2026.
//
import UIKit

class ChartViewController: UIViewController {
    
    @IBOutlet weak var analyticslbl: UILabel!
    
    var selectedDate: Date? = nil
    var monthBtn = UIButton(type: .system)
    var clearFilterBtn = UIButton(type: .system)
    
    let scrollView = UIScrollView()
    let contentStack = UIStackView()
    
    // Expense chart
    var expenseChartView = UIView()
    var expenseLegendStack = UIStackView()
    
    // Income chart
    var incomeChartView = UIView()
    var incomeLegendStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupMonthButton()
        setupScrollView()
        setupChartSections()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { self.loadCharts() }
    }
    
    func setupMonthButton() {
        monthBtn.setTitle("Select Date ▾", for: .normal)
        monthBtn.setTitleColor(.label, for: .normal)
        monthBtn.backgroundColor = UIColor(white: 0.93, alpha: 1)
        monthBtn.layer.cornerRadius = 8
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
            monthBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            monthBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            monthBtn.widthAnchor.constraint(equalToConstant: 140),
            monthBtn.heightAnchor.constraint(equalToConstant: 36),
            
            clearFilterBtn.centerYAnchor.constraint(equalTo: monthBtn.centerYAnchor),
            clearFilterBtn.leadingAnchor.constraint(equalTo: monthBtn.trailingAnchor, constant: 8),
            clearFilterBtn.heightAnchor.constraint(equalToConstant: 36),
            clearFilterBtn.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: monthBtn.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    func setupChartSections() {
        // Expense Section
        let expenseSection = makeSectionContainer(title: "Expense Breakdown", chartView: &expenseChartView, legendStack: &expenseLegendStack)
        contentStack.addArrangedSubview(expenseSection)
        
        // Income Section
        let incomeSection = makeSectionContainer(title: "Income Breakdown", chartView: &incomeChartView, legendStack: &incomeLegendStack)
        contentStack.addArrangedSubview(incomeSection)
    }
    
    func makeSectionContainer(title: String, chartView: inout UIView, legendStack: inout UIStackView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        chartView = UIView()
        chartView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        chartView.layer.cornerRadius = 16
        chartView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(chartView)
        
        legendStack = UIStackView()
        legendStack.axis = .vertical
        legendStack.spacing = 8
        legendStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(legendStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            chartView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            chartView.heightAnchor.constraint(equalToConstant: 260),
            
            legendStack.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 16),
            legendStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            legendStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            legendStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    func loadCharts() {
        let allExpenses = CoreDataManager.shared.fetchExpenses()
        
        var filtered = allExpenses
        if let selectedDate = selectedDate {
            filtered = filtered.filter {
                Calendar.current.isDate($0.date ?? Date(), inSameDayAs: selectedDate)
            }
        }
        
        let expenses = filtered.filter { $0.type == "expense" }
        let incomes = filtered.filter { $0.type == "income" }
        
        loadChart(data: expenses, chartView: expenseChartView, legendStack: expenseLegendStack)
        loadChart(data: incomes, chartView: incomeChartView, legendStack: incomeLegendStack)
    }
    
    func loadChart(data: [Expense], chartView: UIView, legendStack: UIStackView) {
        var categoryTotals: [String: Double] = [:]
        for item in data {
            let cat = (item.category?.isEmpty == false) ? item.category! : "Other"
            let convertedAmount = CurrencyManager.shared.convertAmount(item.amount, from: item.currency ?? "PKR")
            categoryTotals[cat, default: 0] += convertedAmount
        }
        
        let total = categoryTotals.values.reduce(0, +)
        guard total > 0 else {
            drawEmptyState(in: chartView, legendStack: legendStack)
            return
        }
        drawDonutChart(categoryTotals: categoryTotals, total: total, chartView: chartView, legendStack: legendStack)
    }
    
    func drawEmptyState(in chartView: UIView, legendStack: UIStackView) {
        chartView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        chartView.subviews.forEach { $0.removeFromSuperview() }
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.text = "No data found"
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        chartView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: chartView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: chartView.centerYAnchor)
        ])
    }
    
    func drawDonutChart(categoryTotals: [String: Double], total: Double, chartView: UIView, legendStack: UIStackView) {
        chartView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        chartView.subviews.forEach { $0.removeFromSuperview() }
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let colors: [UIColor] = [
            UIColor(hex: "#E63946"),
            UIColor(hex: "#2196F3"),
            UIColor(hex: "#FF9800"),
            UIColor(hex: "#4CAF50"),
            UIColor(hex: "#9C27B0")
        ]
        
        let center = CGPoint(x: chartView.bounds.width / 2, y: chartView.bounds.height / 2)
        let radius: CGFloat = 90
        let innerRadius: CGFloat = 55
        var startAngle: CGFloat = -CGFloat.pi / 2
        var colorIndex = 0
        
        for (category, amount) in categoryTotals.sorted(by: { $0.value > $1.value }) {
            let percentage = amount / total
            let endAngle = startAngle + CGFloat(percentage) * 2 * CGFloat.pi
            
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.close()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = colors[colorIndex % colors.count].cgColor
            chartView.layer.addSublayer(shapeLayer)
            
            let midAngle = startAngle + CGFloat(percentage) * CGFloat.pi
            let labelRadius = (radius + innerRadius) / 2
            let labelX = center.x + labelRadius * cos(midAngle)
            let labelY = center.y + labelRadius * sin(midAngle)
            
            let pctLabel = UILabel()
            pctLabel.text = "\(Int(percentage * 100))%"
            pctLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
            pctLabel.textColor = .white
            pctLabel.sizeToFit()
            pctLabel.center = CGPoint(x: labelX, y: labelY)
            chartView.addSubview(pctLabel)
            
            let legendRow = makeLegendRow(color: colors[colorIndex % colors.count], category: category, amount: amount)
            legendStack.addArrangedSubview(legendRow)
            
            startAngle = endAngle
            colorIndex += 1
        }
        
        let holeLayer = CAShapeLayer()
        let holePath = UIBezierPath(arcCenter: center, radius: innerRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        holeLayer.path = holePath.cgPath
        holeLayer.fillColor = UIColor(white: 0.95, alpha: 1).cgColor
        chartView.layer.addSublayer(holeLayer)
    }
    
    func makeLegendRow(color: UIColor, category: String, amount: Double) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 6
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 12).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        let label = UILabel()
        label.text = category
        label.font = UIFont.systemFont(ofSize: 14)
        
        let amountLabel = UILabel()
        amountLabel.text = "\(CurrencyManager.shared.currencySymbol()) \(String(format: "%.2f", amount))"
        amountLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        amountLabel.textAlignment = .right
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        row.addArrangedSubview(dot)
        row.addArrangedSubview(label)
        row.addArrangedSubview(spacer)
        row.addArrangedSubview(amountLabel)
        
        return row
    }
    
    @objc func monthBtnTapped() {
        let alert = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
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
            self?.loadCharts()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func clearFilter() {
        selectedDate = nil
        monthBtn.setTitle("Select Date ▾", for: .normal)
        clearFilterBtn.isHidden = true
        loadCharts()
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
