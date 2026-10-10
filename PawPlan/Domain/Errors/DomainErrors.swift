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

public enum CareCircleError: LocalizedError, Equatable {
    case profileNotFound(UUID)
    case emptyPrimaryContact
    case emptyVetClinic
    case invalidMedication(String)
    case sharingFailed(String)
    case persistenceFailed(String)

    public var errorDescription: String? {
        switch self {
        case .profileNotFound(let id):
            return "No Care Circle profile found for dog \(id)."
        case .emptyPrimaryContact:
            return "Primary emergency contact name and phone number are required."
        case .emptyVetClinic:
            return "Veterinary clinic name is required."
        case .invalidMedication(let reason):
            return "Medication validation failed: \(reason)"
        case .sharingFailed(let msg):
            return "Could not prepare care packet for sharing: \(msg)"
        case .persistenceFailed(let msg):
            return "Care Circle persistence error: \(msg)"
        }
    }
}

public enum SittingSessionError: LocalizedError, Equatable {
    case sessionNotFound(UUID)
    case invalidDateRange
    case emptySitterName
    case sessionAlreadyCompleted
    case sessionNotActive
    case locationSharingDenied
    case persistenceFailed(String)

    public var errorDescription: String? {
        switch self {
        case .sessionNotFound(let id):
            return "Sitting session \(id) was not found."
        case .invalidDateRange:
            return "Session end time must be after the start time."
        case .emptySitterName:
            return "Sitter name cannot be blank."
        case .sessionAlreadyCompleted:
            return "Cannot modify or log activities to an already completed sitting session."
        case .sessionNotActive:
            return "Activities can only be recorded while the sitting session is active."
        case .locationSharingDenied:
            return "Location sharing requires Location Services permission to be granted in Settings."
        case .persistenceFailed(let msg):
            return "Sitting session persistence error: \(msg)"
        }
    }
}

