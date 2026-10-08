//
//  MainTabView.swift
//  PawPlan
//
//  Created for PawPlan Main Navigation.
//

import SwiftUI

public struct MainTabView: View {
    @ObservedObject var container: AppDependencyContainer
    @State private var selectedTab: Int = 0

    public init(container: AppDependencyContainer) {
        self.container = container
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main Tab Content
            Group {
                switch selectedTab {
                case 0:
                    TodayView(container: container, selectedTab: $selectedTab)
                case 1:
                    ScheduleView(container: container)
                case 2:
                    HealthView(container: container)
                case 3:
                    ExploreView(container: container)
                default:
                    MoreView(container: container)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Translucent Floating Electric Ocean Bottom Bar
            CustomFloatingTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .ignoresSafeArea(.keyboard)
    }
}

private struct CustomFloatingTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            TabBarItem(
                title: "Today",
                icon: "house.fill",
                isSelected: selectedTab == 0
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { selectedTab = 0 }
            }

            TabBarItem(
                title: "Schedule",
                icon: "calendar",
                isSelected: selectedTab == 1
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { selectedTab = 1 }
            }

            TabBarItem(
                title: "Health",
                icon: "cross.case.fill",
                isSelected: selectedTab == 2
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { selectedTab = 2 }
            }

            TabBarItem(
                title: "Explore",
                icon: "map.fill",
                isSelected: selectedTab == 3
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { selectedTab = 3 }
            }

            TabBarItem(
                title: "More",
                icon: "ellipsis.circle.fill",
                isSelected: selectedTab == 4
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { selectedTab = 4 }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(hex: "#091427").opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 8)
        )
    }
}

private struct TabBarItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(PawPlanTheme.electricTurquoise.opacity(0.2))
                            .frame(width: 44, height: 26)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? PawPlanTheme.electricTurquoise : PawPlanTheme.textSecondary)
                }

                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : PawPlanTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
