//
//  PersistenceController.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import CoreData
import Foundation

public final class PersistenceController: @unchecked Sendable {
    public nonisolated static let shared = PersistenceController()

    public let container: NSPersistentContainer

    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PawPlan")
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                #if DEBUG
                print("[PersistenceController] Core Data store load warning: \(error), \(error.userInfo)")
                #endif
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    public func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                throw PersistenceError.saveFailed("\(nsError.localizedDescription) (\(nsError.userInfo))")
            }
        }
    }

    @MainActor
    public static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.viewContext
        // Populate preview seed data
        let dog = DogEntity(context: context)
        dog.id = UUID()
        dog.name = "Archie"
        dog.breed = "Cavoodle"
        dog.birthDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        dog.weight = 8.4
        dog.sex = "Male"
        dog.isDesexed = true
        dog.suburb = "Surry Hills"
        dog.councilRegistration = "NSW-SYD-88219"
        dog.microchipNumber = "953010002934812"
        dog.careNotes = "Loves fetch in Prince Alfred Park; prefers dry grain-free kibble."
        dog.createdAt = Date()

        let task1 = CareTaskEntity(context: context)
        task1.id = UUID()
        task1.dogId = dog.id
        task1.title = "Morning River Walk"
        task1.category = "Walk"
        task1.recurrenceRule = "Every Day"
        task1.intervalDays = 1
        task1.scheduledDate = Calendar.current.date(byAdding: .minute, value: 35, to: Date()) ?? Date()
        task1.durationMinutes = 30
        task1.priority = "normal"
        task1.notes = "Bring leash and collapsible water bowl."
        task1.isCompleted = false
        task1.reminderEnabled = true
        task1.createdAt = Date()
        task1.dog = dog

        let task2 = CareTaskEntity(context: context)
        task2.id = UUID()
        task2.dogId = dog.id
        task2.title = "Breakfast Feeding"
        task2.category = "Feeding"
        task2.recurrenceRule = "Every Day"
        task2.intervalDays = 1
        task2.scheduledDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
        task2.durationMinutes = 10
        task2.priority = "high"
        task2.notes = "1 scoop puppy kibble + fresh water."
        task2.isCompleted = false
        task2.reminderEnabled = true
        task2.createdAt = Date()
        task2.dog = dog

        try? context.save()
        return controller
    }()
}
