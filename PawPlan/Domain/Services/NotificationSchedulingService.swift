//
//  NotificationSchedulingService.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture & Smart Care Notifications.
//

import Foundation
import UserNotifications

public enum SmartReminderCategory: String, Codable, CaseIterable, Sendable {
    case feeding = "Feeding"
    case walk = "Walk"
    case medication = "Medication"
    case bathing = "Bathing"
    case brushing = "Brushing"
    case parasitePrevention = "Flea & Tick Prevention"
    case vaccination = "Vaccination"
    case vetAppointment = "Vet Appointment"
    case dogSitting = "Dog Sitting Activity"

    public var notificationCategoryIdentifier: String {
        return "PAWPLAN_\(self.rawValue.uppercased().replacingOccurrences(of: " ", with: "_"))"
    }

    public var defaultBodyMessage: String {
        switch self {
        case .feeding:
            return "Time for mealtime & fresh water bowl check."
        case .walk:
            return "Time for outdoor exercise, leash walk & sniff safari."
        case .medication:
            return "Scheduled medication dose required. Check administration notes."
        case .bathing:
            return "Warm bath & gentle coat rinse scheduled for today."
        case .brushing:
            return "Quick brushing session to prevent matting and remove debris."
        case .parasitePrevention:
            return "Monthly tick, flea, or heartworm preventative treatment due."
        case .vaccination:
            return "Vaccination appointment or annual booster due soon."
        case .vetAppointment:
            return "Upcoming veterinary clinic consultation scheduled."
        case .dogSitting:
            return "Dog sitting care activity or status update check."
        }
    }
}

public struct SmartReminderRequest: Sendable {
    public let id: String
    public let dogId: UUID
    public let dogName: String
    public let category: SmartReminderCategory
    public let title: String
    public let notes: String?
    public let scheduledDate: Date
    public let recurrenceRule: CareRecurrenceRule

    public init(
        id: String = UUID().uuidString,
        dogId: UUID,
        dogName: String,
        category: SmartReminderCategory,
        title: String,
        notes: String? = nil,
        scheduledDate: Date,
        recurrenceRule: CareRecurrenceRule = .none
    ) {
        self.id = id
        self.dogId = dogId
        self.dogName = dogName
        self.category = category
        self.title = title
        self.notes = notes
        self.scheduledDate = scheduledDate
        self.recurrenceRule = recurrenceRule
    }

    public var deterministicNotificationId: String {
        return "pawplan_smart_\(category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))_\(id)"
    }
}

public final class NotificationSchedulingService: @unchecked Sendable {
    public static let shared = NotificationSchedulingService()

    public static let defaultCategoryIdentifier = "PAWPLAN_CARE_REMINDER"

    public init() {
        configureNotificationCategories()
    }

    // MARK: - Permissions & Status

    public func requestAuthorization() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("[NotificationSchedulingService] Authorization error: \(error)")
            return false
        }
    }

    public func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
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

        var categories: [UNNotificationCategory] = []

        // Default category
        let defaultCategory = UNNotificationCategory(
            identifier: Self.defaultCategoryIdentifier,
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        categories.append(defaultCategory)

        // Specialized categories
        for cat in SmartReminderCategory.allCases {
            let catObj = UNNotificationCategory(
                identifier: cat.notificationCategoryIdentifier,
                actions: [completeAction, snoozeAction],
                intentIdentifiers: [],
                options: [.customDismissAction]
            )
            categories.append(catObj)
        }

        UNUserNotificationCenter.current().setNotificationCategories(Set(categories))
    }

    // MARK: - Smart Care Reminders Scheduling

    /// Schedules a smart care reminder with deterministic duplicate prevention
    public func scheduleSmartReminder(_ request: SmartReminderRequest) {
        let notifId = request.deterministicNotificationId

        // 1. Prevent duplicate notifications: remove existing request with this ID first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifId])

        // 2. Prepare content
        let content = UNMutableNotificationContent()
        content.title = "\(request.category.rawValue) Time for \(request.dogName)"
        content.subtitle = request.title
        content.body = request.notes ?? request.category.defaultBodyMessage
        content.sound = .default
        content.categoryIdentifier = request.category.notificationCategoryIdentifier

        content.userInfo = [
            "dogId": request.dogId.uuidString,
            "dogName": request.dogName,
            "category": request.category.rawValue,
            "title": request.title,
            "scheduledTimestamp": request.scheduledDate.timeIntervalSince1970
        ]

        // 3. Calendar & Recurrence Trigger
        let calendar = Calendar.current
        let trigger: UNNotificationTrigger

        switch request.recurrenceRule {
        case .none:
            let timeInterval = max(1.0, request.scheduledDate.timeIntervalSinceNow)
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        case .daily:
            let components = calendar.dateComponents([.hour, .minute], from: request.scheduledDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        case .weekdays:
            // Schedule recurring for weekday hour/min
            let components = calendar.dateComponents([.hour, .minute], from: request.scheduledDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        case .weekends:
            let components = calendar.dateComponents([.hour, .minute], from: request.scheduledDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        case .weekly, .biweekly:
            let components = calendar.dateComponents([.weekday, .hour, .minute], from: request.scheduledDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        case .monthly:
            let components = calendar.dateComponents([.day, .hour, .minute], from: request.scheduledDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        }

        let unRequest = UNNotificationRequest(identifier: notifId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(unRequest) { error in
            if let error = error {
                print("[NotificationSchedulingService] Failed to schedule smart reminder \(notifId): \(error)")
            }
        }
    }

    /// Legacy Task reminder support (preserving existing scheduling behavior)
    public func scheduleTaskReminder(task: CareTask, dogName: String, triggerDate: Date? = nil) {
        guard task.reminderEnabled else { return }

        let notifId = "pawplan_task_\(task.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifId])

        let content = UNMutableNotificationContent()
        content.title = "\(task.category.rawValue) Time for \(dogName)"
        content.subtitle = task.title
        content.body = task.notes ?? "Keep up the routine! Happy paws, every day."
        content.sound = .default
        content.categoryIdentifier = Self.defaultCategoryIdentifier

        content.userInfo = [
            "taskId": task.id.uuidString,
            "dogId": task.dogId.uuidString,
            "dogName": dogName,
            "title": task.title,
            "category": task.category.rawValue,
            "scheduledTimestamp": task.scheduledDate.timeIntervalSince1970
        ]

        let fireDate = triggerDate ?? task.scheduledDate
        let timeInterval = max(1.0, fireDate.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: notifId, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationSchedulingService] Failed to schedule task reminder: \(error)")
            }
        }
    }

    // MARK: - Cancellation & Rescheduling

    public func cancelReminder(taskId: UUID) {
        let legacyId = "pawplan_task_\(taskId.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId.uuidString, legacyId])
    }

    public func cancelSmartReminder(id: String, category: SmartReminderCategory) {
        let notifId = "pawplan_smart_\(category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))_\(id)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifId])
    }

    public func cancelAllReminders(for dogId: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let idsToRemove = requests.filter { req in
                (req.content.userInfo["dogId"] as? String) == dogId.uuidString
            }.map(\.identifier)

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }

    public func cancelReminders(category: SmartReminderCategory) {
        let prefix = "pawplan_smart_\(category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))_"
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let idsToRemove = requests.filter { $0.identifier.hasPrefix(prefix) }.map(\.identifier)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }

    public func fetchPendingCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }

    public func scheduleTestReminder(dogName: String = "Archie", delaySeconds: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = "Feeding Time for \(dogName)"
        content.subtitle = "Evening Dinner & Hydration"
        content.body = "1 scoop dry kibble + fresh water bowl check. Archie has had a great day!"
        content.sound = .default
        content.categoryIdentifier = Self.defaultCategoryIdentifier

        content.userInfo = [
            "dogName": dogName,
            "category": "Feeding",
            "title": "Evening Dinner & Hydration"
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delaySeconds, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification_\(UUID().uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule test reminder: \(error)")
            }
        }
    }
}
