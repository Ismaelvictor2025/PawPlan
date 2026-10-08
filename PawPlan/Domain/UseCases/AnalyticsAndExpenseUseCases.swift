//
//  AnalyticsAndExpenseUseCases.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation

public struct CareConsistencyReport: Sendable {
    public let totalScheduled: Int
    public let totalCompleted: Int
    public let consistencyRate: Double // 0.0 - 1.0
    public let currentStreakDays: Int
    public let adherenceDescription: String

    public init(
        totalScheduled: Int,
        totalCompleted: Int,
        consistencyRate: Double,
        currentStreakDays: Int,
        adherenceDescription: String
    ) {
        self.totalScheduled = totalScheduled
        self.totalCompleted = totalCompleted
        self.consistencyRate = consistencyRate
        self.currentStreakDays = currentStreakDays
        self.adherenceDescription = adherenceDescription
    }
}

public struct CalculateCareConsistencyUseCase: Sendable {
    private let careTaskRepository: CareTaskRepositoryProtocol

    public init(careTaskRepository: CareTaskRepositoryProtocol) {
        self.careTaskRepository = careTaskRepository
    }

    public func execute(for dogId: UUID? = nil, days: Int = 7) throws -> CareConsistencyReport {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let completions = try careTaskRepository.fetchCompletions(for: dogId, since: startDate)
        let tasks = try careTaskRepository.fetchTasks(for: dogId)

        let completedCount = completions.count
        let baseCount = max(tasks.count, 1) * days
        let rate = min(1.0, Double(completedCount) / Double(max(baseCount, completedCount)))

        // Calculate consecutive active days with at least one completed task
        var streak = 0
        for i in 0..<days {
            guard let dayTarget = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let hadActivity = completions.contains {
                calendar.isDate($0.completedAt, inSameDayAs: dayTarget)
            }
            if hadActivity {
                streak += 1
            } else if i > 0 {
                break
            }
        }

        let desc: String
        if rate >= 0.85 {
            desc = "Excellent Routine"
        } else if rate >= 0.65 {
            desc = "Consistent Care"
        } else if rate >= 0.40 {
            desc = "Building Habits"
        } else {
            desc = "Starting Out"
        }

        return CareConsistencyReport(
            totalScheduled: baseCount,
            totalCompleted: completedCount,
            consistencyRate: rate,
            currentStreakDays: streak,
            adherenceDescription: desc
        )
    }
}

public struct ExpenseSummary: Sendable {
    public let totalAmount: Double
    public let currency: String
    public let categoryBreakdown: [ExpenseCategory: Double]
    public let monthlyBudgetGoal: Double
    public let remainingBudget: Double
    public let isOverBudget: Bool

    public init(
        totalAmount: Double,
        currency: String = "AUD",
        categoryBreakdown: [ExpenseCategory: Double],
        monthlyBudgetGoal: Double = 350.0
    ) {
        self.totalAmount = totalAmount
        self.currency = currency
        self.categoryBreakdown = categoryBreakdown
        self.monthlyBudgetGoal = monthlyBudgetGoal
        self.remainingBudget = max(0.0, monthlyBudgetGoal - totalAmount)
        self.isOverBudget = totalAmount > monthlyBudgetGoal
    }
}

public struct ManageExpensesUseCase: Sendable {
    private let expenseRepository: ExpenseRepositoryProtocol

    public init(expenseRepository: ExpenseRepositoryProtocol) {
        self.expenseRepository = expenseRepository
    }

    public func executeSave(_ expense: Expense) throws {
        guard expense.amount > 0 else {
            throw ExpenseError.negativeAmount
        }
        try expenseRepository.saveExpense(expense)
    }

    public func executeSummary(for dogId: UUID? = nil, monthDate: Date = Date(), budget: Double = 350.0) throws -> ExpenseSummary {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return ExpenseSummary(totalAmount: 0, categoryBreakdown: [:], monthlyBudgetGoal: budget)
        }

        let expenses = try expenseRepository.fetchExpenses(for: dogId, from: startOfMonth, to: endOfMonth)
        var total = 0.0
        var breakdown: [ExpenseCategory: Double] = [:]

        for exp in expenses {
            total += exp.amount
            breakdown[exp.category, default: 0.0] += exp.amount
        }

        return ExpenseSummary(
            totalAmount: total,
            currency: "AUD",
            categoryBreakdown: breakdown,
            monthlyBudgetGoal: budget
        )
    }

    public func executeExportCSV(for dogId: UUID? = nil) throws -> String {
        let expenses = try expenseRepository.fetchExpenses(for: dogId, from: nil, to: nil)
        let dateFormatter = ISO8601DateFormatter()

        var csv = "ID,Date,Category,Amount,Currency,Merchant,Notes\n"
        for exp in expenses {
            let row = [
                exp.id.uuidString,
                dateFormatter.string(from: exp.date),
                exp.category.rawValue,
                String(format: "%.2f", exp.amount),
                exp.currency,
                "\"\(exp.merchant ?? "")\"",
                "\"\(exp.notes ?? "")\""
            ].joined(separator: ",")
            csv.append(row + "\n")
        }
        return csv
    }
}
