//
//  CoreDataDocumentRepository.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import CoreData

public final class CoreDataDocumentRepository: DocumentRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    public func fetchDocuments(for dogId: UUID) throws -> [DocumentRecord] {
        var documents: [DocumentRecord] = []
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<DocumentRecordEntity> = DocumentRecordEntity.fetchRequest()
            request.predicate = NSPredicate(format: "dogId == %@", dogId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            do {
                let entities = try context.fetch(request)
                documents = entities.map { CoreDataMappers.toDomain(entity: $0) }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return documents
    }

    public func saveDocument(_ document: DocumentRecord) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<DocumentRecordEntity> = DocumentRecordEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)
            request.fetchLimit = 1
            do {
                let entity: DocumentRecordEntity
                if let existing = try context.fetch(request).first {
                    entity = existing
                } else {
                    entity = DocumentRecordEntity(context: context)
                }
                CoreDataMappers.update(entity: entity, from: document)

                let dogRequest: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
                dogRequest.predicate = NSPredicate(format: "id == %@", document.dogId as CVarArg)
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

    public func deleteDocument(id: UUID) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<DocumentRecordEntity> = DocumentRecordEntity.fetchRequest()
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
