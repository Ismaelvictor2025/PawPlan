//
//  ContentView.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import SwiftUI

public struct ContentView: View {
    @StateObject private var container = AppDependencyContainer.shared
    @State private var showOpeningAnimation: Bool = true
    @State private var showOnboarding: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            MainTabView(container: container)
                .environmentObject(container)

            // Opening brand intro animation
            if showOpeningAnimation {
                PawPlanOpeningAnimationView(isPresented: $showOpeningAnimation)
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showOnboarding) {
            PawPlanOnboardingView(container: container, isPresented: $showOnboarding)
        }
        .onAppear {
            if container.dogs.isEmpty {
                showOnboarding = true
            }
        }
    }
}

#Preview {
    ContentView()
}
