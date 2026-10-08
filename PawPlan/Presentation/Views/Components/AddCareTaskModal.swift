//
//  AddCareTaskModal.swift
//  PawPlan
//
//  Created for PawPlan Quick Actions.
//

import SwiftUI

public struct AddCareTaskModal: View {
    @ObservedObject var container: AppDependencyContainer
    @Binding var isPresented: Bool
    public var defaultCategory: CareTaskCategory

    @State private var title: String = ""
    @State private var category: CareTaskCategory
    @State private var scheduledDate: Date = Date()
    @State private var durationMinutes: Int = 30
    @State private var recurrenceRule: CareRecurrenceRule = .daily
    @State private var priority: CarePriority = .normal
    @State private var notes: String = ""
    @State private var reminderEnabled: Bool = true

    public init(
        container: AppDependencyContainer,
        isPresented: Binding<Bool>,
        defaultCategory: CareTaskCategory = .walk
    ) {
        self.container = container
        self._isPresented = isPresented
        self.defaultCategory = defaultCategory
        self._category = State(initialValue: defaultCategory)
        self._title = State(initialValue: defaultCategory == .walk ? "Afternoon Walk" : (defaultCategory == .feeding ? "Dinner Meal" : "Care Routine"))
    }

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("Task Details").foregroundColor(PawPlanTheme.textSecondary)) {
                        TextField("Title", text: $title)

                        Picker("Category", selection: $category) {
                            ForEach(CareTaskCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }

                        DatePicker("Scheduled Time", selection: $scheduledDate)
                            .tint(PawPlanTheme.electricTurquoise)

                        Stepper("Duration: \(durationMinutes) mins", value: $durationMinutes, in: 5...180, step: 5)

                        Picker("Recurrence", selection: $recurrenceRule) {
                            ForEach(CareRecurrenceRule.allCases, id: \.self) { rule in
                                Text(rule.rawValue).tag(rule)
                            }
                        }

                        Picker("Priority", selection: $priority) {
                            ForEach(CarePriority.allCases, id: \.self) { p in
                                Text(p.rawValue).tag(p)
                            }
                        }

                        Toggle("Reminder Notification", isOn: $reminderEnabled)
                            .tint(PawPlanTheme.electricTurquoise)

                        TextField("Care Notes & Instructions", text: $notes)
                    }
                    .listRowBackground(PawPlanTheme.cardBackgroundElevated)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Care Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(PawPlanTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        saveTask()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
        }
    }

    private func saveTask() {
        guard let dog = container.activeDog else { return }
        let task = CareTask(
            dogId: dog.id,
            title: title.isEmpty ? category.rawValue : title,
            category: category,
            recurrenceRule: recurrenceRule,
            scheduledDate: scheduledDate,
            durationMinutes: durationMinutes,
            priority: priority,
            notes: notes.isEmpty ? nil : notes,
            reminderEnabled: reminderEnabled
        )
        try? container.careTaskRepository.saveTask(task)
        if reminderEnabled {
            container.notificationService.scheduleTaskReminder(task: task, dogName: dog.name)
        }
        container.updateWidgetSnapshotUseCase.execute(activeDogId: dog.id)
        isPresented = false
    }
}
