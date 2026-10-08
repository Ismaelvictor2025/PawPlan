//
//  Dog.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation

public enum DogSex: String, Codable, CaseIterable, Sendable {
    case male = "Male"
    case female = "Female"
}

public struct Dog: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var breed: String
    public var birthDate: Date?
    public var weight: Double // in kilograms
    public var sex: DogSex
    public var isDesexed: Bool
    public var microchipNumber: String?
    public var councilRegistration: String?
    public var careNotes: String?
    public var suburb: String?
    public var photoData: Data?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        breed: String,
        birthDate: Date? = nil,
        weight: Double = 0.0,
        sex: DogSex = .male,
        isDesexed: Bool = true,
        microchipNumber: String? = nil,
        councilRegistration: String? = nil,
        careNotes: String? = nil,
        suburb: String? = nil,
        photoData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.birthDate = birthDate
        self.weight = weight
        self.sex = sex
        self.isDesexed = isDesexed
        self.microchipNumber = microchipNumber
        self.councilRegistration = councilRegistration
        self.careNotes = careNotes
        self.suburb = suburb
        self.photoData = photoData
        self.createdAt = createdAt
    }

    public var ageDescription: String {
        guard let birthDate = birthDate else { return "Age unknown" }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: birthDate, to: now)
        let years = components.year ?? 0
        let months = components.month ?? 0

        if years == 0 {
            if months <= 1 {
                return "1 month old"
            }
            return "\(months) months old"
        } else if years == 1 && months == 0 {
            return "1 year old"
        } else if months == 0 {
            return "\(years) years old"
        } else {
            return "\(years)y \(months)m old"
        }
    }

    public var weightDescription: String {
        return String(format: "%.1f kg", weight)
    }
}
