//
//  CareTask.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import SwiftUI

public enum CareTaskCategory: String, Codable, CaseIterable, Sendable {
    case walk = "Walk"
    case feeding = "Feeding"
    case water = "Fresh Water"
    case grooming = "Grooming"
    case medication = "Medication"
    case vetCheckup = "Vet Check-up"
    case training = "Training"
    case parasitePrevention = "Tick & Flea Prevention"
    case custom = "Custom Care"

    public var iconName: String {
        switch self {
        case .walk: return "figure.walk"
        case .feeding: return "fork.knife"
        case .water: return "drop.fill"
        case .grooming: return "scissors"
        case .medication: return "pills.fill"
        case .vetCheckup: return "cross.case.fill"
        case .training: return "target"
        case .parasitePrevention: return "shield.lefthalf.filled"
        case .custom: return "pawprint.fill"
        }
    }

    public var accentColorHex: String {
        switch self {
        case .walk: return "#125BCE" // Electric Blue
        case .feeding: return "#15D9D2" // Turquoise
        case .water: return "#85F4FF" // Light Cyan
        case .grooming: return "#9D4EDD" // Violet
        case .medication: return "#00E676" // Green
        case .vetCheckup: return "#FF2A85" // Pink
        case .training: return "#FF7B00" // Orange
        case .parasitePrevention: return "#15D9D2"
        case .custom: return "#125BCE"
        }
    }
}

public enum CareRecurrenceRule: String, Codable, CaseIterable, Sendable {
    case none = "Once"
    case daily = "Every Day"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
    case weekly = "Weekly"
    case biweekly = "Every 2 Weeks"
    case monthly = "Monthly"
}

public enum CarePriority: String, Codable, CaseIterable, Sendable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
    case urgent = "Urgent"

    public var badgeColorHex: String {
        switch self {
        case .low: return "#85F4FF"
        case .normal: return "#15D9D2"
        case .high: return "#FF7B00"
        case .urgent: return "#FF2A85"
        }
    }
}

public struct CareTask: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var dogId: UUID
    public var title: String
    public var category: CareTaskCategory
    public var recurrenceRule: CareRecurrenceRule
    public var intervalDays: Int
    public var scheduledDate: Date
    public var durationMinutes: Int
    public var priority: CarePriority
    public var notes: String?
    public var isCompleted: Bool
    public var reminderEnabled: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        dogId: UUID,
        title: String,
        category: CareTaskCategory = .walk,
        recurrenceRule: CareRecurrenceRule = .daily,
        intervalDays: Int = 1,
        scheduledDate: Date = Date(),
        durationMinutes: Int = 15,
        priority: CarePriority = .normal,
        notes: String? = nil,
        isCompleted: Bool = false,
        reminderEnabled: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.dogId = dogId
        self.title = title
        self.category = category
        self.recurrenceRule = recurrenceRule
        self.intervalDays = intervalDays
        self.scheduledDate = scheduledDate
        self.durationMinutes = durationMinutes
        self.priority = priority
        self.notes = notes
        self.isCompleted = isCompleted
        self.reminderEnabled = reminderEnabled
        self.createdAt = createdAt
    }

    public var isOverdue: Bool {
        return !isCompleted && scheduledDate < Date()
    }

    public var timeRemainingDescription: String {
        let now = Date()
        if isCompleted {
            return "Completed"
        }
        if scheduledDate < now {
            let diff = Int(now.timeIntervalSince(scheduledDate) / 60)
            if diff < 60 {
                return "\(diff)m overdue"
            }
            let hours = diff / 60
            return "\(hours)h overdue"
        } else {
            let diff = Int(scheduledDate.timeIntervalSince(now) / 60)
            if diff < 60 {
                return "In \(diff)m"
            }
            let hours = diff / 60
            if hours < 24 {
                let mins = diff % 60
                return mins > 0 ? "In \(hours)h \(mins)m" : "In \(hours)h"
            }
            let days = hours / 24
            return "In \(days)d"
        }
    }
}

public struct CareCompletion: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var taskId: UUID
    public var dogId: UUID
    public var completedAt: Date
    public var completedBy: String?
    public var notes: String?

    public init(
        id: UUID = UUID(),
        taskId: UUID,
        dogId: UUID,
        completedAt: Date = Date(),
        completedBy: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.taskId = taskId
        self.dogId = dogId
        self.completedAt = completedAt
        self.completedBy = completedBy
        self.notes = notes
    }
}
