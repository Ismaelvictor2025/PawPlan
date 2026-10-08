//
//  WidgetSnapshotStore.swift
//  PawPlan
//
//  Created for PawPlan WidgetKit and App Group persistence.
//

import Foundation

public final class WidgetSnapshotStore: @unchecked Sendable {
    public static let shared = WidgetSnapshotStore()

    public static let appGroupIdentifier = "group.com.vicky.PawPlan"
    private static let snapshotKey = "PawPlan_WidgetCareSnapshot_Key"

    private let userDefaults: UserDefaults

    public init(suiteName: String? = appGroupIdentifier) {
        if let suiteName = suiteName, let groupDefaults = UserDefaults(suiteName: suiteName) {
            self.userDefaults = groupDefaults
        } else {
            self.userDefaults = UserDefaults.standard
        }
    }

    public func save(snapshot: WidgetCareSnapshot) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            userDefaults.set(data, forKey: Self.snapshotKey)
            userDefaults.synchronize()
        } catch {
            print("Failed to save WidgetCareSnapshot: \(error)")
        }
    }

    public func load() -> WidgetCareSnapshot {
        guard let data = userDefaults.data(forKey: Self.snapshotKey) else {
            return .fallback
        }
        do {
            return try JSONDecoder().decode(WidgetCareSnapshot.self, from: data)
        } catch {
            print("Failed to decode WidgetCareSnapshot: \(error)")
            return .fallback
        }
    }
}
