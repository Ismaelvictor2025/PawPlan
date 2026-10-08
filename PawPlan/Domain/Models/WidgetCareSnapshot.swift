//
//  WidgetCareSnapshot.swift
//  PawPlan
//
//  Created for PawPlan WidgetKit integration.
//

import Foundation

public struct WidgetCareSnapshot: Codable, Sendable {
    public let dogName: String
    public let breed: String
    public let nextTaskTitle: String
    public let nextTaskCategory: String
    public let nextTaskTime: Date
    public let timeRemainingDescription: String
    public let completedTodayCount: Int
    public let totalTodayCount: Int
    public let adherenceScore: Double
    public let lastUpdated: Date

    public init(
        dogName: String = "Buddy",
        breed: String = "Golden Retriever",
        nextTaskTitle: String = "Morning River Walk",
        nextTaskCategory: String = "Walk",
        nextTaskTime: Date = Date().addingTimeInterval(1800),
        timeRemainingDescription: String = "In 30m",
        completedTodayCount: Int = 2,
        totalTodayCount: Int = 4,
        adherenceScore: Double = 0.75,
        lastUpdated: Date = Date()
    ) {
        self.dogName = dogName
        self.breed = breed
        self.nextTaskTitle = nextTaskTitle
        self.nextTaskCategory = nextTaskCategory
        self.nextTaskTime = nextTaskTime
        self.timeRemainingDescription = timeRemainingDescription
        self.completedTodayCount = completedTodayCount
        self.totalTodayCount = totalTodayCount
        self.adherenceScore = adherenceScore
        self.lastUpdated = lastUpdated
    }

    public static var fallback: WidgetCareSnapshot {
        WidgetCareSnapshot()
    }
}

public struct CareNotificationPayload: Codable, Sendable {
    public let taskId: String
    public let dogId: String
    public let dogName: String
    public let title: String
    public let category: String
    public let priority: String
    public let scheduledTimestamp: TimeInterval
    public let instructions: String

    public init(
        taskId: String,
        dogId: String,
        dogName: String,
        title: String,
        category: String,
        priority: String,
        scheduledTimestamp: TimeInterval,
        instructions: String
    ) {
        self.taskId = taskId
        self.dogId = dogId
        self.dogName = dogName
        self.title = title
        self.category = category
        self.priority = priority
        self.scheduledTimestamp = scheduledTimestamp
        self.instructions = instructions
    }

    public func toDictionary() -> [String: Any] {
        return [
            "taskId": taskId,
            "dogId": dogId,
            "dogName": dogName,
            "title": title,
            "category": category,
            "priority": priority,
            "scheduledTimestamp": scheduledTimestamp,
            "instructions": instructions
        ]
    }

    public static func from(dictionary: [AnyHashable: Any]) -> CareNotificationPayload? {
        guard let taskId = dictionary["taskId"] as? String,
              let dogId = dictionary["dogId"] as? String,
              let dogName = dictionary["dogName"] as? String,
              let title = dictionary["title"] as? String,
              let category = dictionary["category"] as? String,
              let priority = dictionary["priority"] as? String,
              let scheduledTimestamp = dictionary["scheduledTimestamp"] as? TimeInterval,
              let instructions = dictionary["instructions"] as? String else {
            return nil
        }
        return CareNotificationPayload(
            taskId: taskId,
            dogId: dogId,
            dogName: dogName,
            title: title,
            category: category,
            priority: priority,
            scheduledTimestamp: scheduledTimestamp,
            instructions: instructions
        )
    }
}
