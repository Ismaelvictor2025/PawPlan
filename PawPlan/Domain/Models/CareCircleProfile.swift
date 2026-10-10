//
//  CareCircleProfile.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Feature Expansion.
//

import Foundation

public struct CareCircleMedication: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var dosage: String
    public var frequency: String
    public var administrationInstructions: String?

    public init(
        id: UUID = UUID(),
        name: String,
        dosage: String,
        frequency: String,
        administrationInstructions: String? = nil
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.administrationInstructions = administrationInstructions
    }
}

public struct CareCircleProfile: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var dogId: UUID
    public var sitterName: String?
    public var sitterContact: String?

    // Feeding & Diet
    public var feedingSchedule: String
    public var dietaryRestrictions: String
    public var allergies: [String]
    public var treatGuidelines: String

    // Medications
    public var medications: [CareCircleMedication]

    // Walking & Exercise
    public var walkingRoutine: String
    public var favoriteParks: [String]
    public var leashGuidelines: String

    // Grooming & Bathing
    public var groomingInstructions: String
    public var bathingInstructions: String

    // Behavior & Triggers
    public var behavioralNotes: String
    public var triggers: [String]
    public var calmingTechniques: String

    // Emergency Contacts
    public var primaryContactName: String
    public var primaryContactPhone: String
    public var secondaryContactName: String?
    public var secondaryContactPhone: String?

    // Veterinarian Details
    public var vetClinicName: String
    public var vetDoctorName: String?
    public var vetPhone: String
    public var vetAddress: String
    public var emergency24hHospital: String

    // Special Instructions
    public var homeAccessNotes: String?
    public var sleepingArrangements: String
    public var specialCareNotes: String?
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        dogId: UUID,
        sitterName: String? = nil,
        sitterContact: String? = nil,
        feedingSchedule: String = "Morning (7:30 AM): 1 scoop kibble; Evening (6:00 PM): 1 scoop kibble + fresh water",
        dietaryRestrictions: String = "No chicken treats; sensitive stomach",
        allergies: [String] = ["Chicken protein", "Dairy products"],
        treatGuidelines: String = "Max 2 dental sticks per day, given after evening walk",
        medications: [CareCircleMedication] = [],
        walkingRoutine: String = "2 walks daily: 30-min morning river walk, 20-min evening neighborhood stroll",
        favoriteParks: [String] = ["Sydney Park off-leash area", "Sirius Cove dog beach"],
        leashGuidelines: String = "Keep on standard 1.5m leash near roads and unfamiliar dogs",
        groomingInstructions: String = "Wipe paws with damp cloth after rain; daily coat brush with slicker brush",
        bathingInstructions: String = "Warm water rinse only if muddy; dry thoroughly with towel",
        behavioralNotes: String = "Friendly and affectionate; loves gentle belly rubs and fetch",
        triggers: [String] = ["Thunderstorms", "Skateboards", "High-pitched sirens"],
        calmingTechniques: String = "Offer lick mat with peanut butter; play soft acoustic music; speak in soothing tones",
        primaryContactName: String = "Vicky (Owner)",
        primaryContactPhone: String = "+61 400 123 456",
        secondaryContactName: String? = "Alex (Co-Owner)",
        secondaryContactPhone: String? = "+61 400 987 654",
        vetClinicName: String = "Sydney University Veterinary Teaching Hospital",
        vetDoctorName: String? = "Dr. Sarah Mitchell",
        vetPhone: String = "(02) 9351 3437",
        vetAddress: String = "Evelyn Williams Building, 65 Parramatta Rd, Camperdown NSW 2050",
        emergency24hHospital: String = "SASH Alexandria: (02) 8913 4000 (24/7 Emergency)",
        homeAccessNotes: String? = "Spare key lockbox code available upon request; alarm PIN is disarmed during session",
        sleepingArrangements: String = "Sleeps in memory-foam bed in the bedroom; please keep door cracked open",
        specialCareNotes: String? = "Prefers fresh bowl of water refreshed twice daily. Call immediately if lethargic.",
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.dogId = dogId
        self.sitterName = sitterName
        self.sitterContact = sitterContact
        self.feedingSchedule = feedingSchedule
        self.dietaryRestrictions = dietaryRestrictions
        self.allergies = allergies
        self.treatGuidelines = treatGuidelines
        self.medications = medications
        self.walkingRoutine = walkingRoutine
        self.favoriteParks = favoriteParks
        self.leashGuidelines = leashGuidelines
        self.groomingInstructions = groomingInstructions
        self.bathingInstructions = bathingInstructions
        self.behavioralNotes = behavioralNotes
        self.triggers = triggers
        self.calmingTechniques = calmingTechniques
        self.primaryContactName = primaryContactName
        self.primaryContactPhone = primaryContactPhone
        self.secondaryContactName = secondaryContactName
        self.secondaryContactPhone = secondaryContactPhone
        self.vetClinicName = vetClinicName
        self.vetDoctorName = vetDoctorName
        self.vetPhone = vetPhone
        self.vetAddress = vetAddress
        self.emergency24hHospital = emergency24hHospital
        self.homeAccessNotes = homeAccessNotes
        self.sleepingArrangements = sleepingArrangements
        self.specialCareNotes = specialCareNotes
        self.updatedAt = updatedAt
    }

    public static func defaultProfile(for dog: Dog) -> CareCircleProfile {
        CareCircleProfile(
            dogId: dog.id,
            feedingSchedule: "\(dog.name) eats twice daily: 7:30 AM & 6:00 PM. Check fresh water daily.",
            dietaryRestrictions: "Strict dog food diet; avoid cooked bones, onions, grapes, and chocolate.",
            allergies: ["Chicken poultry meal (mild skin itch)"],
            walkingRoutine: "Morning 30-min walk & evening 20-min stroll in \(dog.suburb ?? "the neighborhood").",
            favoriteParks: ["Local fenced park", "Dog-friendly oval"],
            primaryContactName: "Owner of \(dog.name)",
            primaryContactPhone: "+61 400 123 456",
            vetClinicName: "Sydney Veterinary Hospital",
            vetPhone: "(02) 9351 3437",
            vetAddress: "Sydney, NSW, Australia",
            emergency24hHospital: "SASH Emergency 24/7: (02) 8913 4000"
        )
    }
}
