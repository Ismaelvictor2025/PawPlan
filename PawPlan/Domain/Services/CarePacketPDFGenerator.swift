//
//  CarePacketPDFGenerator.swift
//  PawPlan
//
//  Created for PawPlan Care Circle PDF Generation.
//

import Foundation
import UIKit
import PDFKit

public enum PDFGenerationError: LocalizedError, Equatable {
    case emptyDocumentData
    case fileWriteFailed(String)
    case renderingFailed(String)
    case fileNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .emptyDocumentData:
            return "Failed to generate care packet: Output document was empty."
        case .fileWriteFailed(let reason):
            return "Could not save care packet PDF to temporary storage: \(reason)"
        case .renderingFailed(let reason):
            return "PDF rendering engine error: \(reason)"
        case .fileNotFound(let path):
            return "Generated PDF file could not be located at \(path)."
        }
    }
}

@MainActor
public final class CarePacketPDFGenerator {
    public static let shared = CarePacketPDFGenerator()

    // Standard US Letter dimensions (points)
    private let pageWidth: CGFloat = 612.0
    private let pageHeight: CGFloat = 792.0
    private let margin: CGFloat = 36.0

    private var contentWidth: CGFloat {
        pageWidth - (margin * 2)
    }

    private var usableHeight: CGFloat {
        pageHeight - (margin * 2)
    }

    public init() {}

    // MARK: - Public API

    /// Generates raw PDF Data formatted cleanly across multiple pages if necessary.
    public func generatePDFData(
        profile: CareCircleProfile,
        dog: Dog,
        config: CareCircleShareConfig
    ) throws -> Data {
        let sections = buildSections(profile: profile, dog: dog, config: config)

        let pdfMetaData: [CFString: Any] = [
            kCGPDFContextCreator: "PawPlan iOS App",
            kCGPDFContextAuthor: profile.primaryContactName,
            kCGPDFContextTitle: "PawPlan Care Packet - \(dog.name)",
            kCGPDFContextSubject: "Dog Sitting Instructions & Care Guide"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageBounds = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds, format: format)

        // Pass 1: Calculate total page count for accurate "Page X of Y" numbering
        let totalPages = calculateTotalPages(sections: sections, dog: dog)

        // Pass 2: Render multipage PDF
        let data = renderer.pdfData { context in
            var currentPage = 1
            var currentY: CGFloat = margin

            context.beginPage()
            currentY = drawPageHeader(context: context, dog: dog, pageNumber: currentPage, isFirstPage: true)

            for section in sections {
                let sectionHeight = calculateSectionHeight(section: section)

                // Check if this section fits on the current page before footer margin
                let availableHeight = pageHeight - margin - 32 - currentY
                if sectionHeight > availableHeight && currentY > (margin + 60) {
                    // Draw footer on current page
                    drawPageFooter(pageNumber: currentPage, totalPages: totalPages)

                    // Begin next page
                    context.beginPage()
                    currentPage += 1
                    currentY = drawPageHeader(context: context, dog: dog, pageNumber: currentPage, isFirstPage: false)
                }

                // Draw section card
                drawSectionCard(section: section, startY: currentY, width: contentWidth)
                currentY += sectionHeight + 10.0
            }

            // Draw final footer
            drawPageFooter(pageNumber: currentPage, totalPages: totalPages)
        }

        guard !data.isEmpty else {
            throw PDFGenerationError.emptyDocumentData
        }

        return data
    }

    /// Generates PDF and persists it to a safe temporary file URL for the iOS Share Sheet.
    public func generateAndSavePDF(
        profile: CareCircleProfile,
        dog: Dog,
        config: CareCircleShareConfig
    ) throws -> URL {
        let pdfData = try generatePDFData(profile: profile, dog: dog, config: config)

        let tempFolder = FileManager.default.temporaryDirectory.appendingPathComponent("PawPlanCareCircle", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
        } catch {
            throw PDFGenerationError.fileWriteFailed("Could not create export folder: \(error.localizedDescription)")
        }

        // Clean up previously generated files safely
        cleanUpOldExportFiles(in: tempFolder)

        let safeDogName = dog.name
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "_")
        let baseName = safeDogName.isEmpty ? "Dog" : safeDogName
        let filename = "PawPlan_Care_Packet_\(baseName).pdf"
        let fileURL = tempFolder.appendingPathComponent(filename)

        do {
            try pdfData.write(to: fileURL, options: .atomic)
        } catch {
            throw PDFGenerationError.fileWriteFailed(error.localizedDescription)
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw PDFGenerationError.fileNotFound(fileURL.path)
        }

        return fileURL
    }

    /// Cleans up exports older than 1 hour or previous temp files without deleting the active one.
    public func cleanUpOldExportFiles(in folder: URL) {
        guard let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }
        let oneHourAgo = Date().addingTimeInterval(-3600)
        for file in files {
            if let attrs = try? file.resourceValues(forKeys: [.creationDateKey]),
               let created = attrs.creationDate,
               created < oneHourAgo {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }

    // MARK: - Section Model

    private struct PDFSection {
        let title: String
        let icon: String
        let accentColor: UIColor
        let items: [(label: String, value: String)]
        let alertMessage: String?

        init(
            title: String,
            icon: String,
            accentColor: UIColor = UIColor(red: 18/255, green: 91/255, blue: 206/255, alpha: 1.0),
            items: [(label: String, value: String)],
            alertMessage: String? = nil
        ) {
            self.title = title
            self.icon = icon
            self.accentColor = accentColor
            self.items = items
            self.alertMessage = alertMessage
        }
    }

    // MARK: - Section Builder

    private func buildSections(
        profile: CareCircleProfile,
        dog: Dog,
        config: CareCircleShareConfig
    ) -> [PDFSection] {
        var sections: [PDFSection] = []

        // 1. Dog Profile & Identity
        if config.includeDogIdentity {
            var items: [(String, String)] = [
                ("Dog Name", dog.name),
                ("Breed", dog.breed),
                ("Age", dog.ageDescription),
                ("Weight", dog.weightDescription)
            ]
            if let chip = dog.microchipNumber, !chip.isEmpty {
                items.append(("Microchip", chip))
            }
            if let suburb = dog.suburb, !suburb.isEmpty {
                items.append(("Home Suburb", suburb))
            }
            sections.append(PDFSection(
                title: "DOG PROFILE & IDENTIFICATION",
                icon: "pawprint.fill",
                accentColor: UIColor(red: 21/255, green: 217/255, blue: 210/255, alpha: 1.0),
                items: items
            ))
        }

        // 2. Feeding Schedule & Dietary Restrictions
        if config.includeFeedingAndDiet {
            var items: [(String, String)] = [
                ("Schedule", profile.feedingSchedule),
                ("Dietary Notes", profile.dietaryRestrictions)
            ]
            if !profile.treatGuidelines.isEmpty {
                items.append(("Treats", profile.treatGuidelines))
            }
            let alert: String? = profile.allergies.isEmpty ? nil : "⚠️ Known Allergies: \(profile.allergies.joined(separator: ", "))"
            sections.append(PDFSection(
                title: "FEEDING SCHEDULE & DIET",
                icon: "fork.knife",
                accentColor: UIColor(red: 21/255, green: 217/255, blue: 210/255, alpha: 1.0),
                items: items,
                alertMessage: alert
            ))
        }

        // 3. Medications & Dosages
        if config.includeMedications && !profile.medications.isEmpty {
            var items: [(String, String)] = []
            for (idx, med) in profile.medications.enumerated() {
                var desc = "\(med.dosage) — \(med.frequency)"
                if let instructions = med.administrationInstructions, !instructions.isEmpty {
                    desc += "\nInstructions: \(instructions)"
                }
                items.append(("Medication #\(idx + 1)", "\(med.name): \(desc)"))
            }
            sections.append(PDFSection(
                title: "MEDICATIONS & ADMINISTRATION",
                icon: "pills.fill",
                accentColor: UIColor(red: 0/255, green: 230/255, blue: 118/255, alpha: 1.0),
                items: items
            ))
        }

        // 4. Walking Routine & Exercise
        if config.includeWalkingRoutine {
            var items: [(String, String)] = [
                ("Routine", profile.walkingRoutine)
            ]
            if !profile.favoriteParks.isEmpty {
                items.append(("Parks & Trails", profile.favoriteParks.joined(separator: ", ")))
            }
            if !profile.leashGuidelines.isEmpty {
                items.append(("Leash Rules", profile.leashGuidelines))
            }
            sections.append(PDFSection(
                title: "WALKING & EXERCISE ROUTINE",
                icon: "figure.walk",
                accentColor: UIColor(red: 18/255, green: 91/255, blue: 206/255, alpha: 1.0),
                items: items
            ))
        }

        // 5. Grooming & Bathing
        if config.includeGroomingAndBathing {
            var items: [(String, String)] = []
            if !profile.groomingInstructions.isEmpty {
                items.append(("Grooming", profile.groomingInstructions))
            }
            if !profile.bathingInstructions.isEmpty {
                items.append(("Bathing", profile.bathingInstructions))
            }
            if !items.isEmpty {
                sections.append(PDFSection(
                    title: "GROOMING & COAT CARE",
                    icon: "scissors",
                    accentColor: UIColor(red: 157/255, green: 78/255, blue: 221/255, alpha: 1.0),
                    items: items
                ))
            }
        }

        // 6. Behaviour & Known Triggers
        if config.includeBehaviorAndTriggers {
            var items: [(String, String)] = []
            if !profile.behavioralNotes.isEmpty {
                items.append(("Notes", profile.behavioralNotes))
            }
            if !profile.triggers.isEmpty {
                items.append(("Known Triggers", profile.triggers.joined(separator: ", ")))
            }
            if !profile.calmingTechniques.isEmpty {
                items.append(("Calming Routine", profile.calmingTechniques))
            }
            if !items.isEmpty {
                sections.append(PDFSection(
                    title: "BEHAVIOUR & COMFORT GUIDELINES",
                    icon: "brain.head.profile",
                    accentColor: UIColor(red: 255/255, green: 123/255, blue: 0/255, alpha: 1.0),
                    items: items
                ))
            }
        }

        // 7. Emergency Contacts
        if config.includeEmergencyContacts {
            var items: [(String, String)] = [
                ("Primary Contact", "\(profile.primaryContactName) — \(profile.primaryContactPhone)")
            ]
            if let secName = profile.secondaryContactName, !secName.isEmpty,
               let secPhone = profile.secondaryContactPhone, !secPhone.isEmpty {
                items.append(("Secondary Contact", "\(secName) — \(secPhone)"))
            }
            sections.append(PDFSection(
                title: "EMERGENCY CONTACTS",
                icon: "phone.fill",
                accentColor: UIColor(red: 225/255, green: 29/255, blue: 72/255, alpha: 1.0),
                items: items
            ))
        }

        // 8. Veterinarian & 24/7 Animal Hospital
        if config.includeVeterinarian {
            var items: [(String, String)] = [
                ("Clinic", profile.vetClinicName),
                ("Phone", profile.vetPhone),
                ("Address", profile.vetAddress)
            ]
            if let doc = profile.vetDoctorName, !doc.isEmpty {
                items.insert(("Attending Vet", doc), at: 1)
            }
            if !profile.emergency24hHospital.isEmpty {
                items.append(("24/7 Emergency Hospital", profile.emergency24hHospital))
            }
            sections.append(PDFSection(
                title: "VETERINARY MEDICAL CONTACT",
                icon: "cross.case.fill",
                accentColor: UIColor(red: 225/255, green: 29/255, blue: 72/255, alpha: 1.0),
                items: items
            ))
        }

        // 9. Home Access Notes (ONLY IF EXPLICITLY INCLUDED)
        if config.includeHomeAccessNotes, let home = profile.homeAccessNotes, !home.isEmpty {
            let items: [(String, String)] = [
                ("Access & Security", home)
            ]
            sections.append(PDFSection(
                title: "HOME ACCESS & SECURITY (CONFIDENTIAL)",
                icon: "key.fill",
                accentColor: UIColor(red: 217/255, green: 119/255, blue: 6/255, alpha: 1.0),
                items: items,
                alertMessage: "⚠️ Highly sensitive home access details. Treat securely and do not re-share."
            ))
        }

        // 10. Special Care & Sleeping Arrangements
        if config.includeSpecialCareNotes {
            var items: [(String, String)] = []
            if !profile.sleepingArrangements.isEmpty {
                items.append(("Sleeping Routine", profile.sleepingArrangements))
            }
            if let special = profile.specialCareNotes, !special.isEmpty {
                items.append(("Special Instructions", special))
            }
            if !items.isEmpty {
                sections.append(PDFSection(
                    title: "SLEEPING & SPECIAL CARE NOTES",
                    icon: "bed.double.fill",
                    accentColor: UIColor(red: 18/255, green: 91/255, blue: 206/255, alpha: 1.0),
                    items: items
                ))
            }
        }

        return sections
    }

    // MARK: - Layout & Pagination Calculations

    private func calculateTotalPages(sections: [PDFSection], dog: Dog) -> Int {
        var pages = 1
        var currentY: CGFloat = margin + 85.0 // Page 1 header height

        for section in sections {
            let sectionHeight = calculateSectionHeight(section: section)
            let availableHeight = pageHeight - margin - 32 - currentY
            if sectionHeight > availableHeight && currentY > (margin + 60) {
                pages += 1
                currentY = margin + 35.0 // Subsequent page header height
            }
            currentY += sectionHeight + 10.0
        }
        return max(1, pages)
    }

    private func calculateSectionHeight(section: PDFSection) -> CGFloat {
        var height: CGFloat = 28.0 // Header bar
        let textWidth = contentWidth - 24.0

        for item in section.items {
            let labelStr = "\(item.label): "
            let valueStr = item.value
            let fullStr = labelStr + valueStr

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9.5)
            ]
            let rect = (fullStr as NSString).boundingRect(
                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attrs,
                context: nil
            )
            height += max(16.0, ceil(rect.height) + 4.0)
        }

        if let alert = section.alertMessage {
            let alertAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9.0, weight: .semibold)
            ]
            let alertRect = (alert as NSString).boundingRect(
                with: CGSize(width: textWidth - 16.0, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: alertAttrs,
                context: nil
            )
            height += ceil(alertRect.height) + 16.0
        }

        height += 12.0 // Bottom padding
        return height
    }

    // MARK: - Drawing Routines

    private func drawPageHeader(
        context: UIGraphicsPDFRendererContext,
        dog: Dog,
        pageNumber: Int,
        isFirstPage: Bool
    ) -> CGFloat {
        if isFirstPage {
            // First Page: Premium Hero Header Card
            let bannerRect = CGRect(x: margin, y: margin, width: contentWidth, height: 72)
            let bannerPath = UIBezierPath(roundedRect: bannerRect, cornerRadius: 10)
            UIColor(red: 8/255, green: 15/255, blue: 32/255, alpha: 1.0).setFill()
            bannerPath.fill()

            // Turquoise top accent line
            let accentLine = UIBezierPath(
                roundedRect: CGRect(x: margin, y: margin, width: contentWidth, height: 4),
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: 10, height: 10)
            )
            UIColor(red: 21/255, green: 217/255, blue: 210/255, alpha: 1.0).setFill()
            accentLine.fill()

            // Header Title
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .heavy),
                .foregroundColor: UIColor(red: 21/255, green: 217/255, blue: 210/255, alpha: 1.0)
            ]
            let title = "PAWPLAN CARE CIRCLE — \(dog.name.uppercased())"
            (title as NSString).draw(at: CGPoint(x: margin + 14, y: margin + 14), withAttributes: titleAttrs)

            // Subtitle
            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10.5, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let subtitle = "\(dog.breed) • \(dog.ageDescription) • \(dog.weightDescription)"
            (subtitle as NSString).draw(at: CGPoint(x: margin + 14, y: margin + 36), withAttributes: subAttrs)

            // Right Timestamp
            let dateAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8.5, weight: .medium),
                .foregroundColor: UIColor(red: 133/255, green: 244/255, blue: 255/255, alpha: 0.9)
            ]
            let dateStr = "Care Packet • \(Date().formatted(date: .abbreviated, time: .omitted))"
            let dateSize = (dateStr as NSString).size(withAttributes: dateAttrs)
            (dateStr as NSString).draw(at: CGPoint(x: margin + contentWidth - dateSize.width - 14, y: margin + 18), withAttributes: dateAttrs)

            return margin + 72 + 12
        } else {
            // Subsequent Page: Compact Navigation Bar
            let bannerRect = CGRect(x: margin, y: margin, width: contentWidth, height: 26)
            let bannerPath = UIBezierPath(roundedRect: bannerRect, cornerRadius: 6)
            UIColor(red: 8/255, green: 15/255, blue: 32/255, alpha: 1.0).setFill()
            bannerPath.fill()

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                .foregroundColor: UIColor(red: 21/255, green: 217/255, blue: 210/255, alpha: 1.0)
            ]
            let title = "PAWPLAN CARE PACKET — \(dog.name.uppercased()) (Continued)"
            (title as NSString).draw(at: CGPoint(x: margin + 10, y: margin + 7), withAttributes: titleAttrs)

            return margin + 26 + 10
        }
    }

    private func drawSectionCard(section: PDFSection, startY: CGFloat, width: CGFloat) {
        let sectionHeight = calculateSectionHeight(section: section)
        let cardRect = CGRect(x: margin, y: startY, width: width, height: sectionHeight)

        // Card Background
        let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 8)
        UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0).setFill()
        cardPath.fill()

        // Card Border
        UIColor(red: 226/255, green: 232/255, blue: 240/255, alpha: 1.0).setStroke()
        cardPath.lineWidth = 0.8
        cardPath.stroke()

        // Accent indicator bar on left
        let indicatorRect = CGRect(x: margin, y: startY, width: 4, height: sectionHeight)
        let indicatorPath = UIBezierPath(
            roundedRect: indicatorRect,
            byRoundingCorners: [.topLeft, .bottomLeft],
            cornerRadii: CGSize(width: 8, height: 8)
        )
        section.accentColor.setFill()
        indicatorPath.fill()

        // Section Title
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10.5, weight: .bold),
            .foregroundColor: UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)
        ]
        (section.title as NSString).draw(at: CGPoint(x: margin + 12, y: startY + 8), withAttributes: titleAttrs)

        // Divider under title
        let lineY = startY + 24
        let divider = UIBezierPath()
        divider.move(to: CGPoint(x: margin + 12, y: lineY))
        divider.addLine(to: CGPoint(x: margin + width - 12, y: lineY))
        UIColor(red: 226/255, green: 232/255, blue: 240/255, alpha: 0.8).setStroke()
        divider.lineWidth = 0.5
        divider.stroke()

        // Item Rows
        var itemY = lineY + 6
        let textWidth = width - 24

        for item in section.items {
            let fullText = NSMutableAttributedString()

            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9.5, weight: .bold),
                .foregroundColor: UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1.0)
            ]
            fullText.append(NSAttributedString(string: "\(item.label): ", attributes: labelAttrs))

            let valAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9.5, weight: .regular),
                .foregroundColor: UIColor(red: 51/255, green: 65/255, blue: 85/255, alpha: 1.0)
            ]
            fullText.append(NSAttributedString(string: item.value, attributes: valAttrs))

            let bounding = fullText.boundingRect(
                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            fullText.draw(in: CGRect(x: margin + 12, y: itemY, width: textWidth, height: ceil(bounding.height)))
            itemY += max(15.0, ceil(bounding.height) + 4.0)
        }

        // Alert Box (if present)
        if let alert = section.alertMessage {
            let alertBoxRect = CGRect(x: margin + 12, y: itemY + 2, width: textWidth, height: 22)
            let alertBox = UIBezierPath(roundedRect: alertBoxRect, cornerRadius: 5)
            UIColor(red: 254/255, green: 242/255, blue: 242/255, alpha: 1.0).setFill()
            alertBox.fill()
            UIColor(red: 254/255, green: 202/255, blue: 202/255, alpha: 1.0).setStroke()
            alertBox.lineWidth = 0.6
            alertBox.stroke()

            let alertAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9.0, weight: .semibold),
                .foregroundColor: UIColor(red: 185/255, green: 28/255, blue: 28/255, alpha: 1.0)
            ]
            (alert as NSString).draw(at: CGPoint(x: margin + 18, y: itemY + 6), withAttributes: alertAttrs)
        }
    }

    private func drawPageFooter(pageNumber: Int, totalPages: Int) {
        let footerY = pageHeight - margin - 20

        // Divider
        let divider = UIBezierPath()
        divider.move(to: CGPoint(x: margin, y: footerY - 4))
        divider.addLine(to: CGPoint(x: margin + contentWidth, y: footerY - 4))
        UIColor(red: 203/255, green: 213/255, blue: 225/255, alpha: 0.8).setStroke()
        divider.lineWidth = 0.5
        divider.stroke()

        // Left Branding
        let brandAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8.0, weight: .regular),
            .foregroundColor: UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1.0)
        ]
        let brandText = "🐾 PawPlan Care Circle • Private & Confidential • Stored Locally Offline"
        (brandText as NSString).draw(at: CGPoint(x: margin, y: footerY), withAttributes: brandAttrs)

        // Right Page Number
        let pageAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8.0, weight: .semibold),
            .foregroundColor: UIColor(red: 71/255, green: 85/255, blue: 105/255, alpha: 1.0)
        ]
        let pageText = "Page \(pageNumber) of \(totalPages)"
        let pageSize = (pageText as NSString).size(withAttributes: pageAttrs)
        (pageText as NSString).draw(at: CGPoint(x: margin + contentWidth - pageSize.width, y: footerY), withAttributes: pageAttrs)
    }
}
