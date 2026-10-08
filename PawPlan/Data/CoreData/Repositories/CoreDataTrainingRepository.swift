//
//  CoreDataTrainingRepository.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import CoreData

public final class CoreDataTrainingRepository: TrainingRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    public func fetchTrainingProgress(for dogId: UUID) throws -> [TrainingProgress] {
        var progressList: [TrainingProgress] = []
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<TrainingProgressEntity> = TrainingProgressEntity.fetchRequest()
            request.predicate = NSPredicate(format: "dogId == %@", dogId as CVarArg)
            do {
                let entities = try context.fetch(request)
                progressList = entities.map { CoreDataMappers.toDomain(entity: $0) }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return progressList
    }

    public func saveTrainingProgress(_ progress: TrainingProgress) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<TrainingProgressEntity> = TrainingProgressEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "dogId == %@ AND moduleKey == %@ AND milestoneKey == %@",
                progress.dogId as CVarArg,
                progress.moduleKey,
                progress.milestoneKey
            )
            request.fetchLimit = 1
            do {
                let entity: TrainingProgressEntity
                if let existing = try context.fetch(request).first {
                    entity = existing
                } else {
                    entity = TrainingProgressEntity(context: context)
                }
                CoreDataMappers.update(entity: entity, from: progress)

                let dogRequest: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
                dogRequest.predicate = NSPredicate(format: "id == %@", progress.dogId as CVarArg)
                if let dog = try context.fetch(dogRequest).first {
                    entity.dog = dog
                }

                if context.hasChanges {
                    try context.save()
                }
            } catch {
                thrownError = PersistenceError.saveFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
    }
}
