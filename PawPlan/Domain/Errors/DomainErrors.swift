//
//  DomainErrors.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation

public enum DogProfileError: LocalizedError, Equatable {
    case emptyName
    case invalidWeight
    case dogNotFound(UUID)
    case duplicateMicrochip(String)

    public var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Dog name cannot be empty."
        case .invalidWeight:
            return "Weight must be greater than zero."
        case .dogNotFound(let id):
            return "No dog profile found with identifier \(id)."
        case .duplicateMicrochip(let chip):
            return "Microchip number \(chip) is already registered."
        }
    }
}

public enum CareSchedulingError: LocalizedError, Equatable {
    case invalidScheduledDate
    case taskNotFound(UUID)
    case missingCategory
    case cannotCompleteAlreadyCompletedTask

    public var errorDescription: String? {
        switch self {
        case .invalidScheduledDate:
            return "The scheduled time cannot be in the past when creating a new recurring event."
        case .taskNotFound(let id):
            return "Care task \(id) was not found."
        case .missingCategory:
            return "A care category must be specified."
        case .cannotCompleteAlreadyCompletedTask:
            return "This task has already been recorded as completed."
        }
    }
}

public enum HealthRecordError: LocalizedError, Equatable {
    case emptyTitle
    case invalidDueDate

    public var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Health record title cannot be blank."
        case .invalidDueDate:
            return "Next due date cannot precede the administration date."
        }
    }
}

public enum ExpenseError: LocalizedError, Equatable {
    case invalidAmount
    case negativeAmount

    public var errorDescription: String? {
        switch self {
        case .invalidAmount, .negativeAmount:
            return "Expense amount must be positive."
        }
    }
}

public enum PersistenceError: LocalizedError, Equatable {
    case saveFailed(String)
    case fetchFailed(String)
    case entityNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .saveFailed(let msg):
            return "Failed to save record to persistent store: \(msg)"
        case .fetchFailed(let msg):
            return "Failed to retrieve records from store: \(msg)"
        case .entityNotFound(let msg):
            return "Requested entity not found in persistent store: \(msg)"
        }
    }
}
