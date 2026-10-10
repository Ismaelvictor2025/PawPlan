//
//  MoreView.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import SwiftUI
import StoreKit

public struct MoreView: View {
    @ObservedObject var container: AppDependencyContainer

    @State private var showDogPicker: Bool = false
    @State private var showExportAlert: Bool = false
    @State private var exportedCSV: String = ""
    @Environment(\.requestReview) var requestReview

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
                        // Active Dog Profile Card
                        if let dog = container.activeDog {
                            ActiveDogSummaryCard(dog: dog) {
                                showDogPicker = true
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }

                        // Feature Navigation Sections
                        VStack(spacing: 12) {
                            SectionHeader(title: "SPECIALISED PET CARE")

                            NavigationLink(destination: CareCircleDashboardView(container: container)) {
                                MoreFeatureRow(
                                    title: "PawPlan Care Circle",
                                    subtitle: "Sitter packet, sitting mode & live updates",
                                    icon: "person.2.badge.gearshape.fill",
                                    color: PawPlanTheme.electricTurquoise,
                                    gradient: PawPlanTheme.turquoiseGradient
                                )
                            }

                            NavigationLink(destination: PuppyAcademyView(container: container)) {
                                MoreFeatureRow(
                                    title: "Puppy Training Academy",
                                    subtitle: "Toilet training, leash manners & recall",
                                    icon: "rosette",
                                    color: PawPlanTheme.training,
                                    gradient: PawPlanTheme.orangeGradient
                                )
                            }

                            NavigationLink(destination: ExpensesTrackerView(container: container)) {
                                MoreFeatureRow(
                                    title: "Pet Care Expenses & Budget",
                                    subtitle: "Monthly totals, categories & CSV export",
                                    icon: "dollarsign.circle.fill",
                                    color: PawPlanTheme.expenses,
                                    gradient: PawPlanTheme.amberGradient
                                )
                            }

                            NavigationLink(destination: DocumentVaultView(container: container)) {
                                MoreFeatureRow(
                                    title: "Document Vault",
                                    subtitle: "Vaccination certs & NSW Pet Registry",
                                    icon: "folder.fill",
                                    color: PawPlanTheme.lightCyan,
                                    gradient: PawPlanTheme.cyanGradient
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            SectionHeader(title: "SAFETY & NSW REGULATIONS")

                            NavigationLink(destination: EmergencyHubView(container: container)) {
                                MoreFeatureRow(
                                    title: "Emergency Care Hub",
                                    subtitle: "24/7 vets, poison info & triage checklist",
                                    icon: "cross.fill",
                                    color: PawPlanTheme.vetHealth,
                                    gradient: PawPlanTheme.pinkGradient
                                )
                            }

                            NavigationLink(destination: NSWPetRegulationsView()) {
                                MoreFeatureRow(
                                    title: "NSW Pet Regulations Guide",
                                    subtitle: "Microchipping, council reg & tick season",
                                    icon: "doc.plaintext.fill",
                                    color: PawPlanTheme.electricTurquoise,
                                    gradient: PawPlanTheme.turquoiseGradient
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            SectionHeader(title: "APP & SUPPORT")

                            Button {
                                requestReview()
                            } label: {
                                MoreFeatureRow(
                                    title: "Rate PawPlan on App Store",
                                    subtitle: "Share feedback for our Sydney dog community",
                                    icon: "star.fill",
                                    color: PawPlanTheme.expenses,
                                    gradient: PawPlanTheme.amberGradient
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink(destination: AboutPawPlanView()) {
                                MoreFeatureRow(
                                    title: "About PawPlan",
                                    subtitle: "Version 1.0 (Build 1) • Architecture & Privacy",
                                    icon: "info.circle.fill",
                                    color: PawPlanTheme.lightCyan,
                                    gradient: PawPlanTheme.electricBlueGradient
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showDogPicker) {
                DogProfilePickerModal(container: container, isPresented: $showDogPicker)
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(PawPlanTheme.textSecondary)
                .tracking(1)
            Spacer()
        }
        .padding(.top, 6)
    }
}

private struct ActiveDogSummaryCard: View {
    let dog: Dog
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(PawPlanTheme.turquoiseGradient)
                        .frame(width: 52, height: 52)
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#080F20"))
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(dog.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(dog.sex.rawValue)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(PawPlanTheme.electricTurquoise)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(PawPlanTheme.electricTurquoise.opacity(0.15)))
                    }

                    Text("\(dog.breed) • \(dog.weightDescription) • \(dog.suburb ?? "Sydney")")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(PawPlanTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1.2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct MoreFeatureRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 42, height: 42)
                    .shadow(color: color.opacity(0.35), radius: 6, x: 0, y: 3)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(PawPlanTheme.textTertiary)
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
