//
//  CoreDataDogRepository.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import CoreData

public final class CoreDataDogRepository: DogRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    public func fetchAllDogs() throws -> [Dog] {
        var dogs: [Dog] = []
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            do {
                let entities = try context.fetch(request)
                dogs = entities.map { CoreDataMappers.toDomain(entity: $0) }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return dogs
    }

    public func fetchDog(id: UUID) throws -> Dog? {
        var dog: Dog?
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            do {
                if let entity = try context.fetch(request).first {
                    dog = CoreDataMappers.toDomain(entity: entity)
                }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return dog
    }

    public func saveDog(_ dog: Dog) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", dog.id as CVarArg)
            request.fetchLimit = 1
            do {
                let entity: DogEntity
                if let existing = try context.fetch(request).first {
                    entity = existing
                } else {
                    entity = DogEntity(context: context)
                }
                CoreDataMappers.update(entity: entity, from: dog)
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                thrownError = PersistenceError.saveFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
    }

    public func deleteDog(id: UUID) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
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
}
