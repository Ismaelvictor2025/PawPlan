//
//  NSWPetRegulationsView.swift
//  PawPlan
//
//  Created for PawPlan Sydney Educational Guidance.
//

import SwiftUI

public struct NSWPetRegulationsView: View {
    public init() {}

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Banner
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(PawPlanTheme.electricTurquoise)
                            Text("NSW COMPANION ANIMALS ACT 1998")
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundColor(PawPlanTheme.electricTurquoise)
                                .tracking(0.5)
                        }

                        Text("Sydney Dog Owner Guide")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        Text("Essential legal obligations, council registration, off-leash rules, and tick prevention guidelines for responsible dog ownership in New South Wales.")
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
                                    .stroke(PawPlanTheme.cardBorder, lineWidth: 1.2)
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Guidance Cards
                    VStack(spacing: 14) {
                        ForEach(SydneyPetRegulationGuide.guidance) { item in
                            GuidanceCard(item: item)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("NSW Pet Rules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GuidanceCard: View {
    let item: NSWPetGuidanceItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(PawPlanTheme.turquoiseGradient.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: item.iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Source: \(item.authority)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(PawPlanTheme.textTertiary)
                }
            }

            Text(item.summary)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(PawPlanTheme.textSecondary)
                .lineSpacing(3)

            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(PawPlanTheme.lightCyan)
                Text(item.keyRequirement)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(PawPlanTheme.lightCyan)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(PawPlanTheme.cardBackgroundElevated))
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
