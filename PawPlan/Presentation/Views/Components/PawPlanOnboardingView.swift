//
//  PawPlanOnboardingView.swift
//  PawPlan
//
//  Created for PawPlan Onboarding Experience.
//

import SwiftUI

public struct PawPlanOnboardingView: View {
    @ObservedObject var container: AppDependencyContainer
    @Binding var isPresented: Bool

    @State private var currentStep: Int = 0

    // Form fields
    @State private var dogName: String = ""
    @State private var breed: String = ""
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    @State private var weightString: String = "8.5"
    @State private var sex: DogSex = .male
    @State private var isDesexed: Bool = true
    @State private var suburb: String = "Surry Hills"
    @State private var microchipNumber: String = ""
    @State private var councilRegistration: String = ""
    @State private var careNotes: String = ""
    @State private var walkingPreference: String = "Morning (7:30 AM) & Evening (5:30 PM)"
    @State private var feedingPreference: String = "Twice daily (Kibble + Fresh toppers)"

    public init(container: AppDependencyContainer, isPresented: Binding<Bool>) {
        self.container = container
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header Bar
                HStack {
                    if currentStep > 0 {
                        Button {
                            withAnimation { currentStep -= 1 }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(PawPlanTheme.electricTurquoise)
                        }
                    } else {
                        Spacer()
                    }

                    Spacer()

                    // Skip / Demo Button
                    Button {
                        // Pre-fill demo and finish
                        container.resetToDemoData()
                        container.isOnboardingCompleted = true
                        withAnimation { isPresented = false }
                    } label: {
                        Text("Use Demo Mode")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(PawPlanTheme.cardBackgroundElevated)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Step Indicators
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Capsule()
                            .fill(index <= currentStep ? PawPlanTheme.electricTurquoise : PawPlanTheme.cardBorder)
                            .frame(height: 4)
                            .animation(.spring(), value: currentStep)
                    }
                }
                .padding(.horizontal, 24)

                // Page Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        switch currentStep {
                        case 0:
                            stepWelcome
                        case 1:
                            stepBasics
                        case 2:
                            stepRoutines
                        default:
                            stepSydneyAndRegistry
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }

                // Bottom Action Button
                VStack(spacing: 12) {
                    Button {
                        handleNext()
                    } label: {
                        HStack(spacing: 8) {
                            Text(currentStep == 3 ? "Complete & Open PawPlan" : "Continue")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "#080F20"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(PawPlanTheme.turquoiseGradient)
                                .shadow(color: PawPlanTheme.electricTurquoise.opacity(0.4), radius: 12, x: 0, y: 6)
                        )
                    }

                    if currentStep < 3 {
                        Button {
                            withAnimation { currentStep += 1 }
                        } label: {
                            Text("Skip this step")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Step 0: Welcome
    private var stepWelcome: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(PawPlanTheme.turquoiseGradient.opacity(0.2))
                    .frame(width: 110, height: 110)
                    .blur(radius: 12)

                Image(systemName: "pawprint.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(PawPlanTheme.electricTurquoise)
            }
            .padding(.top, 16)

            VStack(spacing: 8) {
                Text("Welcome to PawPlan")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Designed for dog owners in Sydney. Keep feeding, walks, medications, and vet visits beautifully organised.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 14) {
                WelcomeFeatureRow(icon: "figure.walk", color: PawPlanTheme.walks, title: "Daily Care Planner", desc: "Never forget walks, meals, or medications.")
                WelcomeFeatureRow(icon: "cross.case.fill", color: PawPlanTheme.vetHealth, title: "Health & Vaccinations", desc: "Sydney paralysis tick alerts & vet checkups.")
                WelcomeFeatureRow(icon: "map.fill", color: PawPlanTheme.petPlaces, title: "Sydney Pet Guide", desc: "Curated dog beaches, parks, and emergency vets.")
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(PawPlanTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                    )
            )
            .padding(.top, 10)
        }
    }

    // MARK: - Step 1: Dog Basics
    private var stepBasics: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Tell Us About Your Pup")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Let's create their individual care profile.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)
            }

            VStack(spacing: 16) {
                InputField(label: "Dog's Name", placeholder: "e.g. Archie", text: $dogName)
                InputField(label: "Breed or Mix", placeholder: "e.g. Cavoodle, Border Collie", text: $breed)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Approximate Birthday / Adoption Date")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)
                    DatePicker("", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .colorScheme(.dark)
                        .tint(PawPlanTheme.electricTurquoise)
                }

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Weight (kg)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)
                        TextField("8.5", text: $weightString)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(PawPlanTheme.cardBackgroundElevated)
                            )
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sex")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)
                        Picker("Sex", selection: $sex) {
                            ForEach(DogSex.allCases, id: \.self) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(height: 48)
                    }
                }

                Toggle(isOn: $isDesexed) {
                    Text("Desexed / Spayed / Neutered")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .tint(PawPlanTheme.electricTurquoise)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Step 2: Routines & Care
    private var stepRoutines: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Daily Care & Routines")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Set your preferred schedules for walks and meals.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)
            }

            VStack(spacing: 16) {
                InputField(label: "Typical Walking Schedule", placeholder: "e.g. 7:30 AM & 5:30 PM", text: $walkingPreference)
                InputField(label: "Feeding Preferences & Brand", placeholder: "e.g. Grain-free salmon kibble twice daily", text: $feedingPreference)
                InputField(label: "Dietary Notes or Allergies", placeholder: "e.g. Chicken sensitive, loves carrots", text: $careNotes)
            }
        }
    }

    // MARK: - Step 3: Sydney & Registration (Optional)
    private var stepSydneyAndRegistry: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Sydney Council & Registration")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Optional NSW Pet Registry and local council details.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)
            }

            VStack(spacing: 16) {
                InputField(label: "Sydney Suburb or Postcode", placeholder: "e.g. Surry Hills, 2010", text: $suburb)
                InputField(label: "Microchip Number (Optional)", placeholder: "15 digits (e.g. 95301000...)", text: $microchipNumber)
                InputField(label: "Council Registration Tag (Optional)", placeholder: "e.g. NSW-SYD-2025-1234", text: $councilRegistration)
            }

            HStack(spacing: 10) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(PawPlanTheme.electricTurquoise)
                Text("Stored securely and private on your device.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)
            }
            .padding(.top, 8)
        }
    }

    private func handleNext() {
        if currentStep < 3 {
            withAnimation { currentStep += 1 }
        } else {
            // Save custom profile
            let finalName = dogName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Archie" : dogName
            let finalBreed = breed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Cavoodle" : breed
            let weight = Double(weightString) ?? 8.5

            let dog = Dog(
                name: finalName,
                breed: finalBreed,
                birthDate: birthDate,
                weight: weight,
                sex: sex,
                isDesexed: isDesexed,
                microchipNumber: microchipNumber.isEmpty ? nil : microchipNumber,
                councilRegistration: councilRegistration.isEmpty ? nil : councilRegistration,
                careNotes: careNotes.isEmpty ? nil : careNotes,
                suburb: suburb.isEmpty ? "Sydney" : suburb,
                photoData: nil
            )

            container.saveDog(dog)

            // Create initial daily tasks
            let walkTask = CareTask(
                dogId: dog.id,
                title: "Daily Walk",
                category: .walk,
                recurrenceRule: .daily,
                intervalDays: 1,
                scheduledDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
                durationMinutes: 30,
                priority: .normal,
                notes: walkingPreference
            )
            let feedTask = CareTask(
                dogId: dog.id,
                title: "Daily Feeding",
                category: .feeding,
                recurrenceRule: .daily,
                intervalDays: 1,
                scheduledDate: Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date(),
                durationMinutes: 10,
                priority: .high,
                notes: feedingPreference
            )
            try? container.careTaskRepository.saveTask(walkTask)
            try? container.careTaskRepository.saveTask(feedTask)
            container.updateWidgetSnapshotUseCase.execute(activeDogId: dog.id)

            container.isOnboardingCompleted = true
            withAnimation { isPresented = false }
        }
    }
}

private struct WelcomeFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)
            }
        }
    }
}

private struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(PawPlanTheme.textSecondary)
            TextField(placeholder, text: $text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(PawPlanTheme.cardBackgroundElevated)
                )
                .foregroundColor(.white)
        }
    }
}
