//
//  SydneyPetPlace.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import CoreLocation

public enum SydneyPlaceCategory: String, Codable, CaseIterable, Sendable {
    case offLeashPark = "Off-Leash Park"
    case dogBeach = "Dog-Friendly Beach"
    case emergencyVet = "24/7 Emergency Vet"
    case generalVet = "Veterinary Clinic"
    case dogCafe = "Pet-Friendly Café"
    case petSupplies = "Pet Care & Supplies"

    public var iconName: String {
        switch self {
        case .offLeashPark: return "leaf.fill"
        case .dogBeach: return "water.waves"
        case .emergencyVet: return "cross.fill"
        case .generalVet: return "cross.case.fill"
        case .dogCafe: return "cup.and.saucer.fill"
        case .petSupplies: return "cart.fill"
        }
    }

    public var colorHex: String {
        switch self {
        case .offLeashPark: return "#15D9D2" // Turquoise
        case .dogBeach: return "#85F4FF" // Cyan
        case .emergencyVet: return "#FF2A85" // Pink
        case .generalVet: return "#125BCE" // Electric Blue
        case .dogCafe: return "#FF7B00" // Orange
        case .petSupplies: return "#9D4EDD" // Violet
        }
    }
}

public struct SydneyPetPlace: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let name: String
    public let category: SydneyPlaceCategory
    public let suburb: String
    public let council: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let isOffLeash: Bool
    public let isFenced: Bool
    public let waterAvailable: Bool
    public let description: String
    public let hoursOrNotes: String
    public let contactPhone: String?
    public let officialSourceURL: String?

    public init(
        id: UUID = UUID(),
        name: String,
        category: SydneyPlaceCategory,
        suburb: String,
        council: String,
        address: String,
        latitude: Double,
        longitude: Double,
        isOffLeash: Bool,
        isFenced: Bool,
        waterAvailable: Bool,
        description: String,
        hoursOrNotes: String,
        contactPhone: String? = nil,
        officialSourceURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.suburb = suburb
        self.council = council
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.isOffLeash = isOffLeash
        self.isFenced = isFenced
        self.waterAvailable = waterAvailable
        self.description = description
        self.hoursOrNotes = hoursOrNotes
        self.contactPhone = contactPhone
        self.officialSourceURL = officialSourceURL
    }

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
