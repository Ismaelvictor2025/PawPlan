//
//  CoreDataCareTaskRepository.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import CoreData

public final class CoreDataCareTaskRepository: CareTaskRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    public func fetchTasks(for dogId: UUID?) throws -> [CareTask] {
        var tasks: [CareTask] = []
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<CareTaskEntity> = CareTaskEntity.fetchRequest()
            if let dogId = dogId {
                request.predicate = NSPredicate(format: "dogId == %@", dogId as CVarArg)
            }
            request.sortDescriptors = [NSSortDescriptor(key: "scheduledDate", ascending: true)]
            do {
                let entities = try context.fetch(request)
                tasks = entities.map { CoreDataMappers.toDomain(entity: $0) }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return tasks
    }

    public func fetchUpcomingTasks(limit: Int = 10) throws -> [CareTask] {
        var tasks: [CareTask] = []
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<CareTaskEntity> = CareTaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isCompleted == NO")
            request.sortDescriptors = [NSSortDescriptor(key: "scheduledDate", ascending: true)]
            request.fetchLimit = limit
            do {
                let entities = try context.fetch(request)
                tasks = entities.map { CoreDataMappers.toDomain(entity: $0) }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return tasks
    }

    public func fetchNextTask(for dogId: UUID?) throws -> CareTask? {
        var task: CareTask?
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<CareTaskEntity> = CareTaskEntity.fetchRequest()
            var predicates: [NSPredicate] = [NSPredicate(format: "isCompleted == NO")]
            if let dogId = dogId {
                predicates.append(NSPredicate(format: "dogId == %@", dogId as CVarArg))
            }
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.sortDescriptors = [NSSortDescriptor(key: "scheduledDate", ascending: true)]
            request.fetchLimit = 1
            do {
                if let entity = try context.fetch(request).first {
                    task = CoreDataMappers.toDomain(entity: entity)
                }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return task
    }

    public func saveTask(_ task: CareTask) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<CareTaskEntity> = CareTaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            request.fetchLimit = 1
            do {
                let entity: CareTaskEntity
                if let existing = try context.fetch(request).first {
                    entity = existing
                } else {
                    entity = CareTaskEntity(context: context)
                }
                CoreDataMappers.update(entity: entity, from: task)

                // Wire dog relationship
                let dogRequest: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
                dogRequest.predicate = NSPredicate(format: "id == %@", task.dogId as CVarArg)
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

    public func deleteTask(id: UUID) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<CareTaskEntity> = CareTaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            do {
                if let entity = try context.fetch(request).first {
                    context.delete(entity)
                    if context.hasChanges {
                        try context.save()
                    }
                }
            } catch {
                thrownError = PersistenceError.saveFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
    }

    public func recordCompletion(_ completion: CareCompletion) throws {
        var thrownError: Error?
        context.performAndWait {
            do {
                let completionEntity = CareCompletionEntity(context: context)
                CoreDataMappers.update(entity: completionEntity, from: completion)

                // Wire task relationship
                let taskRequest: NSFetchRequest<CareTaskEntity> = CareTaskEntity.fetchRequest()
                taskRequest.predicate = NSPredicate(format: "id == %@", completion.taskId as CVarArg)
                if let task = try context.fetch(taskRequest).first {
                    completionEntity.task = task
                    task.isCompleted = true
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

    public func fetchCompletions(for dogId: UUID?, since: Date) throws -> [CareCompletion] {
        var completions: [CareCompletion] = []
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<CareCompletionEntity> = CareCompletionEntity.fetchRequest()
            var predicates: [NSPredicate] = [NSPredicate(format: "completedAt >= %@", since as CVarArg)]
            if let dogId = dogId {
                predicates.append(NSPredicate(format: "dogId == %@", dogId as CVarArg))
            }
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: false)]
            do {
                let entities = try context.fetch(request)
                completions = entities.map { CoreDataMappers.toDomain(entity: $0) }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return completions
    }
}
