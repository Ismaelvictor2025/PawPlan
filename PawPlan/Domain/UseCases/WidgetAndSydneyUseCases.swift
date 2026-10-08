//
//  WidgetAndSydneyUseCases.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

public struct UpdateWidgetSnapshotUseCase: Sendable {
    private let dogRepository: DogRepositoryProtocol
    private let careTaskRepository: CareTaskRepositoryProtocol
    private let snapshotStore: WidgetSnapshotStore

    public init(
        dogRepository: DogRepositoryProtocol,
        careTaskRepository: CareTaskRepositoryProtocol,
        snapshotStore: WidgetSnapshotStore = .shared
    ) {
        self.dogRepository = dogRepository
        self.careTaskRepository = careTaskRepository
        self.snapshotStore = snapshotStore
    }

    public func execute(activeDogId: UUID? = nil) {
        do {
            let dogs = try dogRepository.fetchAllDogs()
            let targetDog: Dog?
            if let activeDogId = activeDogId {
                targetDog = dogs.first { $0.id == activeDogId } ?? dogs.first
            } else {
                targetDog = dogs.first
            }

            guard let dog = targetDog else {
                snapshotStore.save(snapshot: .fallback)
                return
            }

            let nextTask = try careTaskRepository.fetchNextTask(for: dog.id)
            let startOfToday = Calendar.current.startOfDay(for: Date())
            let completionsToday = try careTaskRepository.fetchCompletions(for: dog.id, since: startOfToday)
            let allTasks = try careTaskRepository.fetchTasks(for: dog.id)

            let snapshot = WidgetCareSnapshot(
                dogName: dog.name,
                breed: dog.breed,
                nextTaskTitle: nextTask?.title ?? "All caught up!",
                nextTaskCategory: nextTask?.category.rawValue ?? "Rest",
                nextTaskTime: nextTask?.scheduledDate ?? Date(),
                timeRemainingDescription: nextTask?.timeRemainingDescription ?? "Great job!",
                completedTodayCount: completionsToday.count,
                totalTodayCount: max(allTasks.count, completionsToday.count),
                adherenceScore: allTasks.isEmpty ? 1.0 : Double(completionsToday.count) / Double(max(1, allTasks.count)),
                lastUpdated: Date()
            )

            snapshotStore.save(snapshot: snapshot)

            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        } catch {
            print("UpdateWidgetSnapshotUseCase error: \(error)")
        }
    }
}

public struct GetSydneyPetPlacesUseCase: Sendable {
    public init() {}

    public func execute(category: SydneyPlaceCategory? = nil, query: String? = nil) -> [SydneyPetPlace] {
        var places = SydneyPetPlacesData.allPlaces
        if let category = category {
            places = places.filter { $0.category == category }
        }
        if let query = query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lower = query.lowercased()
            places = places.filter {
                $0.name.lowercased().contains(lower) ||
                $0.suburb.lowercased().contains(lower) ||
                $0.council.lowercased().contains(lower) ||
                $0.description.lowercased().contains(lower)
            }
        }
        return places
    }
}
