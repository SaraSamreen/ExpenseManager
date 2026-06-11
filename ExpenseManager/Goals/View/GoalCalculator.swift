//
//  GoalCalculator.swift
//  ExpenseManager
//
//  Created by Mac on 11/06/2026.
//

import Foundation

enum GoalStatus {
    case achieved
    case onTrack
    case behind
    case failed
}

struct GoalProgress {
    let status: GoalStatus
    let progressPercent: Double
    let requiredPerPeriod: Double
    let periodLabel: String
    let periodsRemaining: Int
    let expectedByNow: Double
    let savingsPerPeriod: Double
}

struct GoalCalculator {
    
    static func calculate(goal: Goal, currentSavings: Double, monthlySavings: Double) -> GoalProgress {
        
        let now = Date()
        let calendar = Calendar.current
        let start = goal.createdAt ?? now
        let deadline = goal.deadline ?? now
        let target = goal.amount
        let type = goal.contributionType ?? "Monthly"
        
        // Calculate periods
        let (totalPeriods, remainingPeriods, label) = periods(
            type: type, start: start, deadline: deadline, now: now, calendar: calendar
        )
        
        // Required per period
        let requiredPerPeriod = totalPeriods > 0 ? target / Double(totalPeriods) : target
        
        // How many periods passed
        let passedPeriods = max(1, totalPeriods - remainingPeriods)
        
        // What should be saved by now
        let expectedByNow = requiredPerPeriod * Double(passedPeriods)
        
        // Convert monthlySavings to match period type
        let savingsPerPeriod: Double
        switch type {
        case "Daily":   savingsPerPeriod = monthlySavings / 30
        case "Weekly":  savingsPerPeriod = monthlySavings / 4
        default:        savingsPerPeriod = monthlySavings
        }
        
        // Progress bar = expectedByNow / target
        let progressPercent: Double
        if currentSavings < expectedByNow {
            // Behind — show actual savings
            progressPercent = min(1.0, target > 0 ? currentSavings / target : 0)
        } else {
            // On track — show expected progress
            progressPercent = min(1.0, target > 0 ? expectedByNow / target : 0)
        }
        
        // Failed: deadline passed
        if deadline < now {
            return GoalProgress(
                status: .failed,
                progressPercent: min(1.0, target > 0 ? expectedByNow / target : 0),
                requiredPerPeriod: requiredPerPeriod,
                periodLabel: label,
                periodsRemaining: 0,
                expectedByNow: expectedByNow,
                savingsPerPeriod: savingsPerPeriod
            )
        }
        
        // Achieved: all periods done and savings covered
        if remainingPeriods == 0 && currentSavings >= target {
            return GoalProgress(
                status: .achieved,
                progressPercent: 1.0,
                requiredPerPeriod: requiredPerPeriod,
                periodLabel: label,
                periodsRemaining: 0,
                expectedByNow: target,
                savingsPerPeriod: savingsPerPeriod
            )
        }
        
        // On track: this month's savings >= required per period
        let status: GoalStatus = savingsPerPeriod >= requiredPerPeriod ? .onTrack : .behind
        
        return GoalProgress(
            status: status,
            progressPercent: progressPercent,
            requiredPerPeriod: requiredPerPeriod,
            periodLabel: label,
            periodsRemaining: remainingPeriods,
            expectedByNow: expectedByNow,
            savingsPerPeriod: savingsPerPeriod
        )
    }
    
    private static func periods(type: String, start: Date, deadline: Date, now: Date, calendar: Calendar) -> (total: Int, remaining: Int, label: String) {
        switch type {
        case "Daily":
            let total     = max(1, calendar.dateComponents([.day], from: start, to: deadline).day ?? 1)
            let remaining = max(0, calendar.dateComponents([.day], from: now, to: deadline).day ?? 0)
            return (total, remaining, "day")
        case "Weekly":
            let totalDays  = max(7, calendar.dateComponents([.day], from: start, to: deadline).day ?? 7)
            let remainDays = max(0, calendar.dateComponents([.day], from: now, to: deadline).day ?? 0)
            return (max(1, totalDays / 7), max(0, remainDays / 7), "week")
        default:
            let totalDays   = max(1, calendar.dateComponents([.day], from: start, to: deadline).day ?? 1)
            let remainDays  = max(0, calendar.dateComponents([.day], from: now, to: deadline).day ?? 0)
            let total       = max(1, Int(round(Double(totalDays) / 30.44)))
            let remaining   = max(0, Int(Double(remainDays) / 30.44))
            return (total, remaining, "month")
        }
    }
}
