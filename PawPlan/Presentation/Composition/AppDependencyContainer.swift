//
//  AppDependencyContainer.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
public final class AppDependencyContainer: ObservableObject {
    public static let shared = AppDependencyContainer()

    // Persistence
    public let persistenceController: PersistenceController

    // Repositories
    public let dogRepository: DogRepositoryProtocol
    public let careTaskRepository: CareTaskRepositoryProtocol
    public let healthRecordRepository: HealthRecordRepositoryProtocol
    public let trainingRepository: TrainingRepositoryProtocol
    public let expenseRepository: ExpenseRepositoryProtocol
    public let documentRepository: DocumentRepositoryProtocol

    // Use Cases
    public let getDogsUseCase: GetDogsUseCase
    public let saveDogUseCase: SaveDogUseCase
    public let deleteDogUseCase: DeleteDogUseCase
    public let getUpcomingCareTasksUseCase: GetUpcomingCareTasksUseCase
    public let completeCareTaskUseCase: CompleteCareTaskUseCase
    public let calculateCareConsistencyUseCase: CalculateCareConsistencyUseCase
    public let manageExpensesUseCase: ManageExpensesUseCase
    public let updateWidgetSnapshotUseCase: UpdateWidgetSnapshotUseCase
    public let getSydneyPetPlacesUseCase: GetSydneyPetPlacesUseCase

    // Services
    public let notificationService: NotificationSchedulingService

    // Published State
    @Published public var dogs: [Dog] = []
    @Published public var activeDog: Dog?
    @Published public var isDemoMode: Bool = true
    @Published public var isOnboardingCompleted: Bool = true

    public init(
        persistenceController: PersistenceController = .shared,
        dogRepository: DogRepositoryProtocol? = nil,
        careTaskRepository: CareTaskRepositoryProtocol? = nil,
        healthRecordRepository: HealthRecordRepositoryProtocol? = nil,
        trainingRepository: TrainingRepositoryProtocol? = nil,
        expenseRepository: ExpenseRepositoryProtocol? = nil,
        documentRepository: DocumentRepositoryProtocol? = nil
    ) {
        self.persistenceController = persistenceController
        let viewContext = persistenceController.viewContext

        let dRepo = dogRepository ?? CoreDataDogRepository(context: viewContext)
        let cRepo = careTaskRepository ?? CoreDataCareTaskRepository(context: viewContext)
        let hRepo = healthRecordRepository ?? CoreDataHealthRecordRepository(context: viewContext)
        let tRepo = trainingRepository ?? CoreDataTrainingRepository(context: viewContext)
        let eRepo = expenseRepository ?? CoreDataExpenseRepository(context: viewContext)
        let docRepo = documentRepository ?? CoreDataDocumentRepository(context: viewContext)

        self.dogRepository = dRepo
        self.careTaskRepository = cRepo
        self.healthRecordRepository = hRepo
        self.trainingRepository = tRepo
        self.expenseRepository = eRepo
        self.documentRepository = docRepo

        self.getDogsUseCase = GetDogsUseCase(dogRepository: dRepo)
        self.saveDogUseCase = SaveDogUseCase(dogRepository: dRepo)
        self.deleteDogUseCase = DeleteDogUseCase(dogRepository: dRepo)
        self.getUpcomingCareTasksUseCase = GetUpcomingCareTasksUseCase(careTaskRepository: cRepo)
        self.completeCareTaskUseCase = CompleteCareTaskUseCase(careTaskRepository: cRepo)
        self.calculateCareConsistencyUseCase = CalculateCareConsistencyUseCase(careTaskRepository: cRepo)
        self.manageExpensesUseCase = ManageExpensesUseCase(expenseRepository: eRepo)
        self.updateWidgetSnapshotUseCase = UpdateWidgetSnapshotUseCase(dogRepository: dRepo, careTaskRepository: cRepo)
        self.getSydneyPetPlacesUseCase = GetSydneyPetPlacesUseCase()

        self.notificationService = NotificationSchedulingService.shared

        // Load initial state
        refreshDogs()

        if dogs.isEmpty {
            DevelopmentDemoData.seed(container: self)
            refreshDogs()
        }
    }

    public func refreshDogs() {
        do {
            self.dogs = try getDogsUseCase.execute()
            if activeDog == nil || !dogs.contains(where: { $0.id == activeDog?.id }) {
                self.activeDog = dogs.first
            }
            if let active = self.activeDog {
                self.updateWidgetSnapshotUseCase.execute(activeDogId: active.id)
            }
        } catch {
            print("Failed to load dogs: \(error)")
        }
    }

    public func selectDog(_ dog: Dog) {
        self.activeDog = dog
        self.updateWidgetSnapshotUseCase.execute(activeDogId: dog.id)
    }

    public func saveDog(_ dog: Dog) {
        do {
            try saveDogUseCase.execute(dog)
            refreshDogs()
            self.activeDog = dog
            self.updateWidgetSnapshotUseCase.execute(activeDogId: dog.id)
        } catch {
            print("Error saving dog: \(error)")
        }
    }

    public func resetToDemoData() {
        // Clear and re-seed
        let context = persistenceController.viewContext
        let entities = ["DogEntity", "CareTaskEntity", "CareCompletionEntity", "VetAppointmentEntity", "HealthRecordEntity", "TrainingProgressEntity", "ExpenseEntity", "DocumentRecordEntity"]
        for entity in entities {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let delete = NSBatchDeleteRequest(fetchRequest: fetch)
            _ = try? context.execute(delete)
        }
        try? context.save()
        DevelopmentDemoData.seed(container: self)
        refreshDogs()
    }
}
