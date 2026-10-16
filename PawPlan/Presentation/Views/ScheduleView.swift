//
//  ScheduleView.swift
//  PawPlan
//
//  Created for PawPlan Daily Care Planner.
//

import SwiftUI

public struct ScheduleView: View {
    @ObservedObject var container: AppDependencyContainer

    @State private var selectedCategoryFilter: CareTaskCategory? = nil
    @State private var tasks: [CareTask] = []
    @State private var showAddTaskSheet: Bool = false

    public init(container: AppDependencyContainer) {
        self.container = container
    }

    private var filteredTasks: [CareTask] {
        if let filter = selectedCategoryFilter {
            return tasks.filter { $0.category == filter }
        }
        return tasks
    }

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Category Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All Care",
                                isSelected: selectedCategoryFilter == nil
                            ) {
                                selectedCategoryFilter = nil
                            }

                            ForEach(CareTaskCategory.allCases, id: \.self) { cat in
                                FilterChip(
                                    title: cat.rawValue,
                                    icon: cat.iconName,
                                    isSelected: selectedCategoryFilter == cat
                                ) {
                                    selectedCategoryFilter = cat
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)

                    // Task List
                    if filteredTasks.isEmpty {
                        VStack(spacing: 14) {
                            Spacer()
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 48))
                                .foregroundColor(PawPlanTheme.electricTurquoise.opacity(0.6))
                            Text("No Scheduled Tasks")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Tap the '+' button below to add a recurring walk, feeding, or care item.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(filteredTasks) { task in
                                TaskRowCard(
                                    task: task,
                                    onToggle: {
                                        toggleTask(task)
                                    }
                                )
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteTask(task)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Care Schedule")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTaskSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(PawPlanTheme.electricTurquoise)
                    }
                }
            }
            .sheet(isPresented: $showAddTaskSheet) {
                AddCareTaskModal(container: container, isPresented: $showAddTaskSheet)
                    .onDisappear { loadTasks() }
            }
            .onAppear { loadTasks() }
            .onChange(of: container.activeDog) { loadTasks() }
        }
    }

    private func loadTasks() {
        guard let dog = container.activeDog else { return }
        do {
            tasks = try container.getUpcomingCareTasksUseCase.execute(for: dog.id)
        } catch {
            print("Error loading schedule: \(error)")
        }
    }

    private func toggleTask(_ task: CareTask) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            if !task.isCompleted {
                _ = try? container.completeCareTaskUseCase.execute(task: task)
            } else {
                var reverted = task
                reverted.isCompleted = false
                try? container.careTaskRepository.saveTask(reverted)
            }
            loadTasks()
            if let active = container.activeDog {
                container.updateWidgetSnapshotUseCase.execute(activeDogId: active.id)
            }
        }
    }

    private func deleteTask(_ task: CareTask) {
        withAnimation {
            try? container.careTaskRepository.deleteTask(id: task.id)
            loadTasks()
            if let active = container.activeDog {
                container.updateWidgetSnapshotUseCase.execute(activeDogId: active.id)
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSelected ? Color(hex: "#080F20") : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isSelected ? PawPlanTheme.electricTurquoise : PawPlanTheme.cardBackgroundElevated)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : PawPlanTheme.cardBorder, lineWidth: 1)
            )
        }
    }
}

private struct TaskRowCard: View {
    let task: CareTask
    let onToggle: () -> Void

    private var timeString: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: task.scheduledDate)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Checkmark button
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? PawPlanTheme.electricTurquoise : PawPlanTheme.textSecondary, lineWidth: 2)
                        .frame(width: 26, height: 26)

                    if task.isCompleted {
                        Circle()
                            .fill(PawPlanTheme.electricTurquoise)
                            .frame(width: 18, height: 18)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Color(hex: "#080F20"))
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(task.isCompleted ? PawPlanTheme.textSecondary : .white)
                        .strikethrough(task.isCompleted)

                    Spacer()

                    Text(timeString)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: task.category.iconName)
                            .font(.system(size: 10))
                        Text(task.category.rawValue)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Color(hex: task.category.accentColorHex))

                    Text("•")
                        .foregroundColor(PawPlanTheme.textTertiary)

                    Text(task.recurrenceRule.rawValue)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)

                    if let notes = task.notes, !notes.isEmpty {
                        Text("•")
                            .foregroundColor(PawPlanTheme.textTertiary)
                        Text(notes)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(PawPlanTheme.textTertiary)
                            .lineLimit(1)
                    }
                }
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
