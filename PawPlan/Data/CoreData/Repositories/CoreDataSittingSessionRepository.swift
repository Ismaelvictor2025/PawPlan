//
//  CoreDataSittingSessionRepository.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Dog Sitting Mode.
//

import Foundation
import CoreData

public final class CoreDataSittingSessionRepository: SittingSessionRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func fetchSessions(for dogId: UUID?) throws -> [SittingSession] {
        let request: NSFetchRequest<SittingSessionEntity> = SittingSessionEntity.fetchRequest()
        if let dogId = dogId {
            request.predicate = NSPredicate(format: "dogId == %@", dogId as CVarArg)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]

        let results = try context.fetch(request)
        return results.map(CoreDataMappers.toDomain)
    }

    public func fetchSession(id: UUID) throws -> SittingSession? {
        let request: NSFetchRequest<SittingSessionEntity> = SittingSessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        let results = try context.fetch(request)
        return results.first.map(CoreDataMappers.toDomain)
    }

    public func saveSession(_ session: SittingSession) throws {
        let request: NSFetchRequest<SittingSessionEntity> = SittingSessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)

        let existing = try context.fetch(request)
        let entity: SittingSessionEntity

        if let found = existing.first {
            entity = found
        } else {
            entity = SittingSessionEntity(context: context)
        }

        CoreDataMappers.update(entity: entity, from: session)

        let dogRequest: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
        dogRequest.predicate = NSPredicate(format: "id == %@", session.dogId as CVarArg)
        if let dogEntity = try context.fetch(dogRequest).first {
            entity.dog = dogEntity
        }

        try context.save()
    }

    public func deleteSession(id: UUID) throws {
        let request: NSFetchRequest<SittingSessionEntity> = SittingSessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        let results = try context.fetch(request)
        for entity in results {
            context.delete(entity)
        }

        if context.hasChanges {
            try context.save()
        }
    }

    public func fetchActivities(for sessionId: UUID) throws -> [SittingActivityLog] {
        let request: NSFetchRequest<SittingActivityEntity> = SittingActivityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        let results = try context.fetch(request)
        return results.map(CoreDataMappers.toDomain)
    }

    public func recordActivity(_ activity: SittingActivityLog) throws {
        let entity = SittingActivityEntity(context: context)
        CoreDataMappers.update(entity: entity, from: activity)

        let sessionRequest: NSFetchRequest<SittingSessionEntity> = SittingSessionEntity.fetchRequest()
        sessionRequest.predicate = NSPredicate(format: "id == %@", activity.sessionId as CVarArg)
        if let sessionEntity = try context.fetch(sessionRequest).first {
            entity.session = sessionEntity
        }

        try context.save()
    }

    public func deleteActivity(id: UUID) throws {
        let request: NSFetchRequest<SittingActivityEntity> = SittingActivityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        let results = try context.fetch(request)
        for entity in results {
            context.delete(entity)
        }

        if context.hasChanges {
            try context.save()
        }
    }
}
