//
//  CoreDataHealthRecordRepository.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import CoreData

public final class CoreDataHealthRecordRepository: HealthRecordRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    public func fetchHealthRecords(for dogId: UUID) throws -> [HealthRecord] {
        var records: [HealthRecord] = []
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<HealthRecordEntity> = HealthRecordEntity.fetchRequest()
            request.predicate = NSPredicate(format: "dogId == %@", dogId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "recordDate", ascending: false)]
            do {
                let entities = try context.fetch(request)
                records = entities.map { CoreDataMappers.toDomain(entity: $0) }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return records
    }

    public func saveHealthRecord(_ record: HealthRecord) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<HealthRecordEntity> = HealthRecordEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)
            request.fetchLimit = 1
            do {
                let entity: HealthRecordEntity
                if let existing = try context.fetch(request).first {
                    entity = existing
                } else {
                    entity = HealthRecordEntity(context: context)
                }
                CoreDataMappers.update(entity: entity, from: record)

                // Wire dog relation
                let dogRequest: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
                dogRequest.predicate = NSPredicate(format: "id == %@", record.dogId as CVarArg)
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

    public func deleteHealthRecord(id: UUID) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<HealthRecordEntity> = HealthRecordEntity.fetchRequest()
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

    public func fetchVetAppointments(for dogId: UUID) throws -> [VetAppointment] {
        var appointments: [VetAppointment] = []
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<VetAppointmentEntity> = VetAppointmentEntity.fetchRequest()
            request.predicate = NSPredicate(format: "dogId == %@", dogId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "scheduledDate", ascending: true)]
            do {
                let entities = try context.fetch(request)
                appointments = entities.map { CoreDataMappers.toDomain(entity: $0) }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return appointments
    }

    public func saveVetAppointment(_ appointment: VetAppointment) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<VetAppointmentEntity> = VetAppointmentEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", appointment.id as CVarArg)
            request.fetchLimit = 1
            do {
                let entity: VetAppointmentEntity
                if let existing = try context.fetch(request).first {
                    entity = existing
                } else {
                    entity = VetAppointmentEntity(context: context)
                }
                CoreDataMappers.update(entity: entity, from: appointment)

                let dogRequest: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
                dogRequest.predicate = NSPredicate(format: "id == %@", appointment.dogId as CVarArg)
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

    public func deleteVetAppointment(id: UUID) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<VetAppointmentEntity> = VetAppointmentEntity.fetchRequest()
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
