//
//  PawPlanApp.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import SwiftUI

@main
struct PawPlanApp: App {
    @StateObject private var container = AppDependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, container.persistenceController.viewContext)
                .task {
                    _ = await container.notificationService.requestAuthorization()
                }
        }
    }
}
