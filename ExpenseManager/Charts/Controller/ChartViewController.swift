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
    var chartView = UIView()
    var legendStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupMonthButton()
        setupChartArea()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.loadChart()
        }
    }
    
    func setupMonthButton() {
        monthBtn.setTitle("Select Date ▾", for: .normal)
        monthBtn.setTitleColor(.label, for: .normal)
        monthBtn.backgroundColor = UIColor(white: 0.93, alpha: 1)
        monthBtn.layer.cornerRadius = 8
        monthBtn.layer.masksToBounds = true
        monthBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        monthBtn.addTarget(self, action: #selector(monthBtnTapped), for: .touchUpInside)
        monthBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(monthBtn)
        
        NSLayoutConstraint.activate([
            monthBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            monthBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            monthBtn.widthAnchor.constraint(equalToConstant: 120),
            monthBtn.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func setupChartArea() {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        chartView.layer.cornerRadius = 16
        view.addSubview(chartView)
        
        legendStack.axis = .vertical
        legendStack.spacing = 8
        legendStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(legendStack)
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: monthBtn.bottomAnchor, constant: 24),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 260),
            
            legendStack.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 24),
            legendStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            legendStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    func loadChart() {
        let allExpenses = CoreDataManager.shared.fetchExpenses()
        
        var filtered = allExpenses.filter { $0.type == "expense" }
        if let selectedDate = selectedDate {
            filtered = filtered.filter {
                Calendar.current.isDate($0.date ?? Date(), inSameDayAs: selectedDate)
            }
        }
        
        // Group by category
        var categoryTotals: [String: Double] = [:]
        for expense in filtered {
            let cat = (expense.category?.isEmpty == false) ? expense.category! : "Other"
            categoryTotals[cat, default: 0] += expense.amount
        }
        
        let total = categoryTotals.values.reduce(0, +)
        guard total > 0 else {
            drawEmptyState()
            return
        }
        
        drawDonutChart(categoryTotals: categoryTotals, total: total)
    }
    
    func drawEmptyState() {
        chartView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.text = "No expenses found"
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        chartView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: chartView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: chartView.centerYAnchor)
        ])
    }
    
    func drawDonutChart(categoryTotals: [String: Double], total: Double) {
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
        
        for (category, amount) in categoryTotals {
            let percentage = amount / total
            let endAngle = startAngle + CGFloat(percentage) * 2 * CGFloat.pi
            
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.close()
            
            // Donut hole
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = colors[colorIndex % colors.count].cgColor
            chartView.layer.addSublayer(shapeLayer)
            
            // Percentage label
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
            
            // Legend
            let color = colors[colorIndex % colors.count]
            let legendRow = makeLegendRow(color: color, category: category, amount: amount)
            legendStack.addArrangedSubview(legendRow)
            
            startAngle = endAngle
            colorIndex += 1
        }
        
        // Draw inner circle (donut hole)
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
        amountLabel.text = "Rs \(String(format: "%.0f", amount))"
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
        
        alert.addAction(UIAlertAction(title: "Show", style: .default) { [weak self] _ in
            let selected = datePicker.date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            self?.monthBtn.setTitle("\(formatter.string(from: selected)) ▾", for: .normal)
            self?.selectedDate = selected
            self?.loadChart()
        })
        
        alert.addAction(UIAlertAction(title: "Show All", style: .default) { [weak self] _ in
            self?.selectedDate = nil
            self?.monthBtn.setTitle("Select Date ▾", for: .normal)
            self?.loadChart()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
