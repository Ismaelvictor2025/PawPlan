//
//  PawPlanApp.swift
//  PawPlan
//
//  Created by Vicky Neves Rohr on 8/10/2026.
//

import SwiftUI
import CoreData

@main
struct PawPlanApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
