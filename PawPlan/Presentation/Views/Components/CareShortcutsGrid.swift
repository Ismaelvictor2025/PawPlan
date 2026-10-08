//
//  CareShortcutsGrid.swift
//  PawPlan
//
//  Created for PawPlan Electric Ocean Visual Identity.
//

import SwiftUI

public enum CareShortcutDestination: Identifiable {
    case vetHealth
    case training
    case reminders
    case grooming
    case expenses
    case petPlaces

    public var id: String {
        switch self {
        case .vetHealth: return "vetHealth"
        case .training: return "training"
        case .reminders: return "reminders"
        case .grooming: return "grooming"
        case .expenses: return "expenses"
        case .petPlaces: return "petPlaces"
        }
    }
}

public struct CareShortcutsGrid: View {
    public let onSelect: (CareShortcutDestination) -> Void

    public init(onSelect: @escaping (CareShortcutDestination) -> Void) {
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CARE & WELLNESS SHORTCUTS")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(PawPlanTheme.textSecondary)
                .tracking(1.0)
                .padding(.horizontal, 20)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                // 1. Vet & Health — Pink
                ShortcutGridCard(
                    title: "Vet & Health",
                    subtitle: "Medical Hub",
                    iconName: "cross.case.fill",
                    color: PawPlanTheme.vetHealth,
                    gradient: PawPlanTheme.pinkGradient
                ) {
                    onSelect(.vetHealth)
                }

                // 2. Training — Orange
                ShortcutGridCard(
                    title: "Training",
                    subtitle: "Academy",
                    iconName: "rosette",
                    color: PawPlanTheme.training,
                    gradient: PawPlanTheme.orangeGradient
                ) {
                    onSelect(.training)
                }

                // 3. Reminders — Green
                ShortcutGridCard(
                    title: "Reminders",
                    subtitle: "Alerts & Push",
                    iconName: "bell.badge.fill",
                    color: PawPlanTheme.medication,
                    gradient: PawPlanTheme.greenGradient
                ) {
                    onSelect(.reminders)
                }

                // 4. Grooming — Violet
                ShortcutGridCard(
                    title: "Grooming",
                    subtitle: "Hygiene & Coat",
                    iconName: "scissors",
                    color: PawPlanTheme.grooming,
                    gradient: PawPlanTheme.violetGradient
                ) {
                    onSelect(.grooming)
                }

                // 5. Expenses — Amber
                ShortcutGridCard(
                    title: "Expenses",
                    subtitle: "Care Budget",
                    iconName: "dollarsign.circle.fill",
                    color: PawPlanTheme.expenses,
                    gradient: PawPlanTheme.amberGradient
                ) {
                    onSelect(.expenses)
                }

                // 6. Pet Places — Cyan
                ShortcutGridCard(
                    title: "Pet Places",
                    subtitle: "Sydney Guide",
                    iconName: "map.fill",
                    color: PawPlanTheme.petPlaces,
                    gradient: PawPlanTheme.cyanGradient
                ) {
                    onSelect(.petPlaces)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct ShortcutGridCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Glowing circular icon button
                ZStack {
                    Circle()
                        .fill(gradient)
                        .frame(width: 44, height: 44)
                        .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 3)

                    Image(systemName: iconName)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 4)

                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 104)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(PawPlanTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
