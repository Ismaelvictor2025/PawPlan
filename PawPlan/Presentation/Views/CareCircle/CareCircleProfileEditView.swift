//
//  CareCircleProfileEditView.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Feature Expansion.
//

import SwiftUI

public struct CareCircleProfileEditView: View {
    @ObservedObject var container: AppDependencyContainer
    let dog: Dog

    @Environment(\.dismiss) var dismiss

    @State private var sitterName: String = ""
    @State private var sitterContact: String = ""
    @State private var feedingSchedule: String = ""
    @State private var dietaryRestrictions: String = ""
    @State private var allergiesText: String = ""
    @State private var treatGuidelines: String = ""
    @State private var walkingRoutine: String = ""
    @State private var favoriteParksText: String = ""
    @State private var leashGuidelines: String = ""
    @State private var groomingInstructions: String = ""
    @State private var bathingInstructions: String = ""
    @State private var behavioralNotes: String = ""
    @State private var triggersText: String = ""
    @State private var calmingTechniques: String = ""
    @State private var primaryContactName: String = ""
    @State private var primaryContactPhone: String = ""
    @State private var secondaryContactName: String = ""
    @State private var secondaryContactPhone: String = ""
    @State private var vetClinicName: String = ""
    @State private var vetDoctorName: String = ""
    @State private var vetPhone: String = ""
    @State private var vetAddress: String = ""
    @State private var emergency24hHospital: String = ""
    @State private var homeAccessNotes: String = ""
    @State private var sleepingArrangements: String = ""
    @State private var specialCareNotes: String = ""

    // Medications list
    @State private var medications: [CareCircleMedication] = []
    @State private var showAddMedicationSheet: Bool = false
    @State private var newMedName: String = ""
    @State private var newMedDosage: String = ""
    @State private var newMedFrequency: String = ""
    @State private var newMedInstructions: String = ""

    @State private var alertMessage: String?
    @State private var showAlert: Bool = false

    public init(container: AppDependencyContainer, dog: Dog) {
        self.container = container
        self.dog = dog
    }

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Top Info Card
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(PawPlanTheme.electricTurquoise)
                        Text("Ensure all feeding, medical, and emergency details are up to date before handing over care to your sitter.")
                            .font(.system(size: 13))
                            .foregroundColor(PawPlanTheme.subtext)
                        Spacer()
                    }
                    .padding(14)
                    .background(PawPlanTheme.cardSurface)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // 1. Feeding & Nutrition
                    EditSectionCard(title: "FEEDING & NUTRITION", icon: "fork.knife", color: PawPlanTheme.feeding) {
                        FormField(label: "Feeding Schedule & Portions", text: $feedingSchedule)
                        FormField(label: "Dietary Restrictions", text: $dietaryRestrictions)
                        FormField(label: "Allergies (comma-separated)", text: $allergiesText)
                        FormField(label: "Treat Guidelines & Limits", text: $treatGuidelines)
                    }
                    .padding(.horizontal, 20)

                    // 2. Medications
                    EditSectionCard(title: "MEDICATIONS & DOSAGES", icon: "pills.fill", color: PawPlanTheme.positiveGreen) {
                        if medications.isEmpty {
                            Text("No medications configured. Tap '+ Add Medication' if \(dog.name) requires daily or preventative medication.")
                                .font(.system(size: 12))
                                .foregroundColor(PawPlanTheme.subtext)
                        } else {
                            ForEach(medications) { med in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(med.name)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(PawPlanTheme.textPrimary)
                                        Text("\(med.dosage) • \(med.frequency)")
                                            .font(.system(size: 12))
                                            .foregroundColor(PawPlanTheme.subtext)
                                        if let instr = med.administrationInstructions, !instr.isEmpty {
                                            Text(instr)
                                                .font(.system(size: 11))
                                                .foregroundColor(PawPlanTheme.lightCyan)
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        medications.removeAll { $0.id == med.id }
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 14))
                                            .foregroundColor(PawPlanTheme.vetHealth)
                                    }
                                }
                                .padding(10)
                                .background(PawPlanTheme.midnightNavy.opacity(0.5))
                                .cornerRadius(10)
                            }
                        }

                        Button(action: { showAddMedicationSheet = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Medication")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(PawPlanTheme.electricTurquoise)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)

                    // 3. Walking & Exercise
                    EditSectionCard(title: "WALKING & EXERCISE", icon: "figure.walk", color: PawPlanTheme.walk) {
                        FormField(label: "Daily Walking Routine", text: $walkingRoutine)
                        FormField(label: "Favorite Parks (comma-separated)", text: $favoriteParksText)
                        FormField(label: "Leash & Harness Instructions", text: $leashGuidelines)
                    }
                    .padding(.horizontal, 20)

                    // 4. Grooming & Coat Care
                    EditSectionCard(title: "GROOMING & BATHING", icon: "scissors", color: PawPlanTheme.grooming) {
                        FormField(label: "Daily Grooming & Paws Wipe", text: $groomingInstructions)
                        FormField(label: "Bathing Guidelines", text: $bathingInstructions)
                    }
                    .padding(.horizontal, 20)

                    // 5. Behavior & Triggers
                    EditSectionCard(title: "BEHAVIOUR & TEMPERAMENT", icon: "brain.head.profile", color: PawPlanTheme.training) {
                        FormField(label: "General Personality Notes", text: $behavioralNotes)
                        FormField(label: "Known Triggers (comma-separated)", text: $triggersText)
                        FormField(label: "Calming Techniques & Reassurance", text: $calmingTechniques)
                    }
                    .padding(.horizontal, 20)

                    // 6. Emergency Contacts
                    EditSectionCard(title: "EMERGENCY CONTACTS", icon: "phone.fill", color: PawPlanTheme.electricBlue) {
                        FormField(label: "Primary Contact Name *", text: $primaryContactName)
                        FormField(label: "Primary Phone *", text: $primaryContactPhone)
                        FormField(label: "Secondary Contact Name", text: $secondaryContactName)
                        FormField(label: "Secondary Phone", text: $secondaryContactPhone)
                    }
                    .padding(.horizontal, 20)

                    // 7. Veterinarian & 24/7 Hospital
                    EditSectionCard(title: "VETERINARIAN & 24/7 CLINIC", icon: "cross.case.fill", color: PawPlanTheme.vetHealth) {
                        FormField(label: "Preferred Clinic Name *", text: $vetClinicName)
                        FormField(label: "Attending Vet Doctor", text: $vetDoctorName)
                        FormField(label: "Clinic Phone", text: $vetPhone)
                        FormField(label: "Clinic Address", text: $vetAddress)
                        FormField(label: "24/7 Emergency Hospital", text: $emergency24hHospital)
                    }
                    .padding(.horizontal, 20)

                    // 8. Home & Special Care
                    EditSectionCard(title: "HOME ACCESS & SLEEPING", icon: "house.fill", color: PawPlanTheme.lightCyan) {
                        FormField(label: "Home Access / Lockbox (Sensitive)", text: $homeAccessNotes)
                        FormField(label: "Sleeping Arrangements", text: $sleepingArrangements)
                        FormField(label: "Special Instructions", text: $specialCareNotes)
                    }
                    .padding(.horizontal, 20)

                    // Save Button
                    Button(action: saveCareProfile) {
                        Text("Save Care Instructions")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(PawPlanTheme.midnightNavy)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(PawPlanTheme.turquoiseGradient)
                            .cornerRadius(18)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.top, 14)
            }
        }
        .navigationTitle("Edit Care Instructions")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadExistingProfile()
        }
        .sheet(isPresented: $showAddMedicationSheet) {
            AddMedicationModal(
                medName: $newMedName,
                dosage: $newMedDosage,
                frequency: $newMedFrequency,
                instructions: $newMedInstructions,
                isPresented: $showAddMedicationSheet
            ) {
                let med = CareCircleMedication(
                    name: newMedName,
                    dosage: newMedDosage,
                    frequency: newMedFrequency,
                    administrationInstructions: newMedInstructions.isEmpty ? nil : newMedInstructions
                )
                medications.append(med)
                newMedName = ""
                newMedDosage = ""
                newMedFrequency = ""
                newMedInstructions = ""
            }
        }
        .alert("Care Profile", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func loadExistingProfile() {
        do {
            let profile = try container.manageCareCircleUseCase.executeGetProfile(for: dog.id)
            self.sitterName = profile.sitterName ?? ""
            self.sitterContact = profile.sitterContact ?? ""
            self.feedingSchedule = profile.feedingSchedule
            self.dietaryRestrictions = profile.dietaryRestrictions
            self.allergiesText = profile.allergies.joined(separator: ", ")
            self.treatGuidelines = profile.treatGuidelines
            self.medications = profile.medications
            self.walkingRoutine = profile.walkingRoutine
            self.favoriteParksText = profile.favoriteParks.joined(separator: ", ")
            self.leashGuidelines = profile.leashGuidelines
            self.groomingInstructions = profile.groomingInstructions
            self.bathingInstructions = profile.bathingInstructions
            self.behavioralNotes = profile.behavioralNotes
            self.triggersText = profile.triggers.joined(separator: ", ")
            self.calmingTechniques = profile.calmingTechniques
            self.primaryContactName = profile.primaryContactName
            self.primaryContactPhone = profile.primaryContactPhone
            self.secondaryContactName = profile.secondaryContactName ?? ""
            self.secondaryContactPhone = profile.secondaryContactPhone ?? ""
            self.vetClinicName = profile.vetClinicName
            self.vetDoctorName = profile.vetDoctorName ?? ""
            self.vetPhone = profile.vetPhone
            self.vetAddress = profile.vetAddress
            self.emergency24hHospital = profile.emergency24hHospital
            self.homeAccessNotes = profile.homeAccessNotes ?? ""
            self.sleepingArrangements = profile.sleepingArrangements
            self.specialCareNotes = profile.specialCareNotes ?? ""
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
        }
    }

    private func saveCareProfile() {
        let allergies = allergiesText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let favoriteParks = favoriteParksText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let triggers = triggersText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }

        let updated = CareCircleProfile(
            dogId: dog.id,
            sitterName: sitterName.isEmpty ? nil : sitterName,
            sitterContact: sitterContact.isEmpty ? nil : sitterContact,
            feedingSchedule: feedingSchedule,
            dietaryRestrictions: dietaryRestrictions,
            allergies: allergies,
            treatGuidelines: treatGuidelines,
            medications: medications,
            walkingRoutine: walkingRoutine,
            favoriteParks: favoriteParks,
            leashGuidelines: leashGuidelines,
            groomingInstructions: groomingInstructions,
            bathingInstructions: bathingInstructions,
            behavioralNotes: behavioralNotes,
            triggers: triggers,
            calmingTechniques: calmingTechniques,
            primaryContactName: primaryContactName,
            primaryContactPhone: primaryContactPhone,
            secondaryContactName: secondaryContactName.isEmpty ? nil : secondaryContactName,
            secondaryContactPhone: secondaryContactPhone.isEmpty ? nil : secondaryContactPhone,
            vetClinicName: vetClinicName,
            vetDoctorName: vetDoctorName.isEmpty ? nil : vetDoctorName,
            vetPhone: vetPhone,
            vetAddress: vetAddress,
            emergency24hHospital: emergency24hHospital,
            homeAccessNotes: homeAccessNotes.isEmpty ? nil : homeAccessNotes,
            sleepingArrangements: sleepingArrangements,
            specialCareNotes: specialCareNotes.isEmpty ? nil : specialCareNotes,
            updatedAt: Date()
        )

        do {
            try container.manageCareCircleUseCase.executeSaveProfile(updated)
            dismiss()
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
        }
    }
}

// MARK: - Subcomponents

private struct EditSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }

            content()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PawPlanTheme.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

struct FormField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(PawPlanTheme.subtext)

            TextField(label, text: $text)
                .font(.system(size: 14))
                .foregroundColor(PawPlanTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(PawPlanTheme.cardBackgroundElevated)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 0.8)
                )
        }
    }
}

private struct AddMedicationModal: View {
    @Binding var medName: String
    @Binding var dosage: String
    @Binding var frequency: String
    @Binding var instructions: String
    @Binding var isPresented: Bool
    let onAdd: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    FormField(label: "Medication Name (e.g. NexGard Spectra)", text: $medName)
                    FormField(label: "Dosage (e.g. 1 chewable tablet)", text: $dosage)
                    FormField(label: "Frequency (e.g. Monthly with food)", text: $frequency)
                    FormField(label: "Special Instructions (optional)", text: $instructions)

                    Spacer()

                    Button(action: {
                        onAdd()
                        isPresented = false
                    }) {
                        Text("Add to Profile")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PawPlanTheme.midnightNavy)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(PawPlanTheme.turquoiseGradient)
                            .cornerRadius(16)
                    }
                    .disabled(medName.isEmpty || dosage.isEmpty)
                }
                .padding(20)
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
        }
    }
}
