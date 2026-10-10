//
//  CareCircleShareConfig.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Secure Sharing.
//

import Foundation
import UIKit

public struct CareCircleShareConfig: Equatable, Sendable {
    public var includeDogIdentity: Bool = true
    public var includeFeedingAndDiet: Bool = true
    public var includeMedications: Bool = true
    public var includeWalkingRoutine: Bool = true
    public var includeGroomingAndBathing: Bool = true
    public var includeBehaviorAndTriggers: Bool = true
    public var includeEmergencyContacts: Bool = true
    public var includeVeterinarian: Bool = true
    public var includeHomeAccessNotes: Bool = false // Default to false for privacy
    public var includeSpecialCareNotes: Bool = true

    public init(
        includeDogIdentity: Bool = true,
        includeFeedingAndDiet: Bool = true,
        includeMedications: Bool = true,
        includeWalkingRoutine: Bool = true,
        includeGroomingAndBathing: Bool = true,
        includeBehaviorAndTriggers: Bool = true,
        includeEmergencyContacts: Bool = true,
        includeVeterinarian: Bool = true,
        includeHomeAccessNotes: Bool = false,
        includeSpecialCareNotes: Bool = true
    ) {
        self.includeDogIdentity = includeDogIdentity
        self.includeFeedingAndDiet = includeFeedingAndDiet
        self.includeMedications = includeMedications
        self.includeWalkingRoutine = includeWalkingRoutine
        self.includeGroomingAndBathing = includeGroomingAndBathing
        self.includeBehaviorAndTriggers = includeBehaviorAndTriggers
        self.includeEmergencyContacts = includeEmergencyContacts
        self.includeVeterinarian = includeVeterinarian
        self.includeHomeAccessNotes = includeHomeAccessNotes
        self.includeSpecialCareNotes = includeSpecialCareNotes
    }

    /// Generates a readable plain-text/markdown care packet summary.
    public func generateFormattedSummary(profile: CareCircleProfile, dog: Dog) -> String {
        var sections: [String] = []

        sections.append("🐾 PAWPLAN CARE CIRCLE — SITTING INSTRUCTIONS")
        sections.append("Generated on \(Date().formatted(date: .long, time: .shortened))")
        sections.append("--------------------------------------------------")

        if includeDogIdentity {
            var dogInfo = "DOG PROFILE:\n"
            dogInfo += "• Name: \(dog.name)\n"
            dogInfo += "• Breed: \(dog.breed)\n"
            dogInfo += "• Age: \(dog.ageDescription)\n"
            dogInfo += "• Weight: \(dog.weightDescription)\n"
            dogInfo += "• Microchip: \(dog.microchipNumber ?? "On file with owner")\n"
            if let suburb = dog.suburb {
                dogInfo += "• Home Suburb: \(suburb)\n"
            }
            sections.append(dogInfo)
        }

        if includeFeedingAndDiet {
            var diet = "FEEDING & NUTRITION:\n"
            diet += "• Schedule: \(profile.feedingSchedule)\n"
            diet += "• Restrictions: \(profile.dietaryRestrictions)\n"
            if !profile.allergies.isEmpty {
                diet += "• Allergies: \(profile.allergies.joined(separator: ", "))\n"
            }
            diet += "• Treats: \(profile.treatGuidelines)\n"
            sections.append(diet)
        }

        if includeMedications {
            var meds = "MEDICATIONS & HEALTH:\n"
            if profile.medications.isEmpty {
                meds += "• No active daily medications required.\n"
            } else {
                for (index, m) in profile.medications.enumerated() {
                    meds += "• [\(index + 1)] \(m.name) — \(m.dosage) (\(m.frequency))\n"
                    if let instr = m.administrationInstructions {
                        meds += "    Notes: \(instr)\n"
                    }
                }
            }
            sections.append(meds)
        }

        if includeWalkingRoutine {
            var walk = "WALKING & EXERCISE:\n"
            walk += "• Routine: \(profile.walkingRoutine)\n"
            if !profile.favoriteParks.isEmpty {
                walk += "• Recommended Spots: \(profile.favoriteParks.joined(separator: ", "))\n"
            }
            walk += "• Leash & Equipment: \(profile.leashGuidelines)\n"
            sections.append(walk)
        }

        if includeGroomingAndBathing {
            var groom = "GROOMING & COAT CARE:\n"
            groom += "• Daily Grooming: \(profile.groomingInstructions)\n"
            groom += "• Bathing / Post-Walk: \(profile.bathingInstructions)\n"
            sections.append(groom)
        }

        if includeBehaviorAndTriggers {
            var behavior = "BEHAVIOUR & TEMPERAMENT:\n"
            behavior += "• Personality: \(profile.behavioralNotes)\n"
            if !profile.triggers.isEmpty {
                behavior += "• Known Triggers: \(profile.triggers.joined(separator: ", "))\n"
            }
            behavior += "• Calming Routine: \(profile.calmingTechniques)\n"
            sections.append(behavior)
        }

        if includeEmergencyContacts {
            var contact = "EMERGENCY CONTACTS:\n"
            contact += "• Primary: \(profile.primaryContactName) (\(profile.primaryContactPhone))\n"
            if let secName = profile.secondaryContactName, let secPhone = profile.secondaryContactPhone {
                contact += "• Secondary: \(secName) (\(secPhone))\n"
            }
            sections.append(contact)
        }

        if includeVeterinarian {
            var vet = "VETERINARY CLINIC:\n"
            vet += "• Clinic: \(profile.vetClinicName)\n"
            if let doc = profile.vetDoctorName {
                vet += "• Attending Vet: \(doc)\n"
            }
            vet += "• Phone: \(profile.vetPhone)\n"
            vet += "• Address: \(profile.vetAddress)\n"
            vet += "• 24/7 Emergency Hospital: \(profile.emergency24hHospital)\n"
            sections.append(vet)
        }

        if includeHomeAccessNotes, let home = profile.homeAccessNotes, !home.isEmpty {
            var homeNotes = "HOME ACCESS & SLEEPING:\n"
            homeNotes += "• Access: \(home)\n"
            homeNotes += "• Sleeping: \(profile.sleepingArrangements)\n"
            sections.append(homeNotes)
        } else if includeSpecialCareNotes {
            var sleepNotes = "SLEEPING ARRANGEMENTS:\n"
            sleepNotes += "• Sleeping: \(profile.sleepingArrangements)\n"
            sections.append(sleepNotes)
        }

        if includeSpecialCareNotes, let special = profile.specialCareNotes, !special.isEmpty {
            sections.append("SPECIAL INSTRUCTIONS:\n• \(special)\n")
        }

        sections.append("--------------------------------------------------")
        sections.append("PRIVACY NOTICE: This document was prepared via PawPlan and shared securely by the pet owner. Stored offline.")

        return sections.joined(separator: "\n")
    }

    /// Generates a PDF data representation formatted for printing or sharing.
    @MainActor
    public func generatePDF(profile: CareCircleProfile, dog: Dog) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "PawPlan iOS App",
            kCGPDFContextAuthor: profile.primaryContactName,
            kCGPDFContextTitle: "PawPlan Care Packet - \(dog.name)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 40
        let contentWidth = pageWidth - (margin * 2)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        return renderer.pdfData { context in
            context.beginPage()

            var currentY: CGFloat = margin

            // Header Banner
            let headerRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 48)
            let headerPath = UIBezierPath(roundedRect: headerRect, cornerRadius: 8)
            UIColor(red: 8/255, green: 15/255, blue: 32/255, alpha: 1.0).setFill()
            headerPath.fill()

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor(red: 21/255, green: 217/255, blue: 210/255, alpha: 1.0)
            ]
            let titleString = "PAWPLAN CARE CIRCLE — \(dog.name.uppercased())"
            titleString.draw(at: CGPoint(x: margin + 14, y: currentY + 14), withAttributes: titleAttributes)

            currentY += 60

            let summaryText = generateFormattedSummary(profile: profile, dog: dog)
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.black
            ]

            let textRect = CGRect(x: margin, y: currentY, width: contentWidth, height: pageHeight - currentY - margin)
            summaryText.draw(in: textRect, withAttributes: bodyAttributes)
        }
    }
}
