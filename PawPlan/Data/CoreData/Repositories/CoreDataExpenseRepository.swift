//
//  CoreDataExpenseRepository.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import CoreData

public final class CoreDataExpenseRepository: ExpenseRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    public func fetchExpenses(for dogId: UUID?, from: Date?, to: Date?) throws -> [Expense] {
        var expenses: [Expense] = []
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
            var predicates: [NSPredicate] = []
            if let dogId = dogId {
                predicates.append(NSPredicate(format: "dogId == %@", dogId as CVarArg))
            }
            if let from = from {
                predicates.append(NSPredicate(format: "date >= %@", from as CVarArg))
            }
            if let to = to {
                predicates.append(NSPredicate(format: "date <= %@", to as CVarArg))
            }
            if !predicates.isEmpty {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            do {
                let entities = try context.fetch(request)
                expenses = entities.map { CoreDataMappers.toDomain(entity: $0) }
            } catch {
                thrownError = PersistenceError.fetchFailed(error.localizedDescription)
            }
        }
        if let error = thrownError { throw error }
        return expenses
    }

    public func saveExpense(_ expense: Expense) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
            request.fetchLimit = 1
            do {
                let entity: ExpenseEntity
                if let existing = try context.fetch(request).first {
                    entity = existing
                } else {
                    entity = ExpenseEntity(context: context)
                }
                CoreDataMappers.update(entity: entity, from: expense)

                let dogRequest: NSFetchRequest<DogEntity> = DogEntity.fetchRequest()
                dogRequest.predicate = NSPredicate(format: "id == %@", expense.dogId as CVarArg)
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

    public func deleteExpense(id: UUID) throws {
        var thrownError: Error?
        context.performAndWait {
            let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
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
