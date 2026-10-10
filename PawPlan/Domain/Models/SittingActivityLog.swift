//
//  SittingActivityLog.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Dog Sitting Mode.
//

import Foundation

public enum SittingActivityType: String, Codable, CaseIterable, Sendable {
    case feeding = "Feeding"
    case walk = "Walk"
    case medication = "Medication"
    case water = "Fresh Water"
    case grooming = "Grooming & Bathing"
    case photoUpdate = "Photo Update"
    case note = "General Note"

    public var iconName: String {
        switch self {
        case .feeding: return "fork.knife"
        case .walk: return "figure.walk"
        case .medication: return "pills.fill"
        case .water: return "drop.fill"
        case .grooming: return "scissors"
        case .photoUpdate: return "camera.fill"
        case .note: return "note.text"
        }
    }

    public var badgeColorHex: String {
        switch self {
        case .feeding: return "#15D9D2"     // Turquoise
        case .walk: return "#125BCE"        // Electric Blue
        case .medication: return "#00E676"  // Green
        case .water: return "#85F4FF"       // Light Cyan
        case .grooming: return "#9D4EDD"    // Violet
        case .photoUpdate: return "#FF7B00" // Orange
        case .note: return "#FF2A85"        // Pink
        }
    }
}

public struct SittingActivityLog: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var sessionId: UUID
    public var dogId: UUID
    public var activityType: SittingActivityType
    public var title: String
    public var notes: String?
    public var timestamp: Date
    public var loggedBy: String
    public var locationLatitude: Double?
    public var locationLongitude: Double?

    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        dogId: UUID,
        activityType: SittingActivityType,
        title: String,
        notes: String? = nil,
        timestamp: Date = Date(),
        loggedBy: String,
        locationLatitude: Double? = nil,
        locationLongitude: Double? = nil
    ) {
        self.id = id
        self.sessionId = sessionId
        self.dogId = dogId
        self.activityType = activityType
        self.title = title
        self.notes = notes
        self.timestamp = timestamp
        self.loggedBy = loggedBy
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
    }

    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
