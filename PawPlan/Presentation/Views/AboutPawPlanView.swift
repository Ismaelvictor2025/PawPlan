//
//  AboutPawPlanView.swift
//  PawPlan
//
//  Created for PawPlan App Info.
//

import SwiftUI

public struct AboutPawPlanView: View {
    public init() {}

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        PawPrintMark(size: 60, tintColor: PawPlanTheme.electricTurquoise, glow: true)

                        HStack(spacing: 2) {
                            Text("PAW")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("PLAN")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(PawPlanTheme.electricTurquoise)
                        }

                        Text("Happy paws. Every day.")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)

                        Text("Version 1.0 (Build 1)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(PawPlanTheme.textTertiary)
                    }
                    .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 14) {
                        InfoSectionRow(title: "Architecture Standard", detail: "Clean Architecture, MVVM, Domain Use Cases & Core Data Isolation")
                        InfoSectionRow(title: "Initial Launch Region", detail: "Sydney, New South Wales, Australia")
                        InfoSectionRow(title: "Design System", detail: "PawPlan Electric Ocean (Deep Navy #080F20, Turquoise #15D9D2)")
                        InfoSectionRow(title: "System Extensions", detail: "WidgetKit (Glanceable Lock & Home Widgets) + UNNotificationContentExtension")
                        InfoSectionRow(title: "Data & Privacy", detail: "100% Local Device Storage. No Third-Party Tracking or Ads.")
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(PawPlanTheme.cardGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("About PawPlan")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoSectionRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(PawPlanTheme.electricTurquoise)
            Text(detail)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(PawPlanTheme.textSecondary)
        }
    }
}
