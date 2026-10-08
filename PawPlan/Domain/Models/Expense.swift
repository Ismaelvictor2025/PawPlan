//
//  Expense.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation

public enum ExpenseCategory: String, Codable, CaseIterable, Sendable {
    case food = "Food & Treats"
    case vet = "Veterinary Care"
    case grooming = "Grooming & Spa"
    case toys = "Toys & Enrichment"
    case insurance = "Pet Insurance"
    case training = "Training & Puppy School"
    case medication = "Medication & Parasite"
    case gear = "Gear & Collars"
    case other = "Other Pet Costs"

    public var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .vet: return "cross.case.fill"
        case .grooming: return "scissors"
        case .toys: return "tennisball.fill"
        case .insurance: return "shield.fill"
        case .training: return "rosette"
        case .medication: return "pills.fill"
        case .gear: return "bag.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    public var colorHex: String {
        switch self {
        case .food: return "#15D9D2" // Turquoise
        case .vet: return "#FF2A85" // Pink
        case .grooming: return "#9D4EDD" // Violet
        case .toys: return "#85F4FF" // Cyan
        case .insurance: return "#125BCE" // Electric Blue
        case .training: return "#FF7B00" // Orange
        case .medication: return "#00E676" // Green
        case .gear: return "#E0AAFF" // Lavender
        case .other: return "#FFB703" // Amber
        }
    }
}

public struct Expense: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var dogId: UUID
    public var category: ExpenseCategory
    public var amount: Double
    public var currency: String
    public var date: Date
    public var merchant: String?
    public var notes: String?

    public init(
        id: UUID = UUID(),
        dogId: UUID,
        category: ExpenseCategory,
        amount: Double,
        currency: String = "AUD",
        date: Date = Date(),
        merchant: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.dogId = dogId
        self.category = category
        self.amount = amount
        self.currency = currency
        self.date = date
        self.merchant = merchant
        self.notes = notes
    }

    public var formattedAmount: String {
        return String(format: "$%.2f", amount)
    }
}

public enum DocumentCategory: String, Codable, CaseIterable, Sendable {
    case vaccinationCert = "Vaccination Certificate"
    case councilRegistration = "Council Registration Tag"
    case microchipCert = "NSW Pet Registry Certificate"
    case insurancePolicy = "Pet Insurance Policy"
    case vetInvoice = "Vet Medical Invoice"
    case adoptionCert = "Adoption / Pedigree Papers"
    case other = "Other Pet Document"

    public var iconName: String {
        switch self {
        case .vaccinationCert: return "doc.text.fill"
        case .councilRegistration: return "tag.fill"
        case .microchipCert: return "antenna.radiowaves.left.and.right"
        case .insurancePolicy: return "checkmark.shield.fill"
        case .vetInvoice: return "newspaper.fill"
        case .adoptionCert: return "heart.text.square.fill"
        case .other: return "folder.fill"
        }
    }
}

public struct DocumentRecord: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var dogId: UUID
    public var title: String
    public var category: DocumentCategory
    public var fileName: String
    public var fileExtension: String?
    public var expiryDate: Date?
    public var createdAt: Date
    public var notes: String?

    public init(
        id: UUID = UUID(),
        dogId: UUID,
        title: String,
        category: DocumentCategory,
        fileName: String,
        fileExtension: String? = nil,
        expiryDate: Date? = nil,
        createdAt: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.dogId = dogId
        self.title = title
        self.category = category
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.expiryDate = expiryDate
        self.createdAt = createdAt
        self.notes = notes
    }
}
