//
//  FirestoreManager.swift
//  ExpenseManager
//
//  Created by Mac on 16/06/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreManager {
    
    static let shared = FirestoreManager()
    let db = Firestore.firestore()
    
    // MARK: - Sync Expenses to Firestore
    func syncExpenses() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let expenses = CoreDataManager.shared.fetchExpenses()
        
        for expense in expenses {

            if expense.firestoreID != nil { continue }
            
            let data: [String: Any] = [
                "title": expense.title ?? "",
                "amount": expense.amount,
                "date": Timestamp(date: expense.date ?? Date()),
                "type": expense.type ?? "",
                "category": expense.category ?? "",
                "currency": expense.currency ?? "PKR"
            ]
            
            let docRef = db.collection("users").document(userID)
                .collection("expenses").addDocument(data: data)
            
            expense.firestoreID = docRef.documentID
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: - Sync Single Expense
    func syncExpense(expense: Expense) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Skip if already synced
        if expense.firestoreID != nil { return }
        
        let data: [String: Any] = [
            "title": expense.title ?? "",
            "amount": expense.amount,
            "date": Timestamp(date: expense.date ?? Date()),
            "type": expense.type ?? "",
            "category": expense.category ?? "",
            "currency": expense.currency ?? "PKR"
        ]
        
        let docRef = db.collection("users").document(userID)
            .collection("expenses").addDocument(data: data) { error in
                if error == nil {
                }
            }
        
        // Save the new document ID back to CoreData
        expense.firestoreID = docRef.documentID
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: - Delete Expense from Firestore
    func deleteExpenseFromFirestore(documentID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userID)
          .collection("expenses").document(documentID).delete()
    }
    
    // MARK: - Update Expense
    func updateExpenseInFirestore(documentID: String, title: String, amount: Double, date: Date) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "title": title,
            "amount": amount,
            "date": Timestamp(date: date)
        ]
        
        db.collection("users").document(userID)
          .collection("expenses").document(documentID).updateData(data)
    }
    
    // MARK: - Sync Goals to Firestore
    func syncGoals() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let goals = CoreDataManager.shared.fetchGoals()
        
        for goal in goals {
            if goal.firestoreID != nil { continue }
            
            let data: [String: Any] = [
                "title": goal.title ?? "",
                "amount": goal.amount,
                "deadline": Timestamp(date: goal.deadline ?? Date()),
                "contributionType": goal.contributionType ?? "",
                "icon": goal.icon ?? ""
            ]
            
            let docRef = db.collection("users").document(userID)
                .collection("goals").addDocument(data: data)
            
            goal.firestoreID = docRef.documentID
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: - Sync Single Goal
    func syncGoal(goal: Goal) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        if goal.firestoreID != nil { return }
        
        let data: [String: Any] = [
            "title": goal.title ?? "",
            "amount": goal.amount,
            "deadline": Timestamp(date: goal.deadline ?? Date()),
            "contributionType": goal.contributionType ?? "",
            "icon": goal.icon ?? ""
        ]
        
        let docRef = db.collection("users").document(userID)
            .collection("goals").addDocument(data: data)
        
        goal.firestoreID = docRef.documentID
        CoreDataManager.shared.saveContext()
    }

    // MARK: - Update Goal
    func updateGoalInFirestore(documentID: String, title: String, amount: Double, deadline: Date, contributionType: String, icon: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "title": title,
            "amount": amount,
            "deadline": Timestamp(date: deadline),
            "contributionType": contributionType,
            "icon": icon
        ]
        
        db.collection("users").document(userID)
          .collection("goals").document(documentID).updateData(data)
    }

    // MARK: - Delete Goal
    func deleteGoalFromFirestore(documentID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userID)
          .collection("goals").document(documentID).delete()
    }
    
    // MARK: - Sync ALL Categories to Firestore
        func syncCategories() {
            guard let userID = Auth.auth().currentUser?.uid else { return }
            let categories = CoreDataManager.shared.fetchAllCategories()
            
            for category in categories {
                if category.firestoreID != nil { continue }
                
                let data: [String: Any] = [
                    "name": category.name ?? "",
                    "type": category.type ?? ""
                ]
                
                let docRef = db.collection("users").document(userID)
                    .collection("categories").addDocument(data: data)
                
                category.firestoreID = docRef.documentID
            }
            
            CoreDataManager.shared.saveContext()
        }
        
        // MARK: - Sync Single Category
        func syncCategory(category: ExpenseCategory) {
            guard let userID = Auth.auth().currentUser?.uid else { return }
            
            if category.firestoreID != nil { return }
            
            let data: [String: Any] = [
                "name": category.name ?? "",
                "type": category.type ?? ""
            ]
            
            let docRef = db.collection("users").document(userID)
                .collection("categories").addDocument(data: data)
            
            category.firestoreID = docRef.documentID
            CoreDataManager.shared.saveContext()
        }
    
    
    // MARK: - Sync All
    func syncAll() {
        syncExpenses()
        syncGoals()
        syncCategories()
    }
    
    // MARK: - Sync User Preferences to Firestore
    func saveSyncPreference(enabled: Bool) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userID).setData(["cloudSyncEnabled": enabled], merge: true)
    }

    func saveCurrencyPreference(currency: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userID).setData(["selectedCurrency": currency], merge: true)
    }

    func fetchSyncPreference(completion: @escaping (Bool, String) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { completion(false, "PKR"); return }
        db.collection("users").document(userID).getDocument { snapshot, error in
            let enabled = snapshot?.data()?["cloudSyncEnabled"] as? Bool ?? false
            let currency = snapshot?.data()?["selectedCurrency"] as? String ?? "PKR"
            completion(enabled, currency)
        }
    }
    
    // MARK: - Fetch from Firestore and restore to CoreData
        func fetchAndSyncFromFirestore(completion: @escaping () -> Void) {
            guard let userID = Auth.auth().currentUser?.uid else { return }
            
            let group = DispatchGroup()
            
            // Fetch expenses
            group.enter()
            db.collection("users").document(userID)
              .collection("expenses").getDocuments { snapshot, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error fetching expenses from Firestore: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                  let existing = CoreDataManager.shared.fetchExpenses()
                  existing.forEach { CoreDataManager.shared.deleteExpenseLocalOnly($0) }
                
                for doc in documents {
                    let data = doc.data()
                    let title = data["title"] as? String ?? ""
                    let amount = data["amount"] as? Double ?? 0
                    let type = data["type"] as? String ?? ""
                    let category = data["category"] as? String ?? ""
                    let currency = data["currency"] as? String ?? "PKR"
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    
                    let savedExpense = CoreDataManager.shared.saveExpense(
                        title: title,
                        amount: amount,
                        date: date,
                        type: type,
                        category: category,
                        currency: currency
                    )
                    
                    savedExpense?.firestoreID = doc.documentID
                }
                
                CoreDataManager.shared.saveContext()
            }
            
            // Fetch categories
            group.enter()
            db.collection("users").document(userID)
              .collection("categories").getDocuments { snapshot, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error fetching categories from Firestore: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                for doc in documents {
                    let data = doc.data()
                    let name = data["name"] as? String ?? ""
                    let type = data["type"] as? String ?? ""
                    if !CoreDataManager.shared.fetchCategories(type: type).contains(name) {
                        let saved = CoreDataManager.shared.saveCategory(name: name, type: type)
                        saved?.firestoreID = doc.documentID
                    }
                }
                CoreDataManager.shared.saveContext()
            }
            
            // Fetch goals
            group.enter()
            db.collection("users").document(userID)
              .collection("goals").getDocuments { snapshot, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error fetching goals from Firestore: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                  let existingGoals = CoreDataManager.shared.fetchGoals()
                  existingGoals.forEach { CoreDataManager.shared.deleteGoalLocalOnly($0) }
                
                for doc in documents {
                    let data = doc.data()
                    let title = data["title"] as? String ?? ""
                    let amount = data["amount"] as? Double ?? 0
                    let contributionType = data["contributionType"] as? String ?? "Monthly"
                    let icon = data["icon"] as? String ?? "star.fill"
                    let timestamp = data["deadline"] as? Timestamp
                    let deadline = timestamp?.dateValue() ?? Date()
                    
                    let savedGoal = CoreDataManager.shared.saveGoal(
                        title: title,
                        amount: amount,
                        deadline: deadline,
                        contributionType: contributionType,
                        icon: icon
                    )
                    
                    savedGoal?.firestoreID = doc.documentID
                }
                
                CoreDataManager.shared.saveContext()
            }
            
            group.notify(queue: .main) {
                completion()
            }
        }
}
