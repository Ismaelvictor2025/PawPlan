//
//  NotificationSchedulingService.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation
import UserNotifications

public final class NotificationSchedulingService: @unchecked Sendable {
    public static let shared = NotificationSchedulingService()

    public static let categoryIdentifier = "PAWPLAN_CARE_REMINDER"

    public init() {
        configureNotificationCategories()
    }

    public func requestAuthorization() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    public func configureNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "PAWPLAN_ACTION_COMPLETE",
            title: "Mark Completed",
            options: [.foreground]
        )
        let snoozeAction = UNNotificationAction(
            identifier: "PAWPLAN_ACTION_SNOOZE",
            title: "Snooze 15m",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: Self.categoryIdentifier,
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    public func scheduleTaskReminder(task: CareTask, dogName: String, triggerDate: Date? = nil) {
        guard task.reminderEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(task.category.rawValue) Time for \(dogName)"
        content.subtitle = task.title
        content.body = task.notes ?? "Keep up the routine! Happy paws, every day."
        content.sound = .default
        content.categoryIdentifier = Self.categoryIdentifier

        let payload = CareNotificationPayload(
            taskId: task.id.uuidString,
            dogId: task.dogId.uuidString,
            dogName: dogName,
            title: task.title,
            category: task.category.rawValue,
            priority: task.priority.rawValue,
            scheduledTimestamp: task.scheduledDate.timeIntervalSince1970,
            instructions: task.notes ?? "Remember to bring leash, water, and rewards."
        )
        content.userInfo = payload.toDictionary()

        let fireDate = triggerDate ?? task.scheduledDate
        let timeInterval = max(1.0, fireDate.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    public func scheduleTestReminder(dogName: String = "Archie", delaySeconds: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = "Feeding Time for \(dogName)"
        content.subtitle = "Evening Dinner & Hydration"
        content.body = "1 scoop dry kibble + fresh water bowl check. Archie has had a great day!"
        content.sound = .default
        content.categoryIdentifier = Self.categoryIdentifier

        let payload = CareNotificationPayload(
            taskId: UUID().uuidString,
            dogId: UUID().uuidString,
            dogName: dogName,
            title: "Evening Dinner & Hydration",
            category: "Feeding",
            priority: "High",
            scheduledTimestamp: Date().addingTimeInterval(delaySeconds).timeIntervalSince1970,
            instructions: "1 scoop dry kibble + fresh water bowl check. Archie has had a great day!"
        )
        content.userInfo = payload.toDictionary()

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delaySeconds, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification_\(UUID().uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule test reminder: \(error)")
            }
        }
    }

    public func cancelReminder(taskId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId.uuidString])
    }
}
