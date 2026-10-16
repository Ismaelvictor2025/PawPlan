//
//  PuppyAcademyView.swift
//  PawPlan
//
//  Created for PawPlan Puppy Training Academy.
//

import SwiftUI

public struct PuppyAcademyView: View {
    @ObservedObject var container: AppDependencyContainer
    @State private var progressList: [TrainingProgress] = []

    public init(container: AppDependencyContainer) {
        self.container = container
    }

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Banner
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(PawPlanTheme.training)
                            Text("HUMANE & REWARD-BASED")
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundColor(PawPlanTheme.training)
                                .tracking(0.5)
                        }

                        Text("Puppy Training Academy")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(PawPlanTheme.textPrimary)

                        Text("Positive reinforcement modules designed to build calm confidence and practical life skills for your dog in Sydney.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)
                            .lineSpacing(3)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(PawPlanTheme.cardGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(PawPlanTheme.training.opacity(0.4), lineWidth: 1.2)
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Modules
                    VStack(spacing: 16) {
                        ForEach(PuppyAcademyCurriculum.modules) { module in
                            ModuleCard(
                                module: module,
                                progressList: progressList,
                                onToggleMilestone: { milestone in
                                    toggleMilestone(module: module, milestone: milestone)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Training Academy")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadProgress() }
        .onChange(of: container.activeDog) { loadProgress() }
    }

    private func loadProgress() {
        guard let dog = container.activeDog else { return }
        do {
            progressList = try container.trainingRepository.fetchTrainingProgress(for: dog.id)
        } catch {
            print("Failed to load training progress: \(error)")
        }
    }

    private func toggleMilestone(module: TrainingModule, milestone: TrainingMilestone) {
        guard let dog = container.activeDog else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let existing = progressList.first { $0.moduleKey == module.id && $0.milestoneKey == milestone.id }
            let isNowCompleted = !(existing?.isCompleted ?? false)

            let updated = TrainingProgress(
                id: existing?.id ?? UUID(),
                dogId: dog.id,
                moduleKey: module.id,
                milestoneKey: milestone.id,
                title: milestone.title,
                isCompleted: isNowCompleted,
                completedAt: isNowCompleted ? Date() : nil,
                rating: isNowCompleted ? 5 : 0,
                notes: nil
            )

            try? container.trainingRepository.saveTrainingProgress(updated)
            loadProgress()
        }
    }
}

private struct ModuleCard: View {
    let module: TrainingModule
    let progressList: [TrainingProgress]
    let onToggleMilestone: (TrainingMilestone) -> Void

    @State private var isExpanded: Bool = true

    private var completedCount: Int {
        module.milestones.filter { m in
            progressList.first { $0.moduleKey == module.id && $0.milestoneKey == m.id }?.isCompleted == true
        }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Module Header
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: module.colorHex).opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: module.iconName)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(Color(hex: module.colorHex))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(module.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(PawPlanTheme.textPrimary)
                            .lineLimit(1)

                        Text("\(completedCount) of \(module.milestones.count) milestones completed")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(PawPlanTheme.textSecondary)
                }
            }
            .buttonStyle(.plain)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(PawPlanTheme.cardBackgroundElevated)
                        .frame(height: 6)

                    Capsule()
                        .fill(Color(hex: module.colorHex))
                        .frame(width: geo.size.width * CGFloat(Double(completedCount) / Double(max(1, module.milestones.count))), height: 6)
                }
            }
            .frame(height: 6)

            if isExpanded {
                VStack(spacing: 10) {
                    ForEach(module.milestones) { milestone in
                        let isCompleted = progressList.first { $0.moduleKey == module.id && $0.milestoneKey == milestone.id }?.isCompleted == true

                        MilestoneRow(
                            milestone: milestone,
                            isCompleted: isCompleted,
                            accentColor: Color(hex: module.colorHex)
                        ) {
                            onToggleMilestone(milestone)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PawPlanTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

private struct MilestoneRow: View {
    let milestone: TrainingMilestone
    let isCompleted: Bool
    let accentColor: Color
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? accentColor : PawPlanTheme.textSecondary, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isCompleted {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 16, height: 16)
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(Color(hex: "#080F20"))
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(milestone.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isCompleted ? PawPlanTheme.textSecondary : .white)
                    .strikethrough(isCompleted)

                Text(milestone.summary)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)

                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 10))
                        .foregroundColor(PawPlanTheme.training)
                    Text(milestone.tip)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textTertiary)
                }
                .padding(.top, 2)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PawPlanTheme.cardBackgroundElevated.opacity(0.6))
        )
    }
}
