//
//  EmergencyHubView.swift
//  PawPlan
//
//  Created for PawPlan Emergency Information.
//

import SwiftUI

public struct EmergencyHubView: View {
    @ObservedObject var container: AppDependencyContainer

    public init(container: AppDependencyContainer) {
        self.container = container
    }

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Urgent Disclaimer
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(PawPlanTheme.vetHealth)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Sydney Emergency Assistance")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(PawPlanTheme.textPrimary)
                            Text("If your dog is unconscious, having seizures, choking, or showing paralysis tick signs, call an emergency hospital immediately.")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                                .lineSpacing(2)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(PawPlanTheme.cardGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(PawPlanTheme.vetHealth.opacity(0.6), lineWidth: 1.5)
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // 24/7 Verified Emergency Numbers (Australia)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("VERIFIED 24/7 EMERGENCY CONTACTS")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)
                            .tracking(1)

                        EmergencyCallButton(
                            title: "Animal Poisons Helpline (Australia)",
                            subtitle: "Free toxicology triage for pet owners in AU",
                            phone: "1300 869 738",
                            icon: "cross.fill"
                        )

                        EmergencyCallButton(
                            title: "SASH Alexandria 24/7 Emergency Vet",
                            subtitle: "411 Botany Rd, Alexandria NSW",
                            phone: "(02) 8913 4000",
                            icon: "cross.case.fill"
                        )

                        EmergencyCallButton(
                            title: "ARH Homebush 24/7 Emergency Vet",
                            subtitle: "250 Parramatta Rd, Homebush NSW",
                            phone: "(02) 9758 8666",
                            icon: "cross.case.fill"
                        )
                    }
                    .padding(.horizontal, 20)

                    // Critical Signs Checklist
                    VStack(alignment: .leading, spacing: 14) {
                        Text("CRITICAL SYMPTOM CHECKLIST")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)
                            .tracking(1)

                        TriageSymptomCard(
                            condition: "Paralysis Tick Toxicity",
                            symptoms: "Wobbly back legs, change in bark sound, coughing, vomiting, raspy laboured breathing.",
                            action: "Search coat immediately. Keep dog calm and cool. Do NOT offer food or water. Rush to vet."
                        )

                        TriageSymptomCard(
                            condition: "Heatstroke & Hyperthermia",
                            symptoms: "Excessive panting, bright red tongue/gums, thick saliva, weakness, collapsing.",
                            action: "Move to cool shade immediately. Wet coat with room-temperature (not ice) water and direct fan. Seek emergency vet."
                        )

                        TriageSymptomCard(
                            condition: "Bloat / Gastric Dilatation (GDV)",
                            symptoms: "Unproductive retching, distended tight abdomen, extreme restlessness, drooling.",
                            action: "Extreme emergency! Minutes matter. Transport to nearest emergency veterinary clinic immediately."
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Emergency Hub")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct EmergencyCallButton: View {
    let title: String
    let subtitle: String
    let phone: String
    let icon: String

    var body: some View {
        let cleanPhone = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        Link(destination: URL(string: "tel:\(cleanPhone)")!) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(PawPlanTheme.pinkGradient)
                        .frame(width: 44, height: 44)
                        .shadow(color: PawPlanTheme.vetHealth.opacity(0.4), radius: 6, x: 0, y: 3)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(PawPlanTheme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "phone.fill")
                    Text("Call")
                }
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(PawPlanTheme.vetHealth)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(PawPlanTheme.vetHealth.opacity(0.15)))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(PawPlanTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                    )
            )
        }
    }
}

private struct TriageSymptomCard: View {
    let condition: String
    let symptoms: String
    let action: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(condition)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(PawPlanTheme.lightCyan)

            VStack(alignment: .leading, spacing: 3) {
                Text("Signs: \(symptoms)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textPrimary)
                Text("Action: \(action)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PawPlanTheme.cardBackgroundElevated)
        )
    }
}
