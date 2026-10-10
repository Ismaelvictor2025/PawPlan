//
//  CareCircleUseCases.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Feature Expansion.
//

import Foundation
import UIKit

public struct ManageCareCircleUseCase: Sendable {
    private let repository: CareCircleRepositoryProtocol
    private let dogRepository: DogRepositoryProtocol

    public init(repository: CareCircleRepositoryProtocol, dogRepository: DogRepositoryProtocol) {
        self.repository = repository
        self.dogRepository = dogRepository
    }

    public func executeGetProfile(for dogId: UUID) throws -> CareCircleProfile {
        if let existing = try repository.fetchProfile(for: dogId) {
            return existing
        }
        guard let dog = try dogRepository.fetchDog(id: dogId) else {
            throw DogProfileError.dogNotFound(dogId)
        }
        let fallback = CareCircleProfile.defaultProfile(for: dog)
        try repository.saveProfile(fallback)
        return fallback
    }

    public func executeSaveProfile(_ profile: CareCircleProfile) throws {
        // Validation Invariants
        let primaryName = profile.primaryContactName.trimmingCharacters(in: .whitespacesAndNewlines)
        let primaryPhone = profile.primaryContactPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        if primaryName.isEmpty || primaryPhone.isEmpty {
            throw CareCircleError.emptyPrimaryContact
        }

        let vetClinic = profile.vetClinicName.trimmingCharacters(in: .whitespacesAndNewlines)
        if vetClinic.isEmpty {
            throw CareCircleError.emptyVetClinic
        }

        for med in profile.medications {
            if med.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw CareCircleError.invalidMedication("Medication name cannot be blank.")
            }
            if med.dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw CareCircleError.invalidMedication("Dosage required for \(med.name).")
            }
        }

        var updated = profile
        updated.updatedAt = Date()
        try repository.saveProfile(updated)
    }

    public func executeDeleteProfile(for dogId: UUID) throws {
        try repository.deleteProfile(for: dogId)
    }
}

public struct ExportCareInstructionsUseCase: Sendable {
    public init() {}

    public func executeGenerateSummary(profile: CareCircleProfile, dog: Dog, config: CareCircleShareConfig) -> String {
        config.generateFormattedSummary(profile: profile, dog: dog)
    }

    @MainActor
    public func executeGeneratePDF(profile: CareCircleProfile, dog: Dog, config: CareCircleShareConfig) -> Data {
        config.generatePDF(profile: profile, dog: dog)
    }
}
