//
//  CreateSittingSessionModal.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Dog Sitting Mode.
//

import SwiftUI

public struct CreateSittingSessionModal: View {
    @ObservedObject var container: AppDependencyContainer
    let dog: Dog
    @Binding var isPresented: Bool
    let onCreated: () -> Void

    @State private var sitterName: String = ""
    @State private var sitterPhone: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(86400)
    @State private var emergencyContact: String = ""
    @State private var specialInstructions: String = ""
    @State private var startImmediately: Bool = true
    @State private var errorMessage: String?

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        // Sitter Details Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SITTER DETAILS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(PawPlanTheme.electricTurquoise)

                            TextField("Sitter Name * (e.g. Sarah Jenkins)", text: $sitterName)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(PawPlanTheme.midnightNavy.opacity(0.6))
                                .cornerRadius(10)

                            TextField("Sitter Contact Phone (optional)", text: $sitterPhone)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .keyboardType(.phonePad)
                                .padding(12)
                                .background(PawPlanTheme.midnightNavy.opacity(0.6))
                                .cornerRadius(10)
                        }
                        .padding(16)
                        .background(PawPlanTheme.cardSurface)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                        )

                        // Duration & Dates
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SESSION DURATION")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(PawPlanTheme.electricBlue)

                            DatePicker("Start Time", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .foregroundColor(.white)

                            DatePicker("End Time", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .foregroundColor(.white)

                            Toggle("Start Sitting Session Immediately", isOn: $startImmediately)
                                .tint(PawPlanTheme.electricTurquoise)
                                .foregroundColor(.white)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .padding(16)
                        .background(PawPlanTheme.cardSurface)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                        )

                        // Emergency & Instructions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("INSTRUCTIONS & EMERGENCY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(PawPlanTheme.lightCyan)

                            TextField("Emergency Contact Phone *", text: $emergencyContact)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .keyboardType(.phonePad)
                                .padding(12)
                                .background(PawPlanTheme.midnightNavy.opacity(0.6))
                                .cornerRadius(10)

                            TextField("Special Session Instructions (optional)", text: $specialInstructions, axis: .vertical)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .lineLimit(3...5)
                                .padding(12)
                                .background(PawPlanTheme.midnightNavy.opacity(0.6))
                                .cornerRadius(10)
                        }
                        .padding(16)
                        .background(PawPlanTheme.cardSurface)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                        )

                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundColor(PawPlanTheme.vetHealth)
                        }

                        // Create Button
                        Button(action: createSession) {
                            Text(startImmediately ? "Launch Live Sitting Mode" : "Schedule Sitting Session")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(PawPlanTheme.midnightNavy)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(PawPlanTheme.turquoiseGradient)
                                .cornerRadius(18)
                        }
                        .padding(.top, 10)
                        .disabled(sitterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Sitting Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
            .onAppear {
                if let profile = try? container.manageCareCircleUseCase.executeGetProfile(for: dog.id) {
                    self.emergencyContact = "\(profile.primaryContactName) • \(profile.primaryContactPhone)"
                }
            }
        }
    }

    private func createSession() {
        let trimmedSitter = sitterName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSitter.isEmpty else {
            errorMessage = "Sitter name is required."
            return
        }

        let session = SittingSession(
            dogId: dog.id,
            sitterName: trimmedSitter,
            sitterPhone: sitterPhone.isEmpty ? nil : sitterPhone,
            startDate: startDate,
            endDate: endDate,
            status: startImmediately ? .active : .scheduled,
            emergencyContact: emergencyContact.isEmpty ? nil : emergencyContact,
            specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions,
            isLocationSharingActive: false
        )

        do {
            try container.manageSittingSessionUseCase.executeCreateSession(session)
            onCreated()
            isPresented = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
