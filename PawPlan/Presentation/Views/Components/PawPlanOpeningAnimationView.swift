//
//  PawPlanOpeningAnimationView.swift
//  PawPlan
//
//  Created for PawPlan Opening Animation.
//

import SwiftUI

public struct PawPlanOpeningAnimationView: View {
    @Binding var isPresented: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0
    @State private var glowRadius: CGFloat = 0.0
    @State private var textOffset: CGFloat = 20.0
    @State private var textOpacity: Double = 0.0

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Glowing Animated Paw Print
                ZStack {
                    Circle()
                        .fill(PawPlanTheme.electricTurquoise.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .blur(radius: glowRadius)

                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                        .shadow(color: PawPlanTheme.electricTurquoise, radius: glowRadius)
                }
                .scaleEffect(scale)
                .opacity(opacity)

                // Wordmark & Tagline
                VStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Text("PAW")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(PawPlanTheme.textPrimary)
                        Text("PLAN")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(PawPlanTheme.electricTurquoise)
                    }

                    Text("Happy paws. Every day.")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)
                        .tracking(1.0)
                }
                .offset(y: textOffset)
                .opacity(textOpacity)
            }
        }
        .onAppear {
            if reduceMotion {
                // If Reduce Motion is enabled, transition immediately after a short fade
                opacity = 1.0
                textOpacity = 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        isPresented = false
                    }
                }
            } else {
                // Fluid spring animation
                withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                    scale = 1.0
                    opacity = 1.0
                    glowRadius = 24.0
                }

                withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                    textOffset = 0
                    textOpacity = 1.0
                }

                // Dismiss after 1.8 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scale = 1.15
                        opacity = 0.0
                        textOpacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isPresented = false
                    }
                }
            }
        }
    }
}
