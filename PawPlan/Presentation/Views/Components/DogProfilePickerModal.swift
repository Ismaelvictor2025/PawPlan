//
//  DogProfilePickerModal.swift
//  PawPlan
//
//  Created for PawPlan Multi-Dog Profiles.
//

import SwiftUI

public struct DogProfilePickerModal: View {
    @ObservedObject var container: AppDependencyContainer
    @Binding var isPresented: Bool
    @State private var showAddDogSheet: Bool = false

    public init(container: AppDependencyContainer, isPresented: Binding<Bool>) {
        self.container = container
        self._isPresented = isPresented
    }

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Select Active Dog Profile")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)

                        VStack(spacing: 12) {
                            ForEach(container.dogs) { dog in
                                Button {
                                    container.selectDog(dog)
                                    isPresented = false
                                } label: {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(dog.id == container.activeDog?.id ? PawPlanTheme.electricTurquoise : PawPlanTheme.cardBackgroundElevated)
                                                .frame(width: 50, height: 50)

                                            Image(systemName: "pawprint.fill")
                                                .font(.system(size: 22, weight: .bold))
                                                .foregroundColor(dog.id == container.activeDog?.id ? Color(hex: "#080F20") : PawPlanTheme.electricTurquoise)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(dog.name)
                                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                                    .foregroundColor(.white)
                                                if dog.id == container.activeDog?.id {
                                                    Text("ACTIVE")
                                                        .font(.system(size: 10, weight: .black, design: .rounded))
                                                        .foregroundColor(Color(hex: "#080F20"))
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(Capsule().fill(PawPlanTheme.electricTurquoise))
                                                }
                                            }

                                            Text("\(dog.breed) • \(dog.weightDescription) • \(dog.ageDescription)")
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                                .foregroundColor(PawPlanTheme.textSecondary)
                                        }

                                        Spacer()

                                        if dog.id == container.activeDog?.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 22, weight: .bold))
                                                .foregroundColor(PawPlanTheme.electricTurquoise)
                                        }
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(PawPlanTheme.cardGradient)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .stroke(dog.id == container.activeDog?.id ? PawPlanTheme.electricTurquoise : PawPlanTheme.cardBorder, lineWidth: 1.5)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Add Dog Button
                        Button {
                            showAddDogSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Add Another Dog Profile")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(PawPlanTheme.electricTurquoise)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(PawPlanTheme.cardBackgroundElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)

                        // Demo Mode Controls
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DEMO & TESTING CONTROLS")
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                                .tracking(1)

                            Button {
                                container.resetToDemoData()
                                isPresented = false
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Reset to Sydney Demo Data")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("Re-populates Archie, Bella, schedules & vet records")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(PawPlanTheme.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(PawPlanTheme.electricTurquoise)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(PawPlanTheme.cardBackgroundElevated)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
            .sheet(isPresented: $showAddDogSheet) {
                AddDogModal(container: container, isPresented: $showAddDogSheet)
            }
        }
    }
}

public struct AddDogModal: View {
    @ObservedObject var container: AppDependencyContainer
    @Binding var isPresented: Bool

    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var weightString: String = "10.0"
    @State private var sex: DogSex = .male
    @State private var isDesexed: Bool = true
    @State private var suburb: String = "Sydney"
    @State private var careNotes: String = ""

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("Dog Details").foregroundColor(PawPlanTheme.textSecondary)) {
                        TextField("Name (e.g. Luna)", text: $name)
                        TextField("Breed (e.g. Golden Retriever)", text: $breed)
                        TextField("Weight (kg)", text: $weightString)
                            .keyboardType(.decimalPad)
                        Picker("Sex", selection: $sex) {
                            ForEach(DogSex.allCases, id: \.self) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }
                        Toggle("Desexed", isOn: $isDesexed)
                        TextField("Sydney Suburb", text: $suburb)
                        TextField("Care Notes", text: $careNotes)
                    }
                    .listRowBackground(PawPlanTheme.cardBackgroundElevated)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Dog Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(PawPlanTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let weight = Double(weightString) ?? 10.0
                        let newDog = Dog(
                            name: name.isEmpty ? "My Dog" : name,
                            breed: breed.isEmpty ? "Mixed Breed" : breed,
                            weight: weight,
                            sex: sex,
                            isDesexed: isDesexed,
                            careNotes: careNotes.isEmpty ? nil : careNotes,
                            suburb: suburb.isEmpty ? nil : suburb
                        )
                        container.saveDog(newDog)
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
        }
    }
}
