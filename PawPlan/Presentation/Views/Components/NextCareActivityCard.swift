//
//  NextCareActivityCard.swift
//  PawPlan
//
//  Created for PawPlan Electric Ocean Visual Identity.
//

import SwiftUI

public struct NextCareActivityCard: View {
    public let task: CareTask?
    public let dogName: String
    public let onComplete: (CareTask) -> Void
    public let onTap: () -> Void

    public init(
        task: CareTask?,
        dogName: String,
        onComplete: @escaping (CareTask) -> Void,
        onTap: @escaping () -> Void
    ) {
        self.task = task
        self.dogName = dogName
        self.onComplete = onComplete
        self.onTap = onTap
    }

    private var formattedTime: String {
        guard let task = task else { return "" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: task.scheduledDate)
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                // Top Row: Category pill & Time
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: task?.category.iconName ?? "pawprint.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(PawPlanTheme.electricTurquoise)

                        Text(task?.category.rawValue.uppercased() ?? "CARE SCHEDULE")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(PawPlanTheme.electricTurquoise)
                            .tracking(0.5)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(PawPlanTheme.cardBackgroundElevated)
                            .overlay(
                                Capsule()
                                    .stroke(PawPlanTheme.electricTurquoise.opacity(0.4), lineWidth: 1)
                            )
                    )

                    Spacer()

                    if let task = task {
                        Text(task.timeRemainingDescription)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(task.isOverdue ? PawPlanTheme.vetHealth : PawPlanTheme.lightCyan)
                    }
                }

                // Middle: Title and Dog Subtitle
                if let task = task {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text("\(dogName) • \(task.notes ?? "Scheduled daily routine")")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)
                            .lineLimit(1)
                    }

                    // Bottom Row: Duration pill & Quick Mark Done button
                    HStack {
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 11))
                                Text("\(task.durationMinutes) mins")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(PawPlanTheme.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.white.opacity(0.06))
                            )

                            if task.reminderEnabled {
                                HStack(spacing: 4) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 10))
                                    Text("Alert on")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                }
                                .foregroundColor(PawPlanTheme.electricTurquoise.opacity(0.9))
                            }
                        }

                        Spacer()

                        Button {
                            onComplete(task)
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Done")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(Color(hex: "#080F20"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(PawPlanTheme.turquoiseGradient)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    // Empty / all caught up
                    VStack(alignment: .leading, spacing: 4) {
                        Text("All Caught Up for Today!")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("No pending care tasks scheduled right now. Relax and enjoy cuddle time!")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(PawPlanTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1.2)
                    )
            )
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
    }
}
