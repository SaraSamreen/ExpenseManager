//
//  CoreDataManager.swift
//  ExpenseManager
//
//  Created by Mac on 03/06/2026.
//

import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    lazy var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    // MARK: - Save Expense
    func saveExpense(title: String, amount: Double, date: Date, type: String, category: String) {
        let expense = Expense(context: context)
        expense.title = title
        expense.amount = amount
        expense.date = date
        expense.type = type
        expense.category = category
        
        do {
            try context.save()
        } catch {
            print("Error saving: \(error)")
        }
    }
    
    // MARK: - Fetch Expenses
    func fetchExpenses() -> [Expense] {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching: \(error)")
            return []
        }
    }
    
    // MARK: - Save Category
    func saveCategory(name: String, type: String) {
        let category = ExpenseCategory(context: context)
        category.name = name
        category.type = type
        
        do {
            try context.save()
        } catch {
            print("Error saving category: \(error)")
        }
    }

    // MARK: - Fetch Categories
    func fetchCategories(type: String) -> [String] {
        let request: NSFetchRequest<ExpenseCategory> = ExpenseCategory.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type)
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { $0.name }
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    // MARK: - Default Categories
    func setupDefaultCategories() {
        let incomeDefaults = ["Salary", "Rewards"]
        let expenseDefaults = ["Food", "Transport", "Shopping"]
        
        if fetchCategories(type: "income").isEmpty {
            incomeDefaults.forEach { saveCategory(name: $0, type: "income") }
        }
        if fetchCategories(type: "expense").isEmpty {
            expenseDefaults.forEach { saveCategory(name: $0, type: "expense") }
        }
    }
}
