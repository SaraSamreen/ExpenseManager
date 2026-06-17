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
    
    
    //// MARK: - Convert to Base
    func convertToBase(_ amount: Double, from sourceCurrency: String) -> Double {
        if sourceCurrency == "PKR" { return amount }
        let rate = exchangeRates[sourceCurrency] ?? 1.0
        return amount / rate
    }
    
    // MARK: - Convert Amount
    func convertAmount(_ amount: Double, from sourceCurrency: String) -> Double {
        let targetCode = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "PKR"
        
        if sourceCurrency == targetCode { return amount }
    
        let sourceToPKR = exchangeRates[sourceCurrency] != nil ? 1.0 / (exchangeRates[sourceCurrency] ?? 1.0) : 1.0
        let pkrToTarget = exchangeRates[targetCode] ?? 1.0
        
        return amount * sourceToPKR * pkrToTarget
    }
    
    // MARK: - Currency Symbol
    func currencySymbol() -> String {
        
        let code = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "PKR"
        
        switch code {
        case "USD": return "$"
        case "EUR": return "€"
        case "PKR": return "₨"
        case "INR": return "₹"
        case "AED": return "د.إ"
        default: return "₨"
        }
    }
}
