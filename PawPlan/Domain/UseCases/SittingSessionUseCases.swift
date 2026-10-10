//
//  SittingSessionUseCases.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Dog Sitting Mode.
//

import Foundation

public struct SittingSessionProgressReport: Sendable, Hashable {
    public let totalCoreActivities: Int
    public let completedCoreActivities: Int
    public let progressRate: Double // 0.0 to 1.0
    public let hasFed: Bool
    public let hasWalked: Bool
    public let hasGivenMedication: Bool
    public let hasRefreshedWater: Bool
    public let hasGroomed: Bool

    public var isComplete: Bool {
        return completedCoreActivities >= totalCoreActivities && totalCoreActivities > 0
    }
}

public struct ManageSittingSessionUseCase: Sendable {
    private let repository: SittingSessionRepositoryProtocol

    public init(repository: SittingSessionRepositoryProtocol) {
        self.repository = repository
    }

    public func executeFetchSessions(for dogId: UUID?) throws -> [SittingSession] {
        try repository.fetchSessions(for: dogId)
    }

    public func executeFetchSession(id: UUID) throws -> SittingSession {
        guard let session = try repository.fetchSession(id: id) else {
            throw SittingSessionError.sessionNotFound(id)
        }
        return session
    }

    public func executeCreateSession(_ session: SittingSession) throws {
        if session.sitterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SittingSessionError.emptySitterName
        }
        if session.endDate <= session.startDate {
            throw SittingSessionError.invalidDateRange
        }
        try repository.saveSession(session)
    }

    public func executeStartSession(id: UUID) throws -> SittingSession {
        var session = try executeFetchSession(id: id)
        if session.status == .completed {
            throw SittingSessionError.sessionAlreadyCompleted
        }
        session.status = .active
        try repository.saveSession(session)
        return session
    }

    public func executeCompleteSession(id: UUID) throws -> SittingSession {
        var session = try executeFetchSession(id: id)
        session.status = .completed
        session.isLocationSharingActive = false // Automatically terminate location sharing on completion
        try repository.saveSession(session)
        return session
    }

    public func executeUpdateLocationSharing(id: UUID, isSharing: Bool) throws -> SittingSession {
        var session = try executeFetchSession(id: id)
        if session.status != .active && isSharing {
            throw SittingSessionError.sessionNotActive
        }
        session.isLocationSharingActive = isSharing
        try repository.saveSession(session)
        return session
    }

    public func executeDeleteSession(id: UUID) throws {
        try repository.deleteSession(id: id)
    }
}

public struct RecordSittingActivityUseCase: Sendable {
    private let repository: SittingSessionRepositoryProtocol

    public init(repository: SittingSessionRepositoryProtocol) {
        self.repository = repository
    }

    public func executeFetchActivities(for sessionId: UUID) throws -> [SittingActivityLog] {
        try repository.fetchActivities(for: sessionId)
    }

    public func executeRecordActivity(
        sessionId: UUID,
        dogId: UUID,
        type: SittingActivityType,
        title: String,
        notes: String? = nil,
        loggedBy: String,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) throws -> SittingActivityLog {
        guard let session = try repository.fetchSession(id: sessionId) else {
            throw SittingSessionError.sessionNotFound(sessionId)
        }
        if session.status == .completed {
            throw SittingSessionError.sessionAlreadyCompleted
        }
        if session.status != .active {
            throw SittingSessionError.sessionNotActive
        }

        let activity = SittingActivityLog(
            sessionId: sessionId,
            dogId: dogId,
            activityType: type,
            title: title,
            notes: notes,
            timestamp: Date(),
            loggedBy: loggedBy,
            locationLatitude: latitude,
            locationLongitude: longitude
        )

        try repository.recordActivity(activity)
        return activity
    }

    public func executeCalculateProgress(for sessionId: UUID) throws -> SittingSessionProgressReport {
        let activities = try repository.fetchActivities(for: sessionId)

        let hasFed = activities.contains { $0.activityType == .feeding }
        let hasWalked = activities.contains { $0.activityType == .walk }
        let hasGivenMedication = activities.contains { $0.activityType == .medication }
        let hasRefreshedWater = activities.contains { $0.activityType == .water }
        let hasGroomed = activities.contains { $0.activityType == .grooming }

        // 5 core pet sitting pillars
        let total = 5
        var completed = 0
        if hasFed { completed += 1 }
        if hasWalked { completed += 1 }
        if hasGivenMedication { completed += 1 }
        if hasRefreshedWater { completed += 1 }
        if hasGroomed { completed += 1 }

        let rate = Double(completed) / Double(total)
        return SittingSessionProgressReport(
            totalCoreActivities: total,
            completedCoreActivities: completed,
            progressRate: rate,
            hasFed: hasFed,
            hasWalked: hasWalked,
            hasGivenMedication: hasGivenMedication,
            hasRefreshedWater: hasRefreshedWater,
            hasGroomed: hasGroomed
        )
    }
}
