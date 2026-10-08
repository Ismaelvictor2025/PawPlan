//
//  RepositoryProtocols.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation

public protocol DogRepositoryProtocol: Sendable {
    func fetchAllDogs() throws -> [Dog]
    func fetchDog(id: UUID) throws -> Dog?
    func saveDog(_ dog: Dog) throws
    func deleteDog(id: UUID) throws
}

public protocol CareTaskRepositoryProtocol: Sendable {
    func fetchTasks(for dogId: UUID?) throws -> [CareTask]
    func fetchUpcomingTasks(limit: Int) throws -> [CareTask]
    func fetchNextTask(for dogId: UUID?) throws -> CareTask?
    func saveTask(_ task: CareTask) throws
    func deleteTask(id: UUID) throws
    func recordCompletion(_ completion: CareCompletion) throws
    func fetchCompletions(for dogId: UUID?, since: Date) throws -> [CareCompletion]
}

public protocol HealthRecordRepositoryProtocol: Sendable {
    func fetchHealthRecords(for dogId: UUID) throws -> [HealthRecord]
    func saveHealthRecord(_ record: HealthRecord) throws
    func deleteHealthRecord(id: UUID) throws
    func fetchVetAppointments(for dogId: UUID) throws -> [VetAppointment]
    func saveVetAppointment(_ appointment: VetAppointment) throws
    func deleteVetAppointment(id: UUID) throws
}

public protocol TrainingRepositoryProtocol: Sendable {
    func fetchTrainingProgress(for dogId: UUID) throws -> [TrainingProgress]
    func saveTrainingProgress(_ progress: TrainingProgress) throws
}

public protocol ExpenseRepositoryProtocol: Sendable {
    func fetchExpenses(for dogId: UUID?, from: Date?, to: Date?) throws -> [Expense]
    func saveExpense(_ expense: Expense) throws
    func deleteExpense(id: UUID) throws
}

public protocol DocumentRepositoryProtocol: Sendable {
    func fetchDocuments(for dogId: UUID) throws -> [DocumentRecord]
    func saveDocument(_ document: DocumentRecord) throws
    func deleteDocument(id: UUID) throws
}
