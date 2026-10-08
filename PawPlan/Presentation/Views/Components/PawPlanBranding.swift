//
//  PawPlanBranding.swift
//  PawPlan
//
//  Created for PawPlan Electric Ocean Visual Identity.
//

import SwiftUI

public struct PawPrintMark: View {
    public var size: CGFloat = 36
    public var tintColor: Color = PawPlanTheme.electricTurquoise
    public var glow: Bool = true

    public init(size: CGFloat = 36, tintColor: Color = PawPlanTheme.electricTurquoise, glow: Bool = true) {
        self.size = size
        self.tintColor = tintColor
        self.glow = glow
    }

    public var body: some View {
        ZStack {
            if glow {
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(tintColor.opacity(0.5))
                    .blur(radius: 6)
            }

            Image(systemName: "pawprint.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(tintColor)
        }
    }
}

public struct PawPlanWordmark: View {
    public var isDarkOnLight: Bool = false

    public init(isDarkOnLight: Bool = false) {
        self.isDarkOnLight = isDarkOnLight
    }

    public var body: some View {
        HStack(spacing: 6) {
            PawPrintMark(
                size: 22,
                tintColor: isDarkOnLight ? Color(hex: "#080F20") : PawPlanTheme.electricTurquoise,
                glow: !isDarkOnLight
            )

            HStack(spacing: 1) {
                Text("PAW")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(isDarkOnLight ? Color(hex: "#080F20") : .white)
                Text("PLAN")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(isDarkOnLight ? Color(hex: "#0A2540") : PawPlanTheme.electricTurquoise)
            }
        }
    }
}

public struct PawPlanTopBar: View {
    @ObservedObject var container: AppDependencyContainer
    @Binding var showDogPicker: Bool

    public var body: some View {
        HStack {
            PawPlanWordmark()

            Spacer()

            // Dog Selector / Demo Pill
            Button {
                showDogPicker = true
            } label: {
                HStack(spacing: 6) {
                    Circle()
                        .fill(PawPlanTheme.electricTurquoise)
                        .frame(width: 8, height: 8)

                    Text(container.activeDog?.name ?? "Demo Dog")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(PawPlanTheme.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(PawPlanTheme.cardBackgroundElevated)
                        .overlay(
                            Capsule()
                                .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}
