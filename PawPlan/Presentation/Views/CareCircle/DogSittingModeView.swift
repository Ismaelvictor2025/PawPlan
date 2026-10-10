//
//  DogSittingModeView.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Dog Sitting Mode.
//

import SwiftUI
import MapKit

public struct DogSittingModeView: View {
    @ObservedObject var container: AppDependencyContainer
    @State var session: SittingSession
    let dog: Dog

    @State private var activities: [SittingActivityLog] = []
    @State private var progressReport: SittingSessionProgressReport?
    @State private var showLogModal: Bool = false
    @State private var selectedLogType: SittingActivityType = .note
    @State private var customTitle: String = ""
    @State private var customNotes: String = ""
    @State private var showEndSessionAlert: Bool = false
    @State private var alertMessage: String?
    @State private var showAlert: Bool = false
    @ObservedObject private var locationManager = CareLocationManager.shared

    public init(container: AppDependencyContainer, session: SittingSession, dog: Dog) {
        self.container = container
        self._session = State(initialValue: session)
        self.dog = dog
    }

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Session Header Card
                    SessionHeaderCard(session: session, dog: dog) {
                        handleSessionAction()
                    }
                    .padding(.horizontal, 20)

                    // Care Pillars Progress & Quick Logging (Only if active or completed)
                    if let progress = progressReport {
                        CarePillarsProgressCard(
                            progress: progress,
                            isActive: session.status == .active,
                            onLogPillar: { type, title in
                                logQuickPillarActivity(type: type, title: title)
                            }
                        )
                        .padding(.horizontal, 20)
                    }

                    // Sitter Location Sharing Card
                    SitterLocationSharingCard(
                        session: session,
                        locationManager: locationManager,
                        onToggleSharing: { shouldShare in
                            toggleLocationSharing(shouldShare)
                        }
                    )
                    .padding(.horizontal, 20)

                    // Live Care Activity Timeline
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            SectionHeader(title: "CARE ACTIVITY TIMELINE")
                            Spacer()
                            if session.status == .active {
                                Button(action: {
                                    selectedLogType = .note
                                    customTitle = "Note / Photo Update"
                                    customNotes = ""
                                    showLogModal = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Log Note")
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(PawPlanTheme.electricTurquoise)
                                }
                            }
                        }

                        if activities.isEmpty {
                            EmptyActivityTimelineCard()
                        } else {
                            VStack(spacing: 10) {
                                ForEach(activities) { act in
                                    ActivityTimelineRow(activity: act)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Emergency Quick Bar
                    EmergencyQuickBar(session: session)
                        .padding(.horizontal, 20)

                    // End Session Button (If active)
                    if session.status == .active {
                        Button(action: { showEndSessionAlert = true }) {
                            HStack {
                                Image(systemName: "flag.checkered")
                                Text("Complete & End Sitting Session")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PawPlanTheme.midnightNavy)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(PawPlanTheme.turquoiseGradient)
                            .cornerRadius(18)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                    }

                    // Synchronization Disclosure Notice
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "iphone.and.arrow.forward")
                            .font(.system(size: 13))
                            .foregroundColor(PawPlanTheme.lightCyan)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("On-Device Activity Records")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(PawPlanTheme.lightCyan)
                            Text("Activities and walk timestamps are persisted locally in Apple Core Data. Real-time push updates to another person's device require a remote cloud backend. You can export a session summary to the owner at any time.")
                                .font(.system(size: 10))
                                .foregroundColor(PawPlanTheme.subtext)
                        }
                    }
                    .padding(12)
                    .background(PawPlanTheme.cardSurface)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .padding(.top, 14)
            }
        }
        .navigationTitle("Dog Sitting Mode")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSessionData()
        }
        .sheet(isPresented: $showLogModal) {
            LogActivityModal(
                type: $selectedLogType,
                title: $customTitle,
                notes: $customNotes,
                isPresented: $showLogModal
            ) {
                recordCustomActivity()
            }
        }
        .alert("End Sitting Session", isPresented: $showEndSessionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Complete Session", role: .destructive) {
                completeSession()
            }
        } message: {
            Text("This will mark the sitting session as completed and terminate any active location sharing. Continue?")
        }
        .alert("Sitting Mode", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func loadSessionData() {
        do {
            self.session = try container.manageSittingSessionUseCase.executeFetchSession(id: session.id)
            self.activities = try container.recordSittingActivityUseCase.executeFetchActivities(for: session.id)
            self.progressReport = try container.recordSittingActivityUseCase.executeCalculateProgress(for: session.id)
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
        }
    }

    private func handleSessionAction() {
        if session.status == .scheduled {
            do {
                self.session = try container.manageSittingSessionUseCase.executeStartSession(id: session.id)
                loadSessionData()
            } catch {
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }

    private func logQuickPillarActivity(type: SittingActivityType, title: String) {
        guard session.status == .active else { return }
        do {
            let lat = locationManager.currentLocation?.latitude
            let lon = locationManager.currentLocation?.longitude
            _ = try container.recordSittingActivityUseCase.executeRecordActivity(
                sessionId: session.id,
                dogId: dog.id,
                type: type,
                title: title,
                notes: "Recorded by \(session.sitterName)",
                loggedBy: session.sitterName,
                latitude: lat,
                longitude: lon
            )
            loadSessionData()
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
        }
    }

    private func recordCustomActivity() {
        guard session.status == .active else { return }
        do {
            let lat = locationManager.currentLocation?.latitude
            let lon = locationManager.currentLocation?.longitude
            _ = try container.recordSittingActivityUseCase.executeRecordActivity(
                sessionId: session.id,
                dogId: dog.id,
                type: selectedLogType,
                title: customTitle.isEmpty ? selectedLogType.rawValue : customTitle,
                notes: customNotes.isEmpty ? nil : customNotes,
                loggedBy: session.sitterName,
                latitude: lat,
                longitude: lon
            )
            loadSessionData()
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
        }
    }

    private func toggleLocationSharing(_ shouldShare: Bool) {
        do {
            self.session = try container.manageSittingSessionUseCase.executeUpdateLocationSharing(id: session.id, isSharing: shouldShare)
            if shouldShare {
                locationManager.startSharing(sessionId: session.id)
            } else {
                locationManager.stopSharing()
            }
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
        }
    }

    private func completeSession() {
        do {
            self.session = try container.manageSittingSessionUseCase.executeCompleteSession(id: session.id)
            locationManager.handleSessionEnded(sessionId: session.id)
            loadSessionData()
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
        }
    }
}

// MARK: - Subcomponents

private struct SessionHeaderCard: View {
    let session: SittingSession
    let dog: Dog
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(PawPlanTheme.cyanGradient)
                        .frame(width: 50, height: 50)
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 22))
                        .foregroundColor(PawPlanTheme.midnightNavy)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(dog.name) with \(session.sitterName)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text(session.formattedDurationDescription)
                        .font(.system(size: 12))
                        .foregroundColor(PawPlanTheme.subtext)
                }

                Spacer()

                StatusBadgeChip(
                    icon: session.status == .active ? "antenna.radiowaves.left.and.right" : "circle.fill",
                    label: session.status.rawValue,
                    color: session.status == .active ? PawPlanTheme.positiveGreen : PawPlanTheme.lightCyan
                )
            }

            if session.status == .scheduled {
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Sitting Session Now")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(PawPlanTheme.midnightNavy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(PawPlanTheme.turquoiseGradient)
                    .cornerRadius(14)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(PawPlanTheme.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(session.status == .active ? PawPlanTheme.positiveGreen.opacity(0.4) : PawPlanTheme.cardBorder, lineWidth: 1.2)
                )
        )
    }
}

private struct CarePillarsProgressCard: View {
    let progress: SittingSessionProgressReport
    let isActive: Bool
    let onLogPillar: (SittingActivityType, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("CARE PILLARS CHECKLIST")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
                Spacer()
                Text("\(progress.completedCoreActivities) of \(progress.totalCoreActivities) Completed")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(PawPlanTheme.midnightNavy.opacity(0.6))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(PawPlanTheme.turquoiseGradient)
                        .frame(width: geo.size.width * CGFloat(progress.progressRate), height: 8)
                }
            }
            .frame(height: 8)

            // 5 Checklist Buttons
            VStack(spacing: 8) {
                PillarChecklistRow(
                    title: "Feeding Completed",
                    icon: "fork.knife",
                    color: PawPlanTheme.feeding,
                    isDone: progress.hasFed,
                    isActive: isActive
                ) {
                    onLogPillar(.feeding, "Mealtime completed")
                }

                PillarChecklistRow(
                    title: "Walk Completed",
                    icon: "figure.walk",
                    color: PawPlanTheme.walk,
                    isDone: progress.hasWalked,
                    isActive: isActive
                ) {
                    onLogPillar(.walk, "Outdoor walk completed")
                }

                PillarChecklistRow(
                    title: "Medication Administered",
                    icon: "pills.fill",
                    color: PawPlanTheme.positiveGreen,
                    isDone: progress.hasGivenMedication,
                    isActive: isActive
                ) {
                    onLogPillar(.medication, "Medication administered")
                }

                PillarChecklistRow(
                    title: "Fresh Water Refreshed",
                    icon: "drop.fill",
                    color: PawPlanTheme.lightCyan,
                    isDone: progress.hasRefreshedWater,
                    isActive: isActive
                ) {
                    onLogPillar(.water, "Water bowl cleaned & refreshed")
                }

                PillarChecklistRow(
                    title: "Grooming & Paws Checked",
                    icon: "scissors",
                    color: PawPlanTheme.grooming,
                    isDone: progress.hasGroomed,
                    isActive: isActive
                ) {
                    onLogPillar(.grooming, "Paws wiped & brushed")
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(PawPlanTheme.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1.2)
                )
        )
    }
}

private struct PillarChecklistRow: View {
    let title: String
    let icon: String
    let color: Color
    let isDone: Bool
    let isActive: Bool
    let onLog: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
                .background(color.opacity(0.15))
                .cornerRadius(6)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            if isDone {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(PawPlanTheme.positiveGreen)
                    Text("Done")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(PawPlanTheme.positiveGreen)
                }
            } else if isActive {
                Button(action: onLog) {
                    Text("Mark Done")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(PawPlanTheme.midnightNavy)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(color)
                        .cornerRadius(10)
                }
            } else {
                Text("Pending")
                    .font(.system(size: 11))
                    .foregroundColor(PawPlanTheme.subtext)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct SitterLocationSharingCard: View {
    let session: SittingSession
    @ObservedObject var locationManager: CareLocationManager
    let onToggleSharing: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.north.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(PawPlanTheme.lightCyan)

                Text("CARE LOCATION (OPTIONAL)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(PawPlanTheme.lightCyan)

                Spacer()

                if session.status == .active {
                    Toggle("", isOn: Binding(
                        get: { locationManager.isSharingActive },
                        set: { onToggleSharing($0) }
                    ))
                    .labelsHidden()
                    .tint(PawPlanTheme.electricTurquoise)
                }
            }

            Text("Sitter location sharing is voluntary and session-limited. When active during walks, your current coordinates are shown below. Sharing terminates automatically when this session completes.")
                .font(.system(size: 11))
                .foregroundColor(PawPlanTheme.subtext)

            if let denied = locationManager.permissionDeniedReason {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(PawPlanTheme.amber)
                    Text(denied)
                        .font(.system(size: 11))
                        .foregroundColor(PawPlanTheme.amber)
                }
                .padding(10)
                .background(PawPlanTheme.amber.opacity(0.1))
                .cornerRadius(10)
            }

            if locationManager.isSharingActive, let coord = locationManager.currentLocation {
                // Mini Map Preview
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))) {
                    Marker("Active Walk", coordinate: coord)
                        .tint(PawPlanTheme.electricTurquoise)
                }
                .frame(height: 140)
                .cornerRadius(14)

                HStack {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(PawPlanTheme.positiveGreen)
                            .frame(width: 8, height: 8)
                        Text("Sharing Active")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(PawPlanTheme.positiveGreen)
                    }
                    Spacer()
                    Button("Stop Sharing") {
                        onToggleSharing(false)
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(PawPlanTheme.vetHealth)
                }
            }
        }
        .padding(16)
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

private struct ActivityTimelineRow: View {
    let activity: SittingActivityLog

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: activity.activityType.iconName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: activity.activityType.badgeColorHex))
                .frame(width: 24, height: 24)
                .background(Color(hex: activity.activityType.badgeColorHex).opacity(0.15))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(activity.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(activity.formattedTime)
                        .font(.system(size: 11))
                        .foregroundColor(PawPlanTheme.subtext)
                }

                if let notes = activity.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 12))
                        .foregroundColor(PawPlanTheme.subtext)
                }

                Text("Logged by \(activity.loggedBy)")
                    .font(.system(size: 10))
                    .foregroundColor(PawPlanTheme.lightCyan)
            }
        }
        .padding(12)
        .background(PawPlanTheme.midnightNavy.opacity(0.4))
        .cornerRadius(12)
    }
}

private struct EmptyActivityTimelineCard: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 24))
                    .foregroundColor(PawPlanTheme.subtext)
                Text("No activities logged yet")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(PawPlanTheme.subtext)
                Text("Check off feeding, walking, or log a note above.")
                    .font(.system(size: 11))
                    .foregroundColor(PawPlanTheme.subtext.opacity(0.7))
            }
            .padding(20)
            Spacer()
        }
        .background(PawPlanTheme.cardSurface)
        .cornerRadius(16)
    }
}

private struct EmergencyQuickBar: View {
    let session: SittingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EMERGENCY ASSISTANCE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(PawPlanTheme.vetHealth)

            HStack(spacing: 12) {
                Button(action: {
                    if let phone = session.emergencyContact, let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                        Text("Call Owner")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(PawPlanTheme.electricBlue)
                    .cornerRadius(12)
                }

                Button(action: {
                    if let url = URL(string: "tel://0289134000") { // SASH Emergency
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "cross.fill")
                        Text("24/7 Vet (SASH)")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(PawPlanTheme.vetHealth)
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(PawPlanTheme.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

private struct LogActivityModal: View {
    @Binding var type: SittingActivityType
    @Binding var title: String
    @Binding var notes: String
    @Binding var isPresented: Bool
    let onSave: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    Picker("Activity Type", selection: $type) {
                        ForEach(SittingActivityType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)

                    FormField(label: "Activity Title", text: $title)
                    FormField(label: "Notes / Description", text: $notes)

                    Spacer()

                    Button(action: {
                        onSave()
                        isPresented = false
                    }) {
                        Text("Save Activity Log")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PawPlanTheme.midnightNavy)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(PawPlanTheme.turquoiseGradient)
                            .cornerRadius(16)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Log Sitting Activity")
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

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(PawPlanTheme.subtext)
            .tracking(1.2)
    }
}
