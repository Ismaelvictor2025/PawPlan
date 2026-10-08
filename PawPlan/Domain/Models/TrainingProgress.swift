//
//  TrainingProgress.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation

public struct TrainingMilestone: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public let title: String
    public let summary: String
    public let tip: String

    public init(id: String, title: String, summary: String, tip: String) {
        self.id = id
        self.title = title
        self.summary = summary
        self.tip = tip
    }
}

public struct TrainingModule: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public let title: String
    public let category: String
    public let summary: String
    public let iconName: String
    public let colorHex: String
    public let milestones: [TrainingMilestone]

    public init(
        id: String,
        title: String,
        category: String,
        summary: String,
        iconName: String,
        colorHex: String,
        milestones: [TrainingMilestone]
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.summary = summary
        self.iconName = iconName
        self.colorHex = colorHex
        self.milestones = milestones
    }
}

public struct TrainingProgress: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var dogId: UUID
    public var moduleKey: String
    public var milestoneKey: String
    public var title: String
    public var isCompleted: Bool
    public var completedAt: Date?
    public var rating: Int
    public var notes: String?

    public init(
        id: UUID = UUID(),
        dogId: UUID,
        moduleKey: String,
        milestoneKey: String,
        title: String,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        rating: Int = 0,
        notes: String? = nil
    ) {
        self.id = id
        self.dogId = dogId
        self.moduleKey = moduleKey
        self.milestoneKey = milestoneKey
        self.title = title
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.rating = rating
        self.notes = notes
    }
}
