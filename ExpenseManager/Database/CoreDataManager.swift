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
    func saveExpense(title: String, amount: Double, date: Date, type: String, category: String, image: UIImage? = nil) {
        let expense = Expense(context: context)
        expense.title = title
        expense.amount = amount
        expense.date = date
        expense.type = type
        expense.category = category
        expense.image = image?.jpegData(compressionQuality: 0.7)
        
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
    
    // MARK: - Delete Expense
    func deleteExpense(_ expense: Expense) {
        context.delete(expense)
        do {
            try context.save()
        } catch {
            print("Error deleting: \(error)")
        }
    }
    
    // MARK: - Save Context
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Save Goal
    func saveGoal(title: String, amount: Double, deadline: Date, contributionType: String, icon: String) {
        let goal = Goal(context: context)
        goal.title = title
        goal.amount = amount
        goal.deadline = deadline
        goal.contributionType = contributionType
        goal.createdAt = Date()
        goal.icon = icon
        
        do {
            try context.save()
        } catch {
            print("Error saving goal: \(error)")
        }
    }
    
    func iconName(for title: String) -> String {
        let t = title.lowercased()
        if t.contains("bike") || t.contains("motor") || t.contains("car") { return "car.fill" }
        if t.contains("phone") || t.contains("iphone") || t.contains("mobile") { return "iphone" }
        if t.contains("house") || t.contains("home") { return "house.fill" }
        if t.contains("laptop") || t.contains("mac") || t.contains("computer") { return "laptopcomputer" }
        if t.contains("travel") || t.contains("trip") || t.contains("vacation") { return "airplane" }
        if t.contains("food") || t.contains("eat") { return "fork.knife" }
        if t.contains("education") || t.contains("study") || t.contains("school") { return "graduationcap.fill" }
        if t.contains("health") || t.contains("gym") || t.contains("fitness") { return "heart.fill" }
        if t.contains("shop") || t.contains("buy") { return "bag.fill" }
        return "star.fill"
    }
    
    // MARK: - Fetch Goals
    func fetchGoals() -> [Goal] {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        let sort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching goals: \(error)")
            return []
        }
    }
    
    // MARK: - Delete Goal
    func deleteGoal(_ goal: Goal) {
        context.delete(goal)
        do {
            try context.save()
        } catch {
            print("Error deleting goal: \(error)")
        }
    }
}
