//
//  SittingSession.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Dog Sitting Mode.
//

import Foundation

public enum SittingSessionStatus: String, Codable, CaseIterable, Sendable {
    case scheduled = "Scheduled"
    case active = "Active"
    case completed = "Completed"
    case cancelled = "Cancelled"

    public var badgeColorHex: String {
        switch self {
        case .scheduled: return "#85F4FF" // Cyan
        case .active: return "#15D9D2"    // Turquoise
        case .completed: return "#00E676" // Green
        case .cancelled: return "#EF4444" // Red
        }
    }
}

public struct SittingSession: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var dogId: UUID
    public var sitterName: String
    public var sitterPhone: String?
    public var startDate: Date
    public var endDate: Date
    public var status: SittingSessionStatus
    public var emergencyContact: String?
    public var specialInstructions: String?
    public var isLocationSharingActive: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        dogId: UUID,
        sitterName: String,
        sitterPhone: String? = nil,
        startDate: Date = Date(),
        endDate: Date = Date().addingTimeInterval(86400),
        status: SittingSessionStatus = .scheduled,
        emergencyContact: String? = nil,
        specialInstructions: String? = nil,
        isLocationSharingActive: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.dogId = dogId
        self.sitterName = sitterName
        self.sitterPhone = sitterPhone
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.emergencyContact = emergencyContact
        self.specialInstructions = specialInstructions
        self.isLocationSharingActive = isLocationSharingActive
        self.createdAt = createdAt
    }

    public var isCurrentlyOngoing: Bool {
        return status == .active
    }

    public var formattedDurationDescription: String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: startDate, to: endDate)
    }
}
