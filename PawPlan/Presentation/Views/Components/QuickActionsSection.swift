//
//  QuickActionsSection.swift
//  PawPlan
//
//  Created for PawPlan Electric Ocean Visual Identity.
//

import SwiftUI

public struct QuickActionsSection: View {
    public let onAddWalk: () -> Void
    public let onAddFeeding: () -> Void
    public let onAddCareTask: () -> Void

    public init(
        onAddWalk: @escaping () -> Void,
        onAddFeeding: @escaping () -> Void,
        onAddCareTask: @escaping () -> Void
    ) {
        self.onAddWalk = onAddWalk
        self.onAddFeeding = onAddFeeding
        self.onAddCareTask = onAddCareTask
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 6) {
                Text("✦")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
                Text("Quick Actions")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.textPrimary)
            }
            .padding(.horizontal, 20)

            // 3 Colorful Buttons Grid
            HStack(spacing: 12) {
                // 1. + Walk (Electric Blue)
                QuickActionButton(
                    title: "+ Walk",
                    iconName: "figure.walk",
                    gradient: PawPlanTheme.electricBlueGradient,
                    glowColor: PawPlanTheme.electricBlue,
                    action: onAddWalk
                )

                // 2. + Feeding (Turquoise)
                QuickActionButton(
                    title: "+ Feeding",
                    iconName: "fork.knife",
                    gradient: PawPlanTheme.turquoiseGradient,
                    glowColor: PawPlanTheme.electricTurquoise,
                    action: onAddFeeding
                )

                // 3. + Care Task (Violet)
                QuickActionButton(
                    title: "+ Care Task",
                    iconName: "checklist",
                    gradient: PawPlanTheme.violetGradient,
                    glowColor: PawPlanTheme.grooming,
                    action: onAddCareTask
                )
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct QuickActionButton: View {
    let title: String
    let iconName: String
    let gradient: LinearGradient
    let glowColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 44, height: 44)

                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 4)

                Text(title)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(gradient)
                    .shadow(color: glowColor.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
