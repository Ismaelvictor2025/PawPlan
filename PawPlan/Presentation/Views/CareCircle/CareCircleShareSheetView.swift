//
//  CareCircleShareSheetView.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Secure Sharing.
//

import SwiftUI
import UIKit
import PDFKit

public struct CareCircleShareSheetView: View {
    @ObservedObject var container: AppDependencyContainer
    let profile: CareCircleProfile
    let dog: Dog

    @Environment(\.dismiss) var dismiss

    @State private var config = CareCircleShareConfig()
    @State private var previewText: String = ""
    @State private var shareFormat: ShareFormat = .pdf
    @State private var isExporting: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false
    @State private var previewPDFData: Data? = nil
    @State private var showPDFPreviewSheet: Bool = false

    public enum ShareFormat: String, CaseIterable, Identifiable {
        case pdf = "Formatted PDF Packet"
        case text = "Plain Text / Notes"

        public var id: String { rawValue }
    }

    public init(container: AppDependencyContainer, profile: CareCircleProfile, dog: Dog) {
        self.container = container
        self.profile = profile
        self.dog = dog
    }

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header Guidance Card
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(PawPlanTheme.electricTurquoise)
                                Text("Owner-Controlled Disclosure")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text("Select which sections to include in the care packet before generating the shareable document.")
                                .font(.system(size: 12))
                                .foregroundColor(PawPlanTheme.subtext)
                        }
                        .padding(16)
                        .background(PawPlanTheme.cardSurface)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        // 1. Selective Disclosure Toggles
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SELECT INFORMATION TO INCLUDE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(PawPlanTheme.subtext)

                            VStack(spacing: 8) {
                                DisclosureToggleRow(title: "Dog Profile & Identification", icon: "pawprint.fill", isOn: $config.includeDogIdentity)
                                DisclosureToggleRow(title: "Feeding Schedule & Allergies", icon: "fork.knife", isOn: $config.includeFeedingAndDiet)
                                DisclosureToggleRow(title: "Medication & Dosages", icon: "pills.fill", isOn: $config.includeMedications)
                                DisclosureToggleRow(title: "Walking Routine & Favorite Parks", icon: "figure.walk", isOn: $config.includeWalkingRoutine)
                                DisclosureToggleRow(title: "Grooming & Bathing", icon: "scissors", isOn: $config.includeGroomingAndBathing)
                                DisclosureToggleRow(title: "Behaviour & Known Triggers", icon: "brain.head.profile", isOn: $config.includeBehaviorAndTriggers)
                                DisclosureToggleRow(title: "Emergency Contacts", icon: "phone.fill", isOn: $config.includeEmergencyContacts)
                                DisclosureToggleRow(title: "Veterinarian & 24/7 Hospital", icon: "cross.case.fill", isOn: $config.includeVeterinarian)
                                DisclosureToggleRow(
                                    title: "Home Access Notes (Sensitive)",
                                    icon: "key.fill",
                                    isOn: $config.includeHomeAccessNotes,
                                    isWarning: true
                                )
                                DisclosureToggleRow(title: "Special Care Instructions", icon: "star.fill", isOn: $config.includeSpecialCareNotes)
                            }
                        }
                        .padding(16)
                        .background(PawPlanTheme.cardSurface)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        // 2. Export Format Picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("EXPORT FORMAT")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(PawPlanTheme.subtext)

                            Picker("Format", selection: $shareFormat) {
                                ForEach(ShareFormat.allCases) { format in
                                    Text(format.rawValue).tag(format)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(16)
                        .background(PawPlanTheme.cardSurface)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        // 3. Live Document Preview & Quick PDF Viewer Action
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(shareFormat == .pdf ? "PDF CONTENT PREVIEW" : "PACKET TEXT PREVIEW")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(PawPlanTheme.subtext)
                                Spacer()

                                if shareFormat == .pdf {
                                    Button(action: openPDFViewerPreview) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "doc.text.magnifyingglass")
                                            Text("Inspect PDF")
                                        }
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(PawPlanTheme.electricTurquoise)
                                    }
                                } else {
                                    Text("\(previewText.count) chars")
                                        .font(.system(size: 11))
                                        .foregroundColor(PawPlanTheme.subtext)
                                }
                            }

                            ScrollView {
                                Text(previewText)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                            }
                            .frame(height: 180)
                            .background(PawPlanTheme.midnightNavy.opacity(0.7))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(PawPlanTheme.cardBorder, lineWidth: 0.8)
                            )
                        }
                        .padding(16)
                        .background(PawPlanTheme.cardSurface)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        // 4. Honest Offline Security Disclosure
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(PawPlanTheme.amber)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Offline Sharing & Revocation Notice")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(PawPlanTheme.amber)
                                Text("Exported care PDFs or text files are stored directly on the recipient's device. Once shared, offline documents cannot be remotely revoked. If you need revocable access, only share with verified and trusted caregivers.")
                                    .font(.system(size: 11))
                                    .foregroundColor(PawPlanTheme.subtext)
                            }
                        }
                        .padding(14)
                        .background(PawPlanTheme.amber.opacity(0.1))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(PawPlanTheme.amber.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        // 5. Primary Share Button
                        Button(action: prepareAndOpenShareSheet) {
                            HStack(spacing: 8) {
                                if isExporting {
                                    ProgressView()
                                        .tint(PawPlanTheme.midnightNavy)
                                } else {
                                    Image(systemName: "square.and.arrow.up.fill")
                                    Text(shareFormat == .pdf ? "Share Care PDF via iOS Share Sheet" : "Share Care Summary via iOS Share Sheet")
                                }
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PawPlanTheme.midnightNavy)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(PawPlanTheme.turquoiseGradient)
                            .cornerRadius(18)
                        }
                        .disabled(isExporting)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 14)
                }
            }
            .navigationTitle("Share Care Packet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
            .onAppear {
                updatePreview()
            }
            .onChange(of: config) { _ in
                updatePreview()
            }
            .alert("Care Packet Export", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An unexpected error occurred while preparing the care packet.")
            }
            .sheet(isPresented: $showPDFPreviewSheet) {
                if let data = previewPDFData {
                    PDFPreviewModal(data: data, dogName: dog.name)
                }
            }
        }
    }

    private func updatePreview() {
        previewText = config.generateFormattedSummary(profile: profile, dog: dog)
    }

    private func openPDFViewerPreview() {
        do {
            let data = try CarePacketPDFGenerator.shared.generatePDFData(profile: profile, dog: dog, config: config)
            previewPDFData = data
            showPDFPreviewSheet = true
        } catch {
            errorMessage = "Failed to render PDF preview: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    private func prepareAndOpenShareSheet() {
        isExporting = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if shareFormat == .pdf {
                do {
                    let fileURL = try CarePacketPDFGenerator.shared.generateAndSavePDF(profile: profile, dog: dog, config: config)
                    ShareSheetPresenter.present(items: [fileURL]) { _, _ in
                        isExporting = false
                    }
                } catch {
                    isExporting = false
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            } else {
                let text = config.generateFormattedSummary(profile: profile, dog: dog)
                let tempFolder = FileManager.default.temporaryDirectory.appendingPathComponent("PawPlanCareCircle", isDirectory: true)
                try? FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
                let safeDogName = dog.name.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }.joined(separator: "_")
                let textFileURL = tempFolder.appendingPathComponent("PawPlan_Care_Summary_\(safeDogName.isEmpty ? "Dog" : safeDogName).txt")
                try? text.write(to: textFileURL, atomically: true, encoding: .utf8)

                let items: [Any] = [text, textFileURL]
                ShareSheetPresenter.present(items: items) { _, _ in
                    isExporting = false
                }
            }
        }
    }
}

// MARK: - Subcomponents

private struct DisclosureToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    var isWarning: Bool = false

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isWarning ? PawPlanTheme.amber : PawPlanTheme.electricTurquoise)
                    .frame(width: 22)

                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isWarning && isOn ? PawPlanTheme.amber : .white)
            }
        }
        .tint(PawPlanTheme.electricTurquoise)
    }
}

// MARK: - Reliable Native Share Sheet Presenter

@MainActor
public enum ShareSheetPresenter {
    public static func present(
        items: [Any],
        onComplete: ((UIActivity.ActivityType?, Bool) -> Void)? = nil
    ) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
              var topController = keyWindow.rootViewController else {
            return
        }

        // Traverse down the presented controller stack to find active front-most modal
        while let presented = topController.presentedViewController {
            topController = presented
        }

        let presenter = topController

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { activityType, completed, _, _ in
            onComplete?(activityType, completed)
        }

        // iPad Popover anchor safety
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        presenter.present(activityVC, animated: true)
    }
}

// MARK: - PDF Preview Modal

private struct PDFPreviewModal: View {
    let data: Data
    let dogName: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            PDFKitRepresentable(data: data)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("\(dogName) Care Packet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                            .foregroundColor(PawPlanTheme.electricTurquoise)
                    }
                }
        }
    }
}

private struct PDFKitRepresentable: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil {
            uiView.document = PDFDocument(data: data)
        }
    }
}
