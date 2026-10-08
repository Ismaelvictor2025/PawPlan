//
//  PawPlanUITests.swift
//  PawPlanUITests
//
//  Created by Vicky Neves Rohr on 8/10/2026.
//

import XCTest

final class PawPlanUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCaptureAppStoreScreenshots() throws {
        let app = XCUIApplication()
        
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                return true
            }
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }
        
        app.launch()
        
        // Tap app to trigger alert handler if present
        app.tap()
        
        let fileManager = FileManager.default
        let screenshotsDir = "/Users/ivnr/Documents/Documents:iOSApps/PawPlan/AppStore/Screenshots"
        try? fileManager.createDirectory(atPath: screenshotsDir, withIntermediateDirectories: true)
        
        // Wait for splash screen to dismiss
        sleep(3)
        
        // 1. Capture Today View
        let todayData = app.screenshot().pngRepresentation
        try? todayData.write(to: URL(fileURLWithPath: "\(screenshotsDir)/01_Today_Dashboard.png"))
        
        // 2. Schedule Tab
        let scheduleTab = app.buttons["Schedule"]
        if scheduleTab.waitForExistence(timeout: 5) {
            scheduleTab.tap()
            sleep(1)
            let scheduleData = app.screenshot().pngRepresentation
            try? scheduleData.write(to: URL(fileURLWithPath: "\(screenshotsDir)/02_Schedule_Timeline.png"))
        }
        
        // 3. Health Tab
        let healthTab = app.buttons["Health"]
        if healthTab.waitForExistence(timeout: 5) {
            healthTab.tap()
            sleep(1)
            let healthData = app.screenshot().pngRepresentation
            try? healthData.write(to: URL(fileURLWithPath: "\(screenshotsDir)/03_Health_Records.png"))
        }
        
        // 4. Explore Tab
        let exploreTab = app.buttons["Explore"]
        if exploreTab.waitForExistence(timeout: 5) {
            exploreTab.tap()
            sleep(1)
            let exploreData = app.screenshot().pngRepresentation
            try? exploreData.write(to: URL(fileURLWithPath: "\(screenshotsDir)/04_Sydney_Dog_Places.png"))
        }
        
        // 5. More Tab
        let moreTab = app.buttons["More"]
        if moreTab.waitForExistence(timeout: 5) {
            moreTab.tap()
            sleep(1)
            let moreData = app.screenshot().pngRepresentation
            try? moreData.write(to: URL(fileURLWithPath: "\(screenshotsDir)/05_More_Hub.png"))
        }

    }
}

