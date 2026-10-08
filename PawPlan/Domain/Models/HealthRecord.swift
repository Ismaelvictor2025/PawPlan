//
//  HealthRecord.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation

public enum HealthRecordType: String, Codable, CaseIterable, Sendable {
    case vaccination = "Vaccination (C5/C3)"
    case worming = "Intestinal Worming"
    case fleaTick = "Paralysis Tick & Flea"
    case heartworm = "Heartworm Prevention"
    case weightLog = "Weight Check"
    case allergy = "Allergy & Dietary"
    case general = "General Health Note"

    public var iconName: String {
        switch self {
        case .vaccination: return "syringe.fill"
        case .worming: return "shield.checkered"
        case .fleaTick: return "shield.fill"
        case .heartworm: return "heart.fill"
        case .weightLog: return "scalemass.fill"
        case .allergy: return "exclamationmark.triangle.fill"
        case .general: return "heart.text.square.fill"
        }
    }
}

public struct HealthRecord: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var dogId: UUID
    public var recordType: HealthRecordType
    public var title: String
    public var recordDate: Date
    public var nextDueDate: Date?
    public var notes: String?
    public var veterinarian: String?
    public var batchNumber: String?

    public init(
        id: UUID = UUID(),
        dogId: UUID,
        recordType: HealthRecordType,
        title: String,
        recordDate: Date = Date(),
        nextDueDate: Date? = nil,
        notes: String? = nil,
        veterinarian: String? = nil,
        batchNumber: String? = nil
    ) {
        self.id = id
        self.dogId = dogId
        self.recordType = recordType
        self.title = title
        self.recordDate = recordDate
        self.nextDueDate = nextDueDate
        self.notes = notes
        self.veterinarian = veterinarian
        self.batchNumber = batchNumber
    }
}

public struct VetAppointment: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var dogId: UUID
    public var clinicName: String
    public var vetName: String?
    public var scheduledDate: Date
    public var reason: String
    public var notes: String?
    public var contactPhone: String?
    public var isCompleted: Bool

    public init(
        id: UUID = UUID(),
        dogId: UUID,
        clinicName: String,
        vetName: String? = nil,
        scheduledDate: Date,
        reason: String,
        notes: String? = nil,
        contactPhone: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.dogId = dogId
        self.clinicName = clinicName
        self.vetName = vetName
        self.scheduledDate = scheduledDate
        self.reason = reason
        self.notes = notes
        self.contactPhone = contactPhone
        self.isCompleted = isCompleted
    }
}
