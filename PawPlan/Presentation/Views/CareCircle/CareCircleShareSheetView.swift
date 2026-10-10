//
//  CareCircleShareSheetView.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Secure Sharing.
//

import SwiftUI
import UIKit

public struct CareCircleShareSheetView: View {
    @ObservedObject var container: AppDependencyContainer
    let profile: CareCircleProfile
    let dog: Dog

    @Environment(\.dismiss) var dismiss

    @State private var config = CareCircleShareConfig()
    @State private var previewText: String = ""
    @State private var showActivityView: Bool = false
    @State private var shareItems: [Any] = []
    @State private var shareFormat: ShareFormat = .pdf

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

                        // 3. Live Document Preview
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("PACKET PREVIEW")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(PawPlanTheme.subtext)
                                Spacer()
                                Text("\(previewText.count) characters")
                                    .font(.system(size: 11))
                                    .foregroundColor(PawPlanTheme.subtext)
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

                        // Share Button
                        Button(action: prepareAndOpenShareSheet) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up.fill")
                                Text(shareFormat == .pdf ? "Share Care PDF via iOS Share Sheet" : "Share Care Summary via iOS Share Sheet")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PawPlanTheme.midnightNavy)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(PawPlanTheme.turquoiseGradient)
                            .cornerRadius(18)
                        }
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
            .sheet(isPresented: $showActivityView) {
                ActivityViewControllerRepresentable(activityItems: shareItems)
            }
        }
    }

    private func updatePreview() {
        previewText = config.generateFormattedSummary(profile: profile, dog: dog)
    }

    private func prepareAndOpenShareSheet() {
        if shareFormat == .pdf {
            let pdfData = config.generatePDF(profile: profile, dog: dog)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("PawPlan_Care_Packet_\(dog.name).pdf")
            try? pdfData.write(to: tempURL)
            shareItems = [tempURL]
        } else {
            let text = config.generateFormattedSummary(profile: profile, dog: dog)
            shareItems = [text]
        }
        showActivityView = true
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

private struct ActivityViewControllerRepresentable: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
