//
//  PawPlanHeroCard.swift
//  PawPlan
//
//  Created for PawPlan Electric Ocean Visual Identity.
//

import SwiftUI

public struct PawPlanHeroCard: View {
    public let dogName: String
    public let breed: String
    @State private var isPulsing: Bool = false

    public init(dogName: String, breed: String) {
        self.dogName = dogName
        self.breed = breed
    }

    private var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning"
        } else if hour < 17 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }

    public var body: some View {
        ZStack {
            // Bright turquoise base card
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(PawPlanTheme.heroGradient)
                .shadow(color: PawPlanTheme.electricTurquoise.opacity(0.35), radius: 18, x: 0, y: 8)

            // Inner subtle decorative water/paw watermark
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                    .blur(radius: 20)
                    .offset(x: geo.size.width * 0.4, y: -geo.size.height * 0.3)

                Image(systemName: "pawprint.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .foregroundColor(Color.white.opacity(0.08))
                    .rotationEffect(.degrees(18))
                    .offset(x: geo.size.width * 0.58, y: geo.size.height * 0.15)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            // Foreground Content
            VStack(spacing: 8) {
                // Branded paw icon & title
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#080F20").opacity(0.12))
                            .frame(width: 48, height: 48)

                        Image(systemName: "pawprint.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color(hex: "#080F20"))
                            .scaleEffect(isPulsing ? 1.08 : 0.95)
                            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isPulsing)
                    }

                    Text("PawPlan")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "#080F20"))
                }
                .padding(.top, 4)

                // Tagline
                Text("Happy paws. Every day.")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "#080F20").opacity(0.85))
                    .tracking(0.5)

                // Divider line
                Rectangle()
                    .fill(Color(hex: "#080F20").opacity(0.18))
                    .frame(height: 1)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 4)

                // Greeting for the dog
                HStack(spacing: 6) {
                    Text("\(timeGreeting), \(dogName)!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#080F20"))

                    Text("•")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "#080F20").opacity(0.5))

                    Text(breed)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#080F20").opacity(0.75))
                }
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 16)
        }
        .frame(height: 160)
        .padding(.horizontal, 20)
        .onAppear {
            isPulsing = true
        }
    }
}
