//
//  TodayView.swift
//  PawPlan
//
//  Created for PawPlan Electric Ocean Visual Identity.
//

import SwiftUI

public struct TodayView: View {
    @ObservedObject var container: AppDependencyContainer
    @Binding var selectedTab: Int

    @State private var showDogPicker: Bool = false
    @State private var showAddWalk: Bool = false
    @State private var showAddFeeding: Bool = false
    @State private var showAddCareTask: Bool = false
    @State private var nextTask: CareTask?
    @State private var consistencyReport: CareConsistencyReport?
    @State private var showTestNotificationAlert: Bool = false

    public init(container: AppDependencyContainer, selectedTab: Binding<Int>) {
        self.container = container
        self._selectedTab = selectedTab
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Top Bar
                PawPlanTopBar(container: container, showDogPicker: $showDogPicker)

                // 1. TOP HERO CARD (Bright Electric Turquoise)
                PawPlanHeroCard(
                    dogName: container.activeDog?.name ?? "Good Dog",
                    breed: container.activeDog?.breed ?? "Loyal Companion"
                )

                // 2. NEXT CARE ACTIVITY CARD (Premium Dark Navy)
                NextCareActivityCard(
                    task: nextTask,
                    dogName: container.activeDog?.name ?? "Pup",
                    onComplete: { task in
                        handleComplete(task: task)
                    },
                    onTap: {
                        selectedTab = 1 // Switch to Schedule tab
                    }
                )

                // 3. QUICK ACTIONS (3 Colorful Cards)
                QuickActionsSection(
                    onAddWalk: { showAddWalk = true },
                    onAddFeeding: { showAddFeeding = true },
                    onAddCareTask: { showAddCareTask = true }
                )

                // 4. CARE & WELLNESS SHORTCUTS (3x2 Colorful Grid)
                CareShortcutsGrid { destination in
                    switch destination {
                    case .vetHealth:
                        selectedTab = 2 // Health
                    case .training:
                        selectedTab = 4 // More -> Training
                    case .reminders:
                        testTriggerNotification()
                    case .grooming:
                        selectedTab = 1 // Schedule
                    case .expenses:
                        selectedTab = 4 // More -> Expenses
                    case .petPlaces:
                        selectedTab = 3 // Explore
                    }
                }

                // 5. CARE CONSISTENCY & INSIGHTS CARD
                if let report = consistencyReport {
                    ConsistencySummaryCard(report: report)
                        .padding(.horizontal, 20)
                }

                Spacer(minLength: 40)
            }
            .padding(.bottom, 20)
        }
        .background(PawPlanTheme.background.ignoresSafeArea())
        .onAppear {
            loadDashboardData()
        }
        .onChange(of: container.activeDog) { _ in
            loadDashboardData()
        }
        .sheet(isPresented: $showDogPicker) {
            DogProfilePickerModal(container: container, isPresented: $showDogPicker)
        }
        .sheet(isPresented: $showAddWalk) {
            AddCareTaskModal(container: container, isPresented: $showAddWalk, defaultCategory: .walk)
                .onDisappear { loadDashboardData() }
        }
        .sheet(isPresented: $showAddFeeding) {
            AddCareTaskModal(container: container, isPresented: $showAddFeeding, defaultCategory: .feeding)
                .onDisappear { loadDashboardData() }
        }
        .sheet(isPresented: $showAddCareTask) {
            AddCareTaskModal(container: container, isPresented: $showAddCareTask, defaultCategory: .grooming)
                .onDisappear { loadDashboardData() }
        }
        .alert("Rich Reminder Triggered", isPresented: $showTestNotificationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("A pet care reminder has been scheduled for 5 seconds from now. Lock your screen or go to the home screen to see the custom Notification Content Extension interface!")
        }
    }

    private func loadDashboardData() {
        guard let dog = container.activeDog else { return }
        do {
            nextTask = try container.getUpcomingCareTasksUseCase.executeNext(for: dog.id)
            consistencyReport = try container.calculateCareConsistencyUseCase.execute(for: dog.id, days: 7)
        } catch {
            print("Dashboard error: \(error)")
        }
    }

    private func handleComplete(task: CareTask) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            _ = try? container.completeCareTaskUseCase.execute(task: task)
            loadDashboardData()
            if let active = container.activeDog {
                container.updateWidgetSnapshotUseCase.execute(activeDogId: active.id)
            }
        }
    }

    private func testTriggerNotification() {
        let name = container.activeDog?.name ?? "Archie"
        container.notificationService.scheduleTestReminder(dogName: name, delaySeconds: 5)
        showTestNotificationAlert = true
    }
}

private struct ConsistencySummaryCard: View {
    let report: CareConsistencyReport

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(PawPlanTheme.training)
                    Text("ROUTINE STREAK")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(PawPlanTheme.training)
                        .tracking(0.5)
                }

                Spacer()

                Text("\(report.currentStreakDays) Days Active")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.adherenceDescription)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("\(report.totalCompleted) care routines completed this week")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)
                }

                Spacer()

                // Circular Progress Indicator
                ZStack {
                    Circle()
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 6)
                        .frame(width: 52, height: 52)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(report.consistencyRate))
                        .stroke(
                            PawPlanTheme.turquoiseGradient,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 52, height: 52)

                    Text("\(Int(report.consistencyRate * 100))%")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
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
