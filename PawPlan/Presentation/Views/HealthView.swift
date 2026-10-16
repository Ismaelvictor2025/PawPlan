//
//  HealthView.swift
//  PawPlan
//
//  Created for PawPlan Health & Vet Records.
//

import SwiftUI

public struct HealthView: View {
    @ObservedObject var container: AppDependencyContainer

    @State private var healthRecords: [HealthRecord] = []
    @State private var vetAppointments: [VetAppointment] = []
    @State private var selectedTab: Int = 0 // 0: All Health, 1: Vaccinations, 2: Vet Visits
    @State private var showAddRecordSheet: Bool = false
    @State private var showAddAppointmentSheet: Bool = false

    public init(container: AppDependencyContainer) {
        self.container = container
    }

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Emergency Notice Banner (Safe medical disclaimer)
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(PawPlanTheme.lightCyan)
                            Text("Health records are for owner reference only. In an emergency, contact your nearest Sydney 24/7 veterinary hospital immediately.")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                                .lineSpacing(2)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(PawPlanTheme.cardBackgroundElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(PawPlanTheme.lightCyan.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                        // Next Vet Appointment Hero Card
                        if let nextAppt = vetAppointments.first(where: { !$0.isCompleted }) {
                            UpcomingVetCard(appointment: nextAppt)
                                .padding(.horizontal, 20)
                        }

                        // Segmented Control
                        Picker("", selection: $selectedTab) {
                            Text("Records").tag(0)
                            Text("Vaccinations").tag(1)
                            Text("Vet Visits").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)

                        // Content List
                        VStack(spacing: 12) {
                            if selectedTab == 0 {
                                ForEach(healthRecords) { record in
                                    HealthRecordCard(record: record)
                                }
                            } else if selectedTab == 1 {
                                ForEach(healthRecords.filter { $0.recordType == .vaccination || $0.recordType == .fleaTick || $0.recordType == .worming }) { record in
                                    HealthRecordCard(record: record)
                                }
                            } else {
                                ForEach(vetAppointments) { appt in
                                    VetAppointmentRow(appointment: appt)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Health & Vet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showAddRecordSheet = true
                        } label: {
                            Label("Add Health Record", systemImage: "plus.circle")
                        }

                        Button {
                            showAddAppointmentSheet = true
                        } label: {
                            Label("Add Vet Visit", systemImage: "cross.case")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(PawPlanTheme.electricTurquoise)
                    }
                }
            }
            .sheet(isPresented: $showAddRecordSheet) {
                AddHealthRecordModal(container: container, isPresented: $showAddRecordSheet)
                    .onDisappear { loadHealthData() }
            }
            .sheet(isPresented: $showAddAppointmentSheet) {
                AddVetAppointmentModal(container: container, isPresented: $showAddAppointmentSheet)
                    .onDisappear { loadHealthData() }
            }
            .onAppear { loadHealthData() }
            .onChange(of: container.activeDog) { loadHealthData() }
        }
    }

    private func loadHealthData() {
        guard let dog = container.activeDog else { return }
        do {
            healthRecords = try container.healthRecordRepository.fetchHealthRecords(for: dog.id)
            vetAppointments = try container.healthRecordRepository.fetchVetAppointments(for: dog.id)
        } catch {
            print("Error loading health records: \(error)")
        }
    }
}

private struct UpcomingVetCard: View {
    let appointment: VetAppointment

    private var dateString: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: appointment.scheduledDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "cross.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(PawPlanTheme.vetHealth)
                    Text("UPCOMING VET VISIT")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(PawPlanTheme.vetHealth)
                }
                Spacer()
                Text(dateString)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(appointment.clinicName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.textPrimary)
                Text(appointment.reason)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)
            }

            if let phone = appointment.contactPhone {
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 11))
                    Text(phone)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(PawPlanTheme.electricTurquoise)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PawPlanTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(PawPlanTheme.vetHealth.opacity(0.5), lineWidth: 1.2)
                )
        )
    }
}

private struct HealthRecordCard: View {
    let record: HealthRecord

    private var dateString: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: record.recordDate)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PawPlanTheme.pinkGradient.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: record.recordType.iconName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(PawPlanTheme.vetHealth)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.textPrimary)

                HStack(spacing: 6) {
                    Text(record.recordType.rawValue)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(PawPlanTheme.electricTurquoise)

                    Text("•")
                        .foregroundColor(PawPlanTheme.textTertiary)

                    Text(dateString)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)
                }

                if let notes = record.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textTertiary)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(PawPlanTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

private struct VetAppointmentRow: View {
    let appointment: VetAppointment

    private var dateString: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: appointment.scheduledDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(appointment.clinicName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.textPrimary)
                Spacer()
                Text(dateString)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
            }

            Text(appointment.reason)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(PawPlanTheme.textSecondary)

            if let vet = appointment.vetName {
                Text("Vet: \(vet)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textTertiary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(PawPlanTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

public struct AddHealthRecordModal: View {
    @ObservedObject var container: AppDependencyContainer
    @Binding var isPresented: Bool

    @State private var title: String = ""
    @State private var recordType: HealthRecordType = .vaccination
    @State private var recordDate: Date = Date()
    @State private var notes: String = ""
    @State private var veterinarian: String = "UVTHS Camperdown"
    @State private var batchNumber: String = ""

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("Record Details").foregroundColor(PawPlanTheme.textSecondary)) {
                        TextField("Title (e.g. C5 Annual Booster)", text: $title)

                        Picker("Type", selection: $recordType) {
                            ForEach(HealthRecordType.allCases, id: \.self) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }

                        DatePicker("Date Administered", selection: $recordDate, displayedComponents: .date)
                            .tint(PawPlanTheme.electricTurquoise)

                        TextField("Veterinarian or Clinic", text: $veterinarian)
                        TextField("Batch Number (Optional)", text: $batchNumber)
                        TextField("Clinical Notes", text: $notes)
                    }
                    .listRowBackground(PawPlanTheme.cardBackgroundElevated)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Health Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(PawPlanTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard let dog = container.activeDog else { return }
                        let record = HealthRecord(
                            dogId: dog.id,
                            recordType: recordType,
                            title: title.isEmpty ? recordType.rawValue : title,
                            recordDate: recordDate,
                            notes: notes.isEmpty ? nil : notes,
                            veterinarian: veterinarian.isEmpty ? nil : veterinarian,
                            batchNumber: batchNumber.isEmpty ? nil : batchNumber
                        )
                        try? container.healthRecordRepository.saveHealthRecord(record)
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
        }
    }
}

public struct AddVetAppointmentModal: View {
    @ObservedObject var container: AppDependencyContainer
    @Binding var isPresented: Bool

    @State private var clinicName: String = "UVTHS Camperdown"
    @State private var vetName: String = ""
    @State private var scheduledDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var reason: String = "General Checkup & Nails"
    @State private var contactPhone: String = "(02) 9351 3437"
    @State private var notes: String = ""

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("Vet Visit Information").foregroundColor(PawPlanTheme.textSecondary)) {
                        TextField("Clinic Name", text: $clinicName)
                        TextField("Reason for Visit", text: $reason)
                        DatePicker("Date & Time", selection: $scheduledDate)
                            .tint(PawPlanTheme.electricTurquoise)
                        TextField("Veterinarian Name", text: $vetName)
                        TextField("Contact Phone", text: $contactPhone)
                        TextField("Notes / Symptoms", text: $notes)
                    }
                    .listRowBackground(PawPlanTheme.cardBackgroundElevated)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Schedule Vet Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(PawPlanTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard let dog = container.activeDog else { return }
                        let appt = VetAppointment(
                            dogId: dog.id,
                            clinicName: clinicName.isEmpty ? "Sydney Vet Clinic" : clinicName,
                            vetName: vetName.isEmpty ? nil : vetName,
                            scheduledDate: scheduledDate,
                            reason: reason.isEmpty ? "Checkup" : reason,
                            notes: notes.isEmpty ? nil : notes,
                            contactPhone: contactPhone.isEmpty ? nil : contactPhone
                        )
                        try? container.healthRecordRepository.saveVetAppointment(appt)
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
        }
    }
}
