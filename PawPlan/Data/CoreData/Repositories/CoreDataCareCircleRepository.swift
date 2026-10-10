//
//  CoreDataCareCircleRepository.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Feature Expansion.
//

import Foundation
import CoreData

public final class CoreDataCareCircleRepository: CareCircleRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func fetchProfile(for dogId: UUID) throws -> CareCircleProfile? {
        let request: NSFetchRequest<CareCircleProfileEntity> = CareCircleProfileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "dogId == %@", dogId as CVarArg)
        request.fetchLimit = 1

        let results = try context.fetch(request)
        return results.first.map(CoreDataMappers.toDomain)
    }

    public func saveProfile(_ profile: CareCircleProfile) throws {
        let request: NSFetchRequest<CareCircleProfileEntity> = CareCircleProfileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "dogId == %@", profile.dogId as CVarArg)

        let existing = try context.fetch(request)
        let entity: CareCircleProfileEntity

        if let found = existing.first {
            entity = found
        } else {
            entity = CareCircleProfileEntity(context: context)
        }

        CoreDataMappers.update(entity: entity, from: profile)

        // Associate with DogEntity if present
        let dogRequest: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
        dogRequest.predicate = NSPredicate(format: "id == %@", profile.dogId as CVarArg)
        if let dogEntity = try context.fetch(dogRequest).first {
            entity.dog = dogEntity
        }

        try context.save()
    }

    public func deleteProfile(for dogId: UUID) throws {
        let request: NSFetchRequest<CareCircleProfileEntity> = CareCircleProfileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "dogId == %@", dogId as CVarArg)

        let results = try context.fetch(request)
        for entity in results {
            context.delete(entity)
        }

        if context.hasChanges {
            try context.save()
        }
    }
}
