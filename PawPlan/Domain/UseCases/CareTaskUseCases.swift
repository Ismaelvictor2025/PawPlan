//
//  CareTaskUseCases.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation

public struct GetUpcomingCareTasksUseCase: Sendable {
    private let careTaskRepository: CareTaskRepositoryProtocol

    public init(careTaskRepository: CareTaskRepositoryProtocol) {
        self.careTaskRepository = careTaskRepository
    }

    public func execute(for dogId: UUID? = nil) throws -> [CareTask] {
        let tasks = try careTaskRepository.fetchTasks(for: dogId)
        // Sort: incomplete first by scheduledDate ascending, then completed
        return tasks.sorted {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted && $1.isCompleted
            }
            return $0.scheduledDate < $1.scheduledDate
        }
    }

    public func executeNext(for dogId: UUID? = nil) throws -> CareTask? {
        return try careTaskRepository.fetchNextTask(for: dogId)
    }
}

public struct CompleteCareTaskUseCase: Sendable {
    private let careTaskRepository: CareTaskRepositoryProtocol

    public init(careTaskRepository: CareTaskRepositoryProtocol) {
        self.careTaskRepository = careTaskRepository
    }

    public func execute(task: CareTask, notes: String? = nil) throws -> CareTask {
        guard !task.isCompleted else {
            throw CareSchedulingError.cannotCompleteAlreadyCompletedTask
        }

        // 1. Record completion log
        let completion = CareCompletion(
            id: UUID(),
            taskId: task.id,
            dogId: task.dogId,
            completedAt: Date(),
            completedBy: "Owner",
            notes: notes
        )
        try careTaskRepository.recordCompletion(completion)

        var updatedTask = task

        // 2. Handle recurrence
        switch task.recurrenceRule {
        case .none:
            updatedTask.isCompleted = true
            try careTaskRepository.saveTask(updatedTask)

        case .daily:
            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: task.scheduledDate) ?? Date()
            updatedTask.scheduledDate = nextDate
            updatedTask.isCompleted = false
            try careTaskRepository.saveTask(updatedTask)

        case .weekdays:
            let nextDate = nextWeekday(after: task.scheduledDate)
            updatedTask.scheduledDate = nextDate
            updatedTask.isCompleted = false
            try careTaskRepository.saveTask(updatedTask)

        case .weekends:
            let nextDate = nextWeekendDay(after: task.scheduledDate)
            updatedTask.scheduledDate = nextDate
            updatedTask.isCompleted = false
            try careTaskRepository.saveTask(updatedTask)

        case .weekly:
            let nextDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: task.scheduledDate) ?? Date()
            updatedTask.scheduledDate = nextDate
            updatedTask.isCompleted = false
            try careTaskRepository.saveTask(updatedTask)

        case .biweekly:
            let nextDate = Calendar.current.date(byAdding: .day, value: 14, to: task.scheduledDate) ?? Date()
            updatedTask.scheduledDate = nextDate
            updatedTask.isCompleted = false
            try careTaskRepository.saveTask(updatedTask)

        case .monthly:
            let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: task.scheduledDate) ?? Date()
            updatedTask.scheduledDate = nextDate
            updatedTask.isCompleted = false
            try careTaskRepository.saveTask(updatedTask)
        }

        return updatedTask
    }

    private func nextWeekday(after date: Date) -> Date {
        let calendar = Calendar.current
        var current = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        while calendar.isDateInWeekend(current) {
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return current
    }

    private func nextWeekendDay(after date: Date) -> Date {
        let calendar = Calendar.current
        var current = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        while !calendar.isDateInWeekend(current) {
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return current
    }
}
