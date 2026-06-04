//
//  ExpenseCategory+CoreDataProperties.swift
//  ExpenseManager
//
//  Created by Mac on 04/06/2026.
//
//

public import Foundation
public import CoreData


public typealias ExpenseCategoryCoreDataPropertiesSet = NSSet

extension ExpenseCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseCategory> {
        return NSFetchRequest<ExpenseCategory>(entityName: "ExpenseCategory")
    }

    @NSManaged public var name: String?
    @NSManaged public var type: String?

}

extension ExpenseCategory : Identifiable {

}
