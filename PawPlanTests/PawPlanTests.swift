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

final class MockCareCircleRepository: CareCircleRepositoryProtocol, @unchecked Sendable {
    var profiles: [UUID: CareCircleProfile] = [:]
    var shouldFail: Bool = false

    func fetchProfile(for dogId: UUID) throws -> CareCircleProfile? {
        if shouldFail { throw CareCircleError.persistenceFailed("Forced mock query error") }
        return profiles[dogId]
    }

    func saveProfile(_ profile: CareCircleProfile) throws {
        if shouldFail { throw CareCircleError.persistenceFailed("Forced mock save error") }
        profiles[profile.dogId] = profile
    }

    func deleteProfile(for dogId: UUID) throws {
        if shouldFail { throw CareCircleError.persistenceFailed("Forced mock delete error") }
        profiles.removeValue(forKey: dogId)
    }
}

final class MockSittingSessionRepository: SittingSessionRepositoryProtocol, @unchecked Sendable {
    var sessions: [UUID: SittingSession] = [:]
    var activities: [UUID: [SittingActivityLog]] = [:]
    var shouldFail: Bool = false

    func fetchSessions(for dogId: UUID?) throws -> [SittingSession] {
        if shouldFail { throw SittingSessionError.persistenceFailed("Forced mock query error") }
        let all = Array(sessions.values)
        if let dogId = dogId {
            return all.filter { $0.dogId == dogId }
        }
        return all
    }

    func fetchSession(id: UUID) throws -> SittingSession? {
        if shouldFail { throw SittingSessionError.persistenceFailed("Forced mock query error") }
        return sessions[id]
    }

    func saveSession(_ session: SittingSession) throws {
        if shouldFail { throw SittingSessionError.persistenceFailed("Forced mock save error") }
        sessions[session.id] = session
    }

    func deleteSession(id: UUID) throws {
        if shouldFail { throw SittingSessionError.persistenceFailed("Forced mock delete error") }
        sessions.removeValue(forKey: id)
        activities.removeValue(forKey: id)
    }

    func recordActivity(_ activity: SittingActivityLog) throws {
        if shouldFail { throw SittingSessionError.persistenceFailed("Forced mock activity save error") }
        activities[activity.sessionId, default: []].append(activity)
    }

    func fetchActivities(for sessionId: UUID) throws -> [SittingActivityLog] {
        if shouldFail { throw SittingSessionError.persistenceFailed("Forced mock activity query error") }
        return activities[sessionId] ?? []
    }

    func deleteActivity(id: UUID) throws {
        if shouldFail { throw SittingSessionError.persistenceFailed("Forced mock activity delete error") }
        for (sessId, list) in activities {
            activities[sessId] = list.filter { $0.id != id }
        }
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

    // 8. Care Circle Validation & Invariants
    @Test func testCareCircleValidationFailures() async throws {
        let careRepo = MockCareCircleRepository()
        let dogRepo = MockDogRepository()
        let useCase = ManageCareCircleUseCase(repository: careRepo, dogRepository: dogRepo)

        let dog = Dog(name: "Archie", breed: "Cavoodle", weight: 8.5)
        try dogRepo.saveDog(dog)
        var profile = CareCircleProfile.defaultProfile(for: dog)

        // 1. Empty Primary Contact
        profile.primaryContactName = ""
        #expect(throws: CareCircleError.emptyPrimaryContact) {
            try useCase.executeSaveProfile(profile)
        }

        // 2. Empty Vet Clinic
        profile.primaryContactName = "Sarah Jenkins"
        profile.vetClinicName = "   "
        #expect(throws: CareCircleError.emptyVetClinic) {
            try useCase.executeSaveProfile(profile)
        }

        // 3. Invalid Medication
        profile.vetClinicName = "Camperdown Vet Clinic"
        profile.medications = [
            CareCircleMedication(name: "", dosage: "10mg", frequency: "Daily")
        ]
        #expect(throws: CareCircleError.self) {
            try useCase.executeSaveProfile(profile)
        }
    }

    @Test func testCareCircleProfileLifecycle() async throws {
        let careRepo = MockCareCircleRepository()
        let dogRepo = MockDogRepository()
        let useCase = ManageCareCircleUseCase(repository: careRepo, dogRepository: dogRepo)

        let dog = Dog(name: "Archie", breed: "Cavoodle", weight: 8.5)
        try dogRepo.saveDog(dog)

        // Fetches default fallback profile if none exists
        let initial = try useCase.executeGetProfile(for: dog.id)
        #expect(initial.dogId == dog.id)
        #expect(initial.primaryContactName == "Owner of \(dog.name)")

        // Saves updated profile
        var updated = initial
        updated.primaryContactName = "Alex Smith"
        updated.primaryContactPhone = "0412 345 678"
        updated.feedingSchedule = "1 cup raw kibble at 7:30 AM and 6:00 PM"
        updated.medications = [
            CareCircleMedication(name: "Apoquel", dosage: "5.4mg", frequency: "Once daily with breakfast")
        ]
        try useCase.executeSaveProfile(updated)

        let retrieved = try useCase.executeGetProfile(for: dog.id)
        #expect(retrieved.primaryContactName == "Alex Smith")
        #expect(retrieved.medications.count == 1)
        #expect(retrieved.medications.first?.name == "Apoquel")

        // Delete profile
        try useCase.executeDeleteProfile(for: dog.id)
        #expect(careRepo.profiles[dog.id] == nil)
    }

    // 9. Selective Disclosure & Secure Sharing
    @Test func testCareCircleSelectiveDisclosureSummary() async throws {
        let dog = Dog(name: "Archie", breed: "Cavoodle", weight: 8.5)
        var profile = CareCircleProfile.defaultProfile(for: dog)
        profile.primaryContactName = "Alex Owner"
        profile.primaryContactPhone = "0400 111 222"
        profile.homeAccessNotes = "Secret Lockbox code: 9942 under the blue pot plant."
        profile.behavioralNotes = "Severe fear of fireworks and thunder."
        profile.feedingSchedule = "Two balanced meals daily."

        let exportUseCase = ExportCareInstructionsUseCase()

        // Config 1: Exclude sensitive home access and behavioral notes
        var configNoAccess = CareCircleShareConfig()
        configNoAccess.includeHomeAccessNotes = false
        configNoAccess.includeBehaviorAndTriggers = false
        configNoAccess.includeFeedingAndDiet = true
        configNoAccess.includeEmergencyContacts = true

        let summaryRedacted = exportUseCase.executeGenerateSummary(profile: profile, dog: dog, config: configNoAccess)
        #expect(!summaryRedacted.contains("9942"))
        #expect(!summaryRedacted.contains("Lockbox code"))
        #expect(!summaryRedacted.contains("fireworks and thunder"))
        #expect(summaryRedacted.contains("Two balanced meals daily"))
        #expect(summaryRedacted.contains("Alex Owner"))

        // Config 2: Explicitly include home access
        var configWithAccess = CareCircleShareConfig()
        configWithAccess.includeHomeAccessNotes = true
        configWithAccess.includeBehaviorAndTriggers = true

        let summaryFull = exportUseCase.executeGenerateSummary(profile: profile, dog: dog, config: configWithAccess)
        #expect(summaryFull.contains("9942"))
        #expect(summaryFull.contains("fireworks and thunder"))
    }

    // 10. Dog Sitting Session Invariants and Lifecycle
    @Test func testSittingSessionValidationAndLifecycle() async throws {
        let sessionRepo = MockSittingSessionRepository()
        let manageSessionUseCase = ManageSittingSessionUseCase(repository: sessionRepo)

        let dogId = UUID()
        let now = Date()

        // 1. Invalid date range (end before start)
        let invalidSession = SittingSession(
            dogId: dogId,
            sitterName: "Jordan",
            startDate: now,
            endDate: now.addingTimeInterval(-3600)
        )
        #expect(throws: SittingSessionError.invalidDateRange) {
            try manageSessionUseCase.executeCreateSession(invalidSession)
        }

        // 2. Empty sitter name
        let blankSitterSession = SittingSession(
            dogId: dogId,
            sitterName: "   ",
            startDate: now,
            endDate: now.addingTimeInterval(7200)
        )
        #expect(throws: SittingSessionError.emptySitterName) {
            try manageSessionUseCase.executeCreateSession(blankSitterSession)
        }

        // 3. Valid creation, start, and completion
        let validSession = SittingSession(
            dogId: dogId,
            sitterName: "Jordan Parker",
            sitterPhone: "0433 999 888",
            startDate: now,
            endDate: now.addingTimeInterval(14400)
        )
        try manageSessionUseCase.executeCreateSession(validSession)
        #expect(validSession.status == .scheduled)

        let activeSession = try manageSessionUseCase.executeStartSession(id: validSession.id)
        #expect(activeSession.status == .active)

        // Enable location sharing during active session
        let sharingSession = try manageSessionUseCase.executeUpdateLocationSharing(id: validSession.id, isSharing: true)
        #expect(sharingSession.isLocationSharingActive == true)

        // Complete session: location sharing MUST automatically terminate
        let completedSession = try manageSessionUseCase.executeCompleteSession(id: validSession.id)
        #expect(completedSession.status == .completed)
        #expect(completedSession.isLocationSharingActive == false)

        // Attempting to restart an already completed session should throw
        #expect(throws: SittingSessionError.sessionAlreadyCompleted) {
            try manageSessionUseCase.executeStartSession(id: validSession.id)
        }
    }

    // 11. Sitter Activity Logging & 5 Core Care Pillars
    @Test func testSittingActivityLoggingAndPillars() async throws {
        let sessionRepo = MockSittingSessionRepository()
        let manageSessionUseCase = ManageSittingSessionUseCase(repository: sessionRepo)
        let recordActivityUseCase = RecordSittingActivityUseCase(repository: sessionRepo)

        let dogId = UUID()
        let session = SittingSession(
            dogId: dogId,
            sitterName: "Jordan",
            startDate: Date(),
            endDate: Date().addingTimeInterval(14400)
        )
        try manageSessionUseCase.executeCreateSession(session)
        _ = try manageSessionUseCase.executeStartSession(id: session.id)

        // Check initial empty progress
        let initialReport = try recordActivityUseCase.executeCalculateProgress(for: session.id)
        #expect(initialReport.totalCoreActivities == 5)
        #expect(initialReport.completedCoreActivities == 0)
        #expect(initialReport.progressRate == 0.0)
        #expect(initialReport.isComplete == false)

        // Log 1: Feeding
        _ = try recordActivityUseCase.executeRecordActivity(
            sessionId: session.id,
            dogId: dogId,
            type: .feeding,
            title: "Morning Kibble & Wet Food",
            notes: "Ate the entire bowl happily",
            loggedBy: "Jordan"
        )

        // Log 2: Leash Walk with GPS Coordinate
        _ = try recordActivityUseCase.executeRecordActivity(
            sessionId: session.id,
            dogId: dogId,
            type: .walk,
            title: "Centennial Park Walk",
            notes: "35 mins brisk walk",
            loggedBy: "Jordan",
            latitude: -33.8967,
            longitude: 151.2335
        )

        // Log 3: Medication
        _ = try recordActivityUseCase.executeRecordActivity(
            sessionId: session.id,
            dogId: dogId,
            type: .medication,
            title: "Apoquel 5.4mg",
            notes: "Given with treat",
            loggedBy: "Jordan"
        )

        // Log 4: Water
        _ = try recordActivityUseCase.executeRecordActivity(
            sessionId: session.id,
            dogId: dogId,
            type: .water,
            title: "Refilled Ceramic Bowl",
            notes: "Cold filtered water",
            loggedBy: "Jordan"
        )

        // Log 5: Grooming
        _ = try recordActivityUseCase.executeRecordActivity(
            sessionId: session.id,
            dogId: dogId,
            type: .grooming,
            title: "Evening Fur Brushing",
            notes: "Brushed out burs after park",
            loggedBy: "Jordan"
        )

        let fullReport = try recordActivityUseCase.executeCalculateProgress(for: session.id)
        #expect(fullReport.completedCoreActivities == 5)
        #expect(fullReport.progressRate == 1.0)
        #expect(fullReport.hasFed == true)
        #expect(fullReport.hasWalked == true)
        #expect(fullReport.hasGivenMedication == true)
        #expect(fullReport.hasRefreshedWater == true)
        #expect(fullReport.hasGroomed == true)
        #expect(fullReport.isComplete == true)

        let activities = try recordActivityUseCase.executeFetchActivities(for: session.id)
        #expect(activities.count == 5)
        #expect(activities.contains { $0.locationLatitude != nil && $0.locationLongitude != nil })
    }

    // 12. Smart Care Notifications & Duplicate Prevention
    @Test func testSmartCareNotificationsDeterminismAndCategories() async throws {
        let dogId = UUID()
        let request1 = SmartReminderRequest(
            id: "walk_morning_001",
            dogId: dogId,
            dogName: "Archie",
            category: .walk,
            title: "Morning Park Walk",
            scheduledDate: Date()
        )

        let request2 = SmartReminderRequest(
            id: "walk_morning_001",
            dogId: dogId,
            dogName: "Archie",
            category: .walk,
            title: "Morning Park Walk",
            scheduledDate: Date()
        )

        // Both requests must yield the exact same deterministic notification identifier to guarantee duplicate cancellation
        #expect(request1.deterministicNotificationId == request2.deterministicNotificationId)
        #expect(request1.deterministicNotificationId == "pawplan_smart_walk_walk_morning_001")

        // Test all 9 categories have valid notification identifiers and default copy
        for category in SmartReminderCategory.allCases {
            #expect(!category.notificationCategoryIdentifier.isEmpty)
            #expect(category.notificationCategoryIdentifier.hasPrefix("PAWPLAN_"))
            #expect(!category.defaultBodyMessage.isEmpty)
        }
        #expect(SmartReminderCategory.allCases.count == 9)
    }

    // 13. AirTag Compatibility Truthfulness
    @Test func testAirTagCompatibilityDocumentation() async throws {
        #expect(AirTagCompatibilityInfo.isThirdPartyLiveTrackingAvailable == false)
        #expect(AirTagCompatibilityInfo.limitationSummary.contains("Apple does not provide a public"))
        #expect(AirTagCompatibilityInfo.recommendedWorkflowSteps.count >= 4)
    }

    // 14. Repository Failures and Typed Domain Errors
    @Test func testRepositoryFailurePropagation() async throws {
        let careRepo = MockCareCircleRepository()
        careRepo.shouldFail = true
        let dogRepo = MockDogRepository()
        let careUseCase = ManageCareCircleUseCase(repository: careRepo, dogRepository: dogRepo)

        let dog = Dog(name: "Archie", breed: "Cavoodle")
        let profile = CareCircleProfile.defaultProfile(for: dog)

        #expect(throws: CareCircleError.self) {
            try careUseCase.executeSaveProfile(profile)
        }

        let sessionRepo = MockSittingSessionRepository()
        sessionRepo.shouldFail = true
        let sessionUseCase = ManageSittingSessionUseCase(repository: sessionRepo)

        let session = SittingSession(
            dogId: dog.id,
            sitterName: "Jordan",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600)
        )

        #expect(throws: SittingSessionError.self) {
            try sessionUseCase.executeCreateSession(session)
        }
    }
}
