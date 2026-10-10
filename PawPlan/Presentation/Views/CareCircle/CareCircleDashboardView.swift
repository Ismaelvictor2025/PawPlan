//
//  CareCircleDashboardView.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Feature Expansion.
//

import SwiftUI

public struct CareCircleDashboardView: View {
    @ObservedObject var container: AppDependencyContainer

    @State private var profile: CareCircleProfile?
    @State private var sessions: [SittingSession] = []
    @State private var activeSession: SittingSession?
    @State private var showShareSheet: Bool = false
    @State private var showNewSessionModal: Bool = false
    @State private var showAirTagGuide: Bool = false
    @State private var errorMessage: String?

    public init(container: AppDependencyContainer) {
        self.container = container
    }

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Hero Header Card
                    if let dog = container.activeDog {
                        CareCircleHeroHeader(dog: dog, activeSession: activeSession)
                    }

                    // Section 1: Dog Sitting Care Packet
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "SITTER CARE INSTRUCTIONS")

                        if let profile = profile, let dog = container.activeDog {
                            CarePacketSummaryCard(
                                profile: profile,
                                dog: dog,
                                onShare: { showShareSheet = true }
                            )

                            NavigationLink(destination: CareCircleProfileEditView(container: container, dog: dog)) {
                                HStack {
                                    Image(systemName: "pencil.and.list.clipboard")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("Edit Complete Care Instructions")
                                        .font(.system(size: 14, weight: .semibold))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(PawPlanTheme.electricTurquoise)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 13)
                                .background(PawPlanTheme.cardSurface)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                                )
                            }
                        } else {
                            ProgressView()
                                .tint(PawPlanTheme.electricTurquoise)
                                .frame(maxWidth: .infinity, minHeight: 120)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Section 2: Dog Sitting Mode & Active Sessions
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            SectionHeader(title: "DOG SITTING SESSIONS")
                            Spacer()
                            Button(action: { showNewSessionModal = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("New Session")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(PawPlanTheme.electricTurquoise)
                            }
                        }

                        if let active = activeSession, let dog = container.activeDog {
                            NavigationLink(destination: DogSittingModeView(container: container, session: active, dog: dog)) {
                                ActiveSessionCard(session: active, dog: dog)
                            }
                        } else if let firstScheduled = sessions.first(where: { $0.status == .scheduled }), let dog = container.activeDog {
                            NavigationLink(destination: DogSittingModeView(container: container, session: firstScheduled, dog: dog)) {
                                ScheduledSessionCard(session: firstScheduled, dog: dog)
                            }
                        } else {
                            EmptySittingSessionCard {
                                showNewSessionModal = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Section 3: Care Location & Find My AirTag Guide
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "LOCATION & AIRTAG COMPATIBILITY")

                        NavigationLink(destination: CareLocationView(container: container)) {
                            LocationAndAirTagBannerCard()
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Care Circle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCareCircleData()
        }
        .sheet(isPresented: $showShareSheet) {
            if let profile = profile, let dog = container.activeDog {
                CareCircleShareSheetView(container: container, profile: profile, dog: dog)
            }
        }
        .sheet(isPresented: $showNewSessionModal) {
            if let dog = container.activeDog {
                CreateSittingSessionModal(container: container, dog: dog, isPresented: $showNewSessionModal) {
                    loadCareCircleData()
                }
            }
        }
    }

    private func loadCareCircleData() {
        guard let dog = container.activeDog else { return }
        do {
            self.profile = try container.manageCareCircleUseCase.executeGetProfile(for: dog.id)
            self.sessions = try container.manageSittingSessionUseCase.executeFetchSessions(for: dog.id)
            self.activeSession = sessions.first(where: { $0.status == .active })
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Subcomponents

private struct CareCircleHeroHeader: View {
    let dog: Dog
    let activeSession: SittingSession?

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(PawPlanTheme.turquoiseGradient)
                        .frame(width: 54, height: 54)
                    Image(systemName: "person.2.badge.gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundColor(PawPlanTheme.midnightNavy)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(dog.name)'s Care Circle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text("Sitter instructions, live care updates & secure sharing")
                        .font(.system(size: 13))
                        .foregroundColor(PawPlanTheme.subtext)
                        .lineLimit(2)
                }
                Spacer()
            }

            // Quick Status Chips
            HStack(spacing: 10) {
                StatusBadgeChip(
                    icon: "checkmark.seal.fill",
                    label: "Care Packet Ready",
                    color: PawPlanTheme.electricTurquoise
                )

                if let active = activeSession {
                    StatusBadgeChip(
                        icon: "antenna.radiowaves.left.and.right",
                        label: "Sitting Active (\(active.sitterName))",
                        color: PawPlanTheme.positiveGreen
                    )
                } else {
                    StatusBadgeChip(
                        icon: "clock.fill",
                        label: "No Active Session",
                        color: PawPlanTheme.subtext
                    )
                }
                Spacer()
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
        .padding(.horizontal, 20)
    }
}

struct StatusBadgeChip: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .cornerRadius(12)
    }
}

private struct CarePacketSummaryCard: View {
    let profile: CareCircleProfile
    let dog: Dog
    let onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Dog Sitter Instructions")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("Updated \(profile.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 11))
                        .foregroundColor(PawPlanTheme.subtext)
                }
                Spacer()

                Button(action: onShare) {
                    HStack(spacing: 5) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Packet")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(PawPlanTheme.midnightNavy)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(PawPlanTheme.turquoiseGradient)
                    .cornerRadius(20)
                }
            }

            Divider()
                .background(PawPlanTheme.cardBorder)

            // Key Care Highlights Grid
            VStack(spacing: 10) {
                CareHighlightRow(
                    icon: "fork.knife",
                    color: PawPlanTheme.feeding,
                    title: "Feeding Routine",
                    detail: profile.feedingSchedule
                )

                if !profile.allergies.isEmpty {
                    CareHighlightRow(
                        icon: "exclamationmark.shield.fill",
                        color: PawPlanTheme.vetHealth,
                        title: "Allergies & Restrictions",
                        detail: profile.allergies.joined(separator: ", ")
                    )
                }

                CareHighlightRow(
                    icon: "figure.walk",
                    color: PawPlanTheme.walk,
                    title: "Walks & Exercise",
                    detail: profile.walkingRoutine
                )

                CareHighlightRow(
                    icon: "phone.fill",
                    color: PawPlanTheme.electricBlue,
                    title: "Primary Emergency",
                    detail: "\(profile.primaryContactName) • \(profile.primaryContactPhone)"
                )

                CareHighlightRow(
                    icon: "cross.case.fill",
                    color: PawPlanTheme.vetHealth,
                    title: "24/7 Hospital",
                    detail: profile.emergency24hHospital
                )
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

private struct CareHighlightRow: View {
    let icon: String
    let color: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
                .frame(width: 22, height: 22)
                .background(color.opacity(0.15))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(PawPlanTheme.subtext)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            Spacer()
        }
    }
}

private struct ActiveSessionCard: View {
    let session: SittingSession
    let dog: Dog

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PawPlanTheme.positiveGreen.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 20))
                    .foregroundColor(PawPlanTheme.positiveGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("ACTIVE SITTING SESSION")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(PawPlanTheme.positiveGreen)
                    Spacer()
                    Text("Live Dashboard")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }

                Text("Sitter: \(session.sitterName)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text(session.formattedDurationDescription)
                    .font(.system(size: 12))
                    .foregroundColor(PawPlanTheme.subtext)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PawPlanTheme.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(PawPlanTheme.positiveGreen.opacity(0.4), lineWidth: 1.5)
                )
        )
    }
}

private struct ScheduledSessionCard: View {
    let session: SittingSession
    let dog: Dog

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PawPlanTheme.electricBlue.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 20))
                    .foregroundColor(PawPlanTheme.electricBlue)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("UPCOMING SESSION")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(PawPlanTheme.lightCyan)
                    Spacer()
                    Text("Ready")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }

                Text("Sitter: \(session.sitterName)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Text(session.formattedDurationDescription)
                    .font(.system(size: 12))
                    .foregroundColor(PawPlanTheme.subtext)
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

private struct EmptySittingSessionCard: View {
    let onNewSession: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 28))
                .foregroundColor(PawPlanTheme.electricTurquoise)

            Text("No Active Dog Sitting Session")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            Text("Create a sitting session when leaving your dog with a sitter, family member, or boarding service.")
                .font(.system(size: 12))
                .foregroundColor(PawPlanTheme.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)

            Button(action: onNewSession) {
                Text("Start Sitting Session")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(PawPlanTheme.midnightNavy)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(PawPlanTheme.turquoiseGradient)
                    .cornerRadius(20)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
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

private struct LocationAndAirTagBannerCard: View {
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PawPlanTheme.cyanGradient)
                    .frame(width: 48, height: 48)
                Image(systemName: "location.north.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(PawPlanTheme.midnightNavy)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Walk Location & Find My AirTag Guide")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Text("Voluntary sitter walk tracking & Apple-supported tag sharing")
                    .font(.system(size: 12))
                    .foregroundColor(PawPlanTheme.subtext)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(PawPlanTheme.subtext)
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

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(PawPlanTheme.subtext)
            .tracking(1.2)
    }
}
