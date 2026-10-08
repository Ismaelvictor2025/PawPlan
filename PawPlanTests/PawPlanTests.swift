//
//  PawPlanTests.swift
//  PawPlanTests
//
//  Created for PawPlan Clean Architecture Test Suite.
//

import Testing
import Foundation
@testable import PawPlan

// MARK: - In-Memory Repository Mocks for Deterministic Testing

final class MockDogRepository: DogRepositoryProtocol, @unchecked Sendable {
    var dogs: [UUID: Dog] = [:]

    func fetchAllDogs() throws -> [Dog] {
        Array(dogs.values).sorted { $0.createdAt < $1.createdAt }
    }

    func fetchDog(id: UUID) throws -> Dog? {
        dogs[id]
    }

    func saveDog(_ dog: Dog) throws {
        dogs[dog.id] = dog
    }

    func deleteDog(id: UUID) throws {
        dogs.removeValue(forKey: id)
    }
}

final class MockCareTaskRepository: CareTaskRepositoryProtocol, @unchecked Sendable {
    var tasks: [UUID: CareTask] = [:]
    var completions: [CareCompletion] = []

    func fetchTasks(for dogId: UUID?) throws -> [CareTask] {
        let all = Array(tasks.values)
        if let dogId = dogId {
            return all.filter { $0.dogId == dogId }
        }
        return all
    }

    func fetchUpcomingTasks(limit: Int) throws -> [CareTask] {
        let incomplete = tasks.values.filter { !$0.isCompleted }
        return Array(incomplete.sorted { $0.scheduledDate < $1.scheduledDate }.prefix(limit))
    }

    func fetchNextTask(for dogId: UUID?) throws -> CareTask? {
        try fetchUpcomingTasks(limit: 1).first
    }

    func saveTask(_ task: CareTask) throws {
        tasks[task.id] = task
    }

    func deleteTask(id: UUID) throws {
        tasks.removeValue(forKey: id)
    }

    func recordCompletion(_ completion: CareCompletion) throws {
        completions.append(completion)
        if var task = tasks[completion.taskId] {
            task.isCompleted = true
            tasks[completion.taskId] = task
        }
    }

    func fetchCompletions(for dogId: UUID?, since: Date) throws -> [CareCompletion] {
        completions.filter { comp in
            let matchesDog = dogId == nil || comp.dogId == dogId
            return matchesDog && comp.completedAt >= since
        }
    }
}

final class MockExpenseRepository: ExpenseRepositoryProtocol, @unchecked Sendable {
    var expenses: [UUID: Expense] = [:]

    func fetchExpenses(for dogId: UUID?, from: Date?, to: Date?) throws -> [Expense] {
        expenses.values.filter { exp in
            let matchesDog = dogId == nil || exp.dogId == dogId
            let matchesFrom = from == nil || exp.date >= from!
            let matchesTo = to == nil || exp.date <= to!
            return matchesDog && matchesFrom && matchesTo
        }.sorted { $0.date > $1.date }
    }

    func saveExpense(_ expense: Expense) throws {
        expenses[expense.id] = expense
    }

    func deleteExpense(id: UUID) throws {
        expenses.removeValue(forKey: id)
    }
}

// MARK: - Test Suite

struct PawPlanTests {

    // 1. Dog Profile Tests
    @Test func testDogCreationAndValidation() async throws {
        let mockRepo = MockDogRepository()
        let saveUseCase = SaveDogUseCase(dogRepository: mockRepo)
        let getUseCase = GetDogsUseCase(dogRepository: mockRepo)

        let validDog = Dog(name: "Archie", breed: "Cavoodle", weight: 8.5)
        try saveUseCase.execute(validDog)

        let retrieved = try getUseCase.execute(id: validDog.id)
        #expect(retrieved != nil)
        #expect(retrieved?.name == "Archie")
        #expect(retrieved?.weightDescription == "8.5 kg")
    }

    @Test func testDogValidationFailures() async throws {
        let mockRepo = MockDogRepository()
        let saveUseCase = SaveDogUseCase(dogRepository: mockRepo)

        // Empty Name Failure
        let blankDog = Dog(name: "   ", breed: "Poodle", weight: 5.0)
        #expect(throws: DogProfileError.emptyName) {
            try saveUseCase.execute(blankDog)
        }

        // Negative Weight Failure
        let negativeWeightDog = Dog(name: "Bella", breed: "Collie", weight: -2.0)
        #expect(throws: DogProfileError.invalidWeight) {
            try saveUseCase.execute(negativeWeightDog)
        }
    }

    // 2. Multi-Dog Isolation & Deletion
    @Test func testMultipleDogsAndDeletion() async throws {
        let mockRepo = MockDogRepository()
        let saveUseCase = SaveDogUseCase(dogRepository: mockRepo)
        let deleteUseCase = DeleteDogUseCase(dogRepository: mockRepo)
        let getUseCase = GetDogsUseCase(dogRepository: mockRepo)

        let dog1 = Dog(name: "Archie", breed: "Cavoodle", weight: 8.4)
        let dog2 = Dog(name: "Bella", breed: "Border Collie", weight: 18.0)
        try saveUseCase.execute(dog1)
        try saveUseCase.execute(dog2)

        var allDogs = try getUseCase.execute()
        #expect(allDogs.count == 2)

        try deleteUseCase.execute(id: dog1.id)
        allDogs = try getUseCase.execute()
        #expect(allDogs.count == 1)
        #expect(allDogs.first?.name == "Bella")
    }

    // 3. Care Task Recurrence Calculations
    @Test func testDailyTaskCompletionRecurrence() async throws {
        let taskRepo = MockCareTaskRepository()
        let completeUseCase = CompleteCareTaskUseCase(careTaskRepository: taskRepo)

        let now = Date()
        let dogId = UUID()
        let task = CareTask(
            dogId: dogId,
            title: "Morning River Walk",
            category: .walk,
            recurrenceRule: .daily,
            scheduledDate: now
        )
        try taskRepo.saveTask(task)

        let updated = try completeUseCase.execute(task: task)
        #expect(taskRepo.completions.count == 1)
        #expect(updated.isCompleted == false) // Rescheduled for next day

        let expectedNextDate = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let diff = abs(updated.scheduledDate.timeIntervalSince(expectedNextDate))
        #expect(diff < 2.0)
    }

    @Test func testNonRecurringTaskCompletion() async throws {
        let taskRepo = MockCareTaskRepository()
        let completeUseCase = CompleteCareTaskUseCase(careTaskRepository: taskRepo)

        let dogId = UUID()
        let task = CareTask(
            dogId: dogId,
            title: "Nail Trimming",
            category: .grooming,
            recurrenceRule: .none,
            scheduledDate: Date()
        )
        try taskRepo.saveTask(task)

        let updated = try completeUseCase.execute(task: task)
        #expect(updated.isCompleted == true)
        #expect(taskRepo.completions.count == 1)

        // Attempting to complete again should throw
        #expect(throws: CareSchedulingError.cannotCompleteAlreadyCompletedTask) {
            try completeUseCase.execute(task: updated)
        }
    }

    // 4. Care Consistency and Streaks
    @Test func testCareConsistencyCalculation() async throws {
        let taskRepo = MockCareTaskRepository()
        let consistencyUseCase = CalculateCareConsistencyUseCase(careTaskRepository: taskRepo)

        let dogId = UUID()
        let task = CareTask(dogId: dogId, title: "Breakfast Feeding", category: .feeding)
        try taskRepo.saveTask(task)

        // Log completion for today
        let compToday = CareCompletion(taskId: task.id, dogId: dogId, completedAt: Date())
        try taskRepo.recordCompletion(compToday)

        let report = try consistencyUseCase.execute(for: dogId, days: 7)
        #expect(report.totalCompleted >= 1)
        #expect(report.currentStreakDays >= 1)
        #expect(report.consistencyRate > 0)
    }

    // 5. Expense Tracking and Budget Goals
    @Test func testExpenseSummaryAndBudgetCalculation() async throws {
        let expRepo = MockExpenseRepository()
        let expenseUseCase = ManageExpensesUseCase(expenseRepository: expRepo)

        let dogId = UUID()
        let exp1 = Expense(dogId: dogId, category: .food, amount: 80.0, currency: "AUD")
        let exp2 = Expense(dogId: dogId, category: .medication, amount: 45.0, currency: "AUD")
        try expenseUseCase.executeSave(exp1)
        try expenseUseCase.executeSave(exp2)

        let summary = try expenseUseCase.executeSummary(for: dogId, budget: 300.0)
        #expect(summary.totalAmount == 125.0)
        #expect(summary.remainingBudget == 175.0)
        #expect(summary.isOverBudget == false)
        #expect(summary.categoryBreakdown[.food] == 80.0)
        #expect(summary.categoryBreakdown[.medication] == 45.0)
    }

    @Test func testNegativeExpenseValidation() async throws {
        let expRepo = MockExpenseRepository()
        let expenseUseCase = ManageExpensesUseCase(expenseRepository: expRepo)

        let badExpense = Expense(dogId: UUID(), category: .food, amount: -15.0)
        #expect(throws: ExpenseError.negativeAmount) {
            try expenseUseCase.executeSave(badExpense)
        }
    }

    @Test func testExpenseCSVExportFormat() async throws {
        let expRepo = MockExpenseRepository()
        let expenseUseCase = ManageExpensesUseCase(expenseRepository: expRepo)

        let dogId = UUID()
        let exp = Expense(dogId: dogId, category: .vet, amount: 150.0, currency: "AUD", merchant: "UVTHS Camperdown")
        try expenseUseCase.executeSave(exp)

        let csv = try expenseUseCase.executeExportCSV(for: dogId)
        #expect(csv.contains("ID,Date,Category,Amount,Currency,Merchant,Notes"))
        #expect(csv.contains("Veterinary Care"))
        #expect(csv.contains("150.00"))
        #expect(csv.contains("UVTHS Camperdown"))
    }

    // 6. Sydney Pet Places Discovery
    @Test func testSydneyPetPlacesFiltering() async throws {
        let sydneyUseCase = GetSydneyPetPlacesUseCase()

        let all = sydneyUseCase.execute()
        #expect(all.count >= 10)

        let offLeashBeaches = sydneyUseCase.execute(category: .dogBeach)
        #expect(offLeashBeaches.count >= 2)
        #expect(offLeashBeaches.allSatisfy { $0.category == .dogBeach })

        let emergencyVets = sydneyUseCase.execute(category: .emergencyVet)
        #expect(emergencyVets.count >= 2)
        #expect(emergencyVets.contains { $0.name.contains("SASH") })

        let searchAlexandria = sydneyUseCase.execute(query: "Alexandria")
        #expect(searchAlexandria.count >= 2)
    }

    // 7. Widget Care Snapshot
    @Test func testWidgetCareSnapshotEncoding() async throws {
        let snapshot = WidgetCareSnapshot(
            dogName: "Archie",
            breed: "Cavoodle",
            nextTaskTitle: "River Walk",
            nextTaskCategory: "Walk",
            completedTodayCount: 3,
            totalTodayCount: 4,
            adherenceScore: 0.75
        )

        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(WidgetCareSnapshot.self, from: data)
        #expect(decoded.dogName == "Archie")
        #expect(decoded.completedTodayCount == 3)
        #expect(decoded.adherenceScore == 0.75)
    }
}
