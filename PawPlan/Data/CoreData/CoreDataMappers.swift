//
//  CoreDataMappers.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import CoreData

public enum CoreDataMappers {

    // MARK: - Dog
    public static func toDomain(entity: DogEntity) -> Dog {
        let sex = DogSex(rawValue: entity.sex ?? "") ?? .male
        return Dog(
            id: entity.id ?? UUID(),
            name: entity.name ?? "Unknown Dog",
            breed: entity.breed ?? "Mixed Breed",
            birthDate: entity.birthDate,
            weight: entity.weight,
            sex: sex,
            isDesexed: entity.isDesexed,
            microchipNumber: entity.microchipNumber,
            councilRegistration: entity.councilRegistration,
            careNotes: entity.careNotes,
            suburb: entity.suburb,
            photoData: entity.photoData,
            createdAt: entity.createdAt ?? Date()
        )
    }

    public static func update(entity: DogEntity, from domain: Dog) {
        entity.id = domain.id
        entity.name = domain.name
        entity.breed = domain.breed
        entity.birthDate = domain.birthDate
        entity.weight = domain.weight
        entity.sex = domain.sex.rawValue
        entity.isDesexed = domain.isDesexed
        entity.microchipNumber = domain.microchipNumber
        entity.councilRegistration = domain.councilRegistration
        entity.careNotes = domain.careNotes
        entity.suburb = domain.suburb
        entity.photoData = domain.photoData
        entity.createdAt = domain.createdAt
    }

    // MARK: - CareTask
    public static func toDomain(entity: CareTaskEntity) -> CareTask {
        let category = CareTaskCategory(rawValue: entity.category ?? "") ?? .walk
        let recurrence = CareRecurrenceRule(rawValue: entity.recurrenceRule ?? "") ?? .daily
        let priority = CarePriority(rawValue: entity.priority ?? "") ?? .normal
        return CareTask(
            id: entity.id ?? UUID(),
            dogId: entity.dogId ?? UUID(),
            title: entity.title ?? "Care Task",
            category: category,
            recurrenceRule: recurrence,
            intervalDays: Int(entity.intervalDays),
            scheduledDate: entity.scheduledDate ?? Date(),
            durationMinutes: Int(entity.durationMinutes),
            priority: priority,
            notes: entity.notes,
            isCompleted: entity.isCompleted,
            reminderEnabled: entity.reminderEnabled,
            createdAt: entity.createdAt ?? Date()
        )
    }

    public static func update(entity: CareTaskEntity, from domain: CareTask) {
        entity.id = domain.id
        entity.dogId = domain.dogId
        entity.title = domain.title
        entity.category = domain.category.rawValue
        entity.recurrenceRule = domain.recurrenceRule.rawValue
        entity.intervalDays = Int32(domain.intervalDays)
        entity.scheduledDate = domain.scheduledDate
        entity.durationMinutes = Int32(domain.durationMinutes)
        entity.priority = domain.priority.rawValue
        entity.notes = domain.notes
        entity.isCompleted = domain.isCompleted
        entity.reminderEnabled = domain.reminderEnabled
        entity.createdAt = domain.createdAt
    }

    // MARK: - CareCompletion
    public static func toDomain(entity: CareCompletionEntity) -> CareCompletion {
        return CareCompletion(
            id: entity.id ?? UUID(),
            taskId: entity.taskId ?? UUID(),
            dogId: entity.dogId ?? UUID(),
            completedAt: entity.completedAt ?? Date(),
            completedBy: entity.completedBy,
            notes: entity.notes
        )
    }

    public static func update(entity: CareCompletionEntity, from domain: CareCompletion) {
        entity.id = domain.id
        entity.taskId = domain.taskId
        entity.dogId = domain.dogId
        entity.completedAt = domain.completedAt
        entity.completedBy = domain.completedBy
        entity.notes = domain.notes
    }

    // MARK: - HealthRecord
    public static func toDomain(entity: HealthRecordEntity) -> HealthRecord {
        let type = HealthRecordType(rawValue: entity.recordType ?? "") ?? .general
        return HealthRecord(
            id: entity.id ?? UUID(),
            dogId: entity.dogId ?? UUID(),
            recordType: type,
            title: entity.title ?? "Health Note",
            recordDate: entity.recordDate ?? Date(),
            nextDueDate: entity.nextDueDate,
            notes: entity.notes,
            veterinarian: entity.veterinarian,
            batchNumber: entity.batchNumber
        )
    }

    public static func update(entity: HealthRecordEntity, from domain: HealthRecord) {
        entity.id = domain.id
        entity.dogId = domain.dogId
        entity.recordType = domain.recordType.rawValue
        entity.title = domain.title
        entity.recordDate = domain.recordDate
        entity.nextDueDate = domain.nextDueDate
        entity.notes = domain.notes
        entity.veterinarian = domain.veterinarian
        entity.batchNumber = domain.batchNumber
    }

    // MARK: - VetAppointment
    public static func toDomain(entity: VetAppointmentEntity) -> VetAppointment {
        return VetAppointment(
            id: entity.id ?? UUID(),
            dogId: entity.dogId ?? UUID(),
            clinicName: entity.clinicName ?? "Vet Clinic",
            vetName: entity.vetName,
            scheduledDate: entity.scheduledDate ?? Date(),
            reason: entity.reason ?? "Checkup",
            notes: entity.notes,
            contactPhone: entity.contactPhone,
            isCompleted: entity.isCompleted
        )
    }

    public static func update(entity: VetAppointmentEntity, from domain: VetAppointment) {
        entity.id = domain.id
        entity.dogId = domain.dogId
        entity.clinicName = domain.clinicName
        entity.vetName = domain.vetName
        entity.scheduledDate = domain.scheduledDate
        entity.reason = domain.reason
        entity.notes = domain.notes
        entity.contactPhone = domain.contactPhone
        entity.isCompleted = domain.isCompleted
    }

    // MARK: - TrainingProgress
    public static func toDomain(entity: TrainingProgressEntity) -> TrainingProgress {
        return TrainingProgress(
            id: entity.id ?? UUID(),
            dogId: entity.dogId ?? UUID(),
            moduleKey: entity.moduleKey ?? "",
            milestoneKey: entity.milestoneKey ?? "",
            title: entity.title ?? "",
            isCompleted: entity.isCompleted,
            completedAt: entity.completedAt,
            rating: Int(entity.rating),
            notes: entity.notes
        )
    }

    public static func update(entity: TrainingProgressEntity, from domain: TrainingProgress) {
        entity.id = domain.id
        entity.dogId = domain.dogId
        entity.moduleKey = domain.moduleKey
        entity.milestoneKey = domain.milestoneKey
        entity.title = domain.title
        entity.isCompleted = domain.isCompleted
        entity.completedAt = domain.completedAt
        entity.rating = Int16(domain.rating)
        entity.notes = domain.notes
    }

    // MARK: - Expense
    public static func toDomain(entity: ExpenseEntity) -> Expense {
        let cat = ExpenseCategory(rawValue: entity.category ?? "") ?? .other
        return Expense(
            id: entity.id ?? UUID(),
            dogId: entity.dogId ?? UUID(),
            category: cat,
            amount: entity.amount,
            currency: entity.currency ?? "AUD",
            date: entity.date ?? Date(),
            merchant: entity.merchant,
            notes: entity.notes
        )
    }

    public static func update(entity: ExpenseEntity, from domain: Expense) {
        entity.id = domain.id
        entity.dogId = domain.dogId
        entity.category = domain.category.rawValue
        entity.amount = domain.amount
        entity.currency = domain.currency
        entity.date = domain.date
        entity.merchant = domain.merchant
        entity.notes = domain.notes
    }

    // MARK: - DocumentRecord
    public static func toDomain(entity: DocumentRecordEntity) -> DocumentRecord {
        let cat = DocumentCategory(rawValue: entity.category ?? "") ?? .other
        return DocumentRecord(
            id: entity.id ?? UUID(),
            dogId: entity.dogId ?? UUID(),
            title: entity.title ?? "Document",
            category: cat,
            fileName: entity.fileName ?? "doc.pdf",
            fileExtension: entity.fileExtension,
            expiryDate: entity.expiryDate,
            createdAt: entity.createdAt ?? Date(),
            notes: entity.notes
        )
    }

    public static func update(entity: DocumentRecordEntity, from domain: DocumentRecord) {
        entity.id = domain.id
        entity.dogId = domain.dogId
        entity.title = domain.title
        entity.category = domain.category.rawValue
        entity.fileName = domain.fileName
        entity.fileExtension = domain.fileExtension
        entity.expiryDate = domain.expiryDate
        entity.createdAt = domain.createdAt
        entity.notes = domain.notes
    }

    // MARK: - CareCircleProfile
    public static func toDomain(entity: CareCircleProfileEntity) -> CareCircleProfile {
        let allergies: [String] = {
            guard let json = entity.allergiesJSON?.data(using: .utf8),
                  let list = try? JSONDecoder().decode([String].self, from: json) else { return [] }
            return list
        }()
        let medications: [CareCircleMedication] = {
            guard let json = entity.medicationsJSON?.data(using: .utf8),
                  let list = try? JSONDecoder().decode([CareCircleMedication].self, from: json) else { return [] }
            return list
        }()
        let favoriteParks: [String] = {
            guard let json = entity.favoriteParksJSON?.data(using: .utf8),
                  let list = try? JSONDecoder().decode([String].self, from: json) else { return [] }
            return list
        }()
        let triggers: [String] = {
            guard let json = entity.triggersJSON?.data(using: .utf8),
                  let list = try? JSONDecoder().decode([String].self, from: json) else { return [] }
            return list
        }()

        return CareCircleProfile(
            id: entity.id ?? UUID(),
            dogId: entity.dogId ?? UUID(),
            sitterName: entity.sitterName,
            sitterContact: entity.sitterContact,
            feedingSchedule: entity.feedingSchedule ?? "",
            dietaryRestrictions: entity.dietaryRestrictions ?? "",
            allergies: allergies,
            treatGuidelines: entity.treatGuidelines ?? "",
            medications: medications,
            walkingRoutine: entity.walkingRoutine ?? "",
            favoriteParks: favoriteParks,
            leashGuidelines: entity.leashGuidelines ?? "",
            groomingInstructions: entity.groomingInstructions ?? "",
            bathingInstructions: entity.bathingInstructions ?? "",
            behavioralNotes: entity.behavioralNotes ?? "",
            triggers: triggers,
            calmingTechniques: entity.calmingTechniques ?? "",
            primaryContactName: entity.primaryContactName ?? "Owner",
            primaryContactPhone: entity.primaryContactPhone ?? "",
            secondaryContactName: entity.secondaryContactName,
            secondaryContactPhone: entity.secondaryContactPhone,
            vetClinicName: entity.vetClinicName ?? "",
            vetDoctorName: entity.vetDoctorName,
            vetPhone: entity.vetPhone ?? "",
            vetAddress: entity.vetAddress ?? "",
            emergency24hHospital: entity.emergency24hHospital ?? "",
            homeAccessNotes: entity.homeAccessNotes,
            sleepingArrangements: entity.sleepingArrangements ?? "",
            specialCareNotes: entity.specialCareNotes,
            updatedAt: entity.updatedAt ?? Date()
        )
    }

    public static func update(entity: CareCircleProfileEntity, from domain: CareCircleProfile) {
        entity.id = domain.id
        entity.dogId = domain.dogId
        entity.sitterName = domain.sitterName
        entity.sitterContact = domain.sitterContact
        entity.feedingSchedule = domain.feedingSchedule
        entity.dietaryRestrictions = domain.dietaryRestrictions
        entity.allergiesJSON = try? String(data: JSONEncoder().encode(domain.allergies), encoding: .utf8)
        entity.treatGuidelines = domain.treatGuidelines
        entity.medicationsJSON = try? String(data: JSONEncoder().encode(domain.medications), encoding: .utf8)
        entity.walkingRoutine = domain.walkingRoutine
        entity.favoriteParksJSON = try? String(data: JSONEncoder().encode(domain.favoriteParks), encoding: .utf8)
        entity.leashGuidelines = domain.leashGuidelines
        entity.groomingInstructions = domain.groomingInstructions
        entity.bathingInstructions = domain.bathingInstructions
        entity.behavioralNotes = domain.behavioralNotes
        entity.triggersJSON = try? String(data: JSONEncoder().encode(domain.triggers), encoding: .utf8)
        entity.calmingTechniques = domain.calmingTechniques
        entity.primaryContactName = domain.primaryContactName
        entity.primaryContactPhone = domain.primaryContactPhone
        entity.secondaryContactName = domain.secondaryContactName
        entity.secondaryContactPhone = domain.secondaryContactPhone
        entity.vetClinicName = domain.vetClinicName
        entity.vetDoctorName = domain.vetDoctorName
        entity.vetPhone = domain.vetPhone
        entity.vetAddress = domain.vetAddress
        entity.emergency24hHospital = domain.emergency24hHospital
        entity.homeAccessNotes = domain.homeAccessNotes
        entity.sleepingArrangements = domain.sleepingArrangements
        entity.specialCareNotes = domain.specialCareNotes
        entity.updatedAt = domain.updatedAt
    }

    // MARK: - SittingSession
    public static func toDomain(entity: SittingSessionEntity) -> SittingSession {
        let status = SittingSessionStatus(rawValue: entity.status ?? "") ?? .scheduled
        return SittingSession(
            id: entity.id ?? UUID(),
            dogId: entity.dogId ?? UUID(),
            sitterName: entity.sitterName ?? "Sitter",
            sitterPhone: entity.sitterPhone,
            startDate: entity.startDate ?? Date(),
            endDate: entity.endDate ?? Date().addingTimeInterval(86400),
            status: status,
            emergencyContact: entity.emergencyContact,
            specialInstructions: entity.specialInstructions,
            isLocationSharingActive: entity.isLocationSharingActive,
            createdAt: entity.createdAt ?? Date()
        )
    }

    public static func update(entity: SittingSessionEntity, from domain: SittingSession) {
        entity.id = domain.id
        entity.dogId = domain.dogId
        entity.sitterName = domain.sitterName
        entity.sitterPhone = domain.sitterPhone
        entity.startDate = domain.startDate
        entity.endDate = domain.endDate
        entity.status = domain.status.rawValue
        entity.emergencyContact = domain.emergencyContact
        entity.specialInstructions = domain.specialInstructions
        entity.isLocationSharingActive = domain.isLocationSharingActive
        entity.createdAt = domain.createdAt
    }

    // MARK: - SittingActivityLog
    public static func toDomain(entity: SittingActivityEntity) -> SittingActivityLog {
        let type = SittingActivityType(rawValue: entity.activityType ?? "") ?? .note
        return SittingActivityLog(
            id: entity.id ?? UUID(),
            sessionId: entity.sessionId ?? UUID(),
            dogId: entity.dogId ?? UUID(),
            activityType: type,
            title: entity.title ?? "Activity",
            notes: entity.notes,
            timestamp: entity.timestamp ?? Date(),
            loggedBy: entity.loggedBy ?? "Sitter",
            locationLatitude: entity.locationLatitude != 0.0 ? entity.locationLatitude : nil,
            locationLongitude: entity.locationLongitude != 0.0 ? entity.locationLongitude : nil
        )
    }

    public static func update(entity: SittingActivityEntity, from domain: SittingActivityLog) {
        entity.id = domain.id
        entity.sessionId = domain.sessionId
        entity.dogId = domain.dogId
        entity.activityType = domain.activityType.rawValue
        entity.title = domain.title
        entity.notes = domain.notes
        entity.timestamp = domain.timestamp
        entity.loggedBy = domain.loggedBy
        entity.locationLatitude = domain.locationLatitude ?? 0.0
        entity.locationLongitude = domain.locationLongitude ?? 0.0
    }
}

