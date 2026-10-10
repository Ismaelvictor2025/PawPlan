//
//  CareLocationManager.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Location Sharing.
//

import Foundation
import CoreLocation
import MapKit
import Combine

@MainActor
public final class CareLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = CareLocationManager()

    private let locationManager = CLLocationManager()

    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var currentLocation: CLLocationCoordinate2D?
    @Published public var isSharingActive: Bool = false
    @Published public var activeSessionId: UUID?
    @Published public var permissionDeniedReason: String?

    // Ephemeral in-memory route breadcrumbs (never persisted permanently to disk)
    @Published public var sessionRoute: [CLLocationCoordinate2D] = []

    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10.0 // updates every 10 meters
        self.authorizationStatus = locationManager.authorizationStatus
    }

    /// Requests When-In-Use Location permission with explicit user context
    public func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Starts voluntary session-limited location sharing for an active sitting session
    public func startSharing(sessionId: UUID) {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            if authorizationStatus == .denied || authorizationStatus == .restricted {
                permissionDeniedReason = "Location access is denied. Please enable 'While Using the App' in iOS Settings > PawPlan > Location to share your walk location."
            } else {
                requestPermission()
            }
            return
        }

        permissionDeniedReason = nil
        activeSessionId = sessionId
        isSharingActive = true
        sessionRoute.removeAll()
        locationManager.startUpdatingLocation()
    }

    /// Stops location sharing immediately and clears ephemeral coordinates
    public func stopSharing() {
        locationManager.stopUpdatingLocation()
        isSharingActive = false
        activeSessionId = nil
        currentLocation = nil
        sessionRoute.removeAll()
    }

    /// Automatically terminates location sharing when a session completes or cancels
    public func handleSessionEnded(sessionId: UUID) {
        if activeSessionId == sessionId {
            stopSharing()
        }
    }

    // MARK: - CLLocationManagerDelegate

    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .denied || status == .restricted {
                self.isSharingActive = false
                self.permissionDeniedReason = "Location permission was denied. Sitter location sharing is disabled."
                self.stopSharing()
            } else if (status == .authorizedWhenInUse || status == .authorizedAlways) && self.activeSessionId != nil {
                self.permissionDeniedReason = nil
                self.locationManager.startUpdatingLocation()
            }
        }
    }

    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        let coord = latest.coordinate

        Task { @MainActor in
            guard self.isSharingActive else { return }
            self.currentLocation = coord
            self.sessionRoute.append(coord)
        }
    }

    public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("[CareLocationManager] Location error: \(error.localizedDescription)")
        }
    }
}
