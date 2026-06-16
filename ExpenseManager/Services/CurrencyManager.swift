//
//  CurrencyManager.swift
//  ExpenseManager
//
//  Created by Mac on 16/06/2026.
//

import Foundation

class CurrencyManager {
    
    static let shared = CurrencyManager()
    
    var exchangeRates: [String: Double] = [:]
    
    // MARK: - Fetch API Rates
    func fetchExchangeRates(completion: @escaping () -> Void) {
        
        let apiKey = "c55010b8dc0b368cc3fbe5e4"
        let base = "PKR"
        let urlString = "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/\(base)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            
            guard let data = data, error == nil else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let rates = json["conversion_rates"] as? [String: Double] {
                self?.exchangeRates = rates
            }
            
            DispatchQueue.main.async {
                completion()
            }
            
        }.resume()
    }
    
    // MARK: - Convert Amount
    func convertAmount(_ amount: Double) -> Double {
        
        let code = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "PKR"
        let rate = exchangeRates[code] ?? 1.0
        
        return amount * rate
    }
    
    // MARK: - Currency Symbol
    func currencySymbol() -> String {
        
        let code = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "USD"
        
        switch code {
        case "USD": return "$"
        case "EUR": return "€"
        case "PKR": return "₨"
        case "INR": return "₹"
        case "AED": return "د.إ"
        default: return "$"
        }
    }
}
