//
//  CareLocationView.swift
//  PawPlan
//
//  Created for PawPlan Care Circle Location & AirTag Compatibility.
//

import SwiftUI
import MapKit
import CoreLocation

public struct CareLocationView: View {
    @ObservedObject var container: AppDependencyContainer
    @ObservedObject private var locationManager = CareLocationManager.shared

    @State private var showAirTagGuideDetails: Bool = false
    @State private var activeSession: SittingSession?

    public init(container: AppDependencyContainer) {
        self.container = container
    }

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(PawPlanTheme.electricTurquoise)
                            Text("Sitter Location & Apple Find My")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("PawPlan supports voluntary walk location sharing by sitters, alongside Apple's native Find My AirTag sharing integration.")
                            .font(.system(size: 13))
                            .foregroundColor(PawPlanTheme.subtext)
                    }
                    .padding(16)
                    .background(PawPlanTheme.cardSurface)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // 1. Sitter Walk Location Tracker
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("LIVE WALK LOCATION (OPTIONAL)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(PawPlanTheme.lightCyan)
                            Spacer()
                            if locationManager.isSharingActive {
                                StatusBadgeChip(
                                    icon: "record.circle",
                                    label: "Sharing Active",
                                    color: PawPlanTheme.positiveGreen
                                )
                            }
                        }

                        Text("During active sitting sessions, sitters can voluntarily share their live location during outdoor walks so owners know their dog is safe.")
                            .font(.system(size: 12))
                            .foregroundColor(PawPlanTheme.subtext)

                        // Permission Status
                        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "location.slash.fill")
                                    .foregroundColor(PawPlanTheme.amber)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Location Access Disabled")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(PawPlanTheme.amber)
                                    Text("To enable sitter walk sharing, open iOS Settings > Privacy & Security > Location Services > PawPlan and select 'While Using the App'.")
                                        .font(.system(size: 11))
                                        .foregroundColor(PawPlanTheme.subtext)

                                    Button(action: {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Text("Open iOS Settings")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(PawPlanTheme.electricTurquoise)
                                            .underline()
                                    }
                                    .padding(.top, 2)
                                }
                            }
                            .padding(12)
                            .background(PawPlanTheme.amber.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Map View
                        if let coord = locationManager.currentLocation {
                            Map(initialPosition: .region(MKCoordinateRegion(
                                center: coord,
                                span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                            ))) {
                                Marker("Current Walk Position", coordinate: coord)
                                    .tint(PawPlanTheme.electricTurquoise)
                            }
                            .frame(height: 220)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                            )

                            HStack {
                                Text("Coordinates: \(String(format: "%.4f", coord.latitude)), \(String(format: "%.4f", coord.longitude))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(PawPlanTheme.subtext)
                                Spacer()
                                Button("Stop Sharing") {
                                    locationManager.stopSharing()
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(PawPlanTheme.vetHealth)
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "map")
                                    .font(.system(size: 32))
                                    .foregroundColor(PawPlanTheme.subtext)

                                Text("No Active Walk Location Shared")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)

                                Text("Location sharing is session-bound. Start an active dog sitting session to turn on live walk tracking.")
                                    .font(.system(size: 11))
                                    .foregroundColor(PawPlanTheme.subtext)
                                    .multilineTextAlignment(.center)

                                if locationManager.authorizationStatus == .notDetermined {
                                    Button("Request Location Permission") {
                                        locationManager.requestPermission()
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(PawPlanTheme.midnightNavy)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(PawPlanTheme.turquoiseGradient)
                                    .cornerRadius(16)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .background(PawPlanTheme.midnightNavy.opacity(0.5))
                            .cornerRadius(16)
                        }

                        // Ephemeral privacy note
                        HStack(spacing: 6) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 10))
                                .foregroundColor(PawPlanTheme.positiveGreen)
                            Text("Zero Location History: Coordinates are held only in temporary memory and purged immediately when sharing ends.")
                                .font(.system(size: 10))
                                .foregroundColor(PawPlanTheme.subtext)
                        }
                    }
                    .padding(18)
                    .background(PawPlanTheme.cardSurface)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // 2. AirTag & Find My Compatibility Guide
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundColor(PawPlanTheme.amber)
                            Text("APPLE AIRTAG & FIND MY INTEGRATION")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(PawPlanTheme.amber)
                        }

                        Text("Important Architecture & Technical Disclosure:")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)

                        Text(AirTagCompatibilityInfo.technicalSummary)
                            .font(.system(size: 12))
                            .foregroundColor(PawPlanTheme.subtext)

                        Text(AirTagCompatibilityInfo.appleSecurityRationale)
                            .font(.system(size: 11))
                            .foregroundColor(PawPlanTheme.subtext)

                        Divider().background(PawPlanTheme.cardBorder)

                        Text("Official Apple-Supported Sitter Sharing Workflow:")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(PawPlanTheme.electricTurquoise)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(AirTagCompatibilityInfo.supportedWorkflowSteps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1).")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(PawPlanTheme.electricTurquoise)
                                    Text(step)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                }
                            }
                        }

                        // Link out to Apple Find My Support
                        Button(action: {
                            if let url = URL(string: "https://support.apple.com/en-au/118258") { // Apple Share Item Location support
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.right.square")
                                Text("Apple Support: Share Item Location Guide")
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(PawPlanTheme.lightCyan)
                        }
                        .padding(.top, 4)
                    }
                    .padding(18)
                    .background(PawPlanTheme.cardSurface)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .padding(.top, 14)
            }
        }
        .navigationTitle("Location & AirTags")
        .navigationBarTitleDisplayMode(.inline)
    }
}
