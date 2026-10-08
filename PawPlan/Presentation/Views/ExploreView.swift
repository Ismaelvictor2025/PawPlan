//
//  ExploreView.swift
//  PawPlan
//
//  Created for PawPlan Sydney Discovery Guide.
//

import SwiftUI
import MapKit

public struct ExploreView: View {
    @ObservedObject var container: AppDependencyContainer

    @State private var selectedCategory: SydneyPlaceCategory? = nil
    @State private var searchText: String = ""
    @State private var isMapView: Bool = true
    @State private var selectedPlace: SydneyPetPlace? = nil

    // Sydney Map Region (Centred over Greater Sydney Harbour / Inner South)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.875, longitude: 151.22),
        span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
    )

    public init(container: AppDependencyContainer) {
        self.container = container
    }

    private var places: [SydneyPetPlace] {
        container.getSydneyPetPlacesUseCase.execute(category: selectedCategory, query: searchText)
    }

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search & Category Filters
                    VStack(spacing: 10) {
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(PawPlanTheme.textSecondary)
                                TextField("Search Sydney parks, beaches, 24/7 vets...", text: $searchText)
                                    .foregroundColor(.white)
                                if !searchText.isEmpty {
                                    Button { searchText = "" } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(PawPlanTheme.textSecondary)
                                    }
                                }
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(PawPlanTheme.cardBackgroundElevated)
                            )

                            // Toggle Map / List
                            Button {
                                withAnimation { isMapView.toggle() }
                            } label: {
                                Image(systemName: isMapView ? "list.bullet" : "map.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(PawPlanTheme.electricTurquoise)
                                    .frame(width: 42, height: 42)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(PawPlanTheme.cardBackgroundElevated)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Category Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(title: "All Places", isSelected: selectedCategory == nil) {
                                    selectedCategory = nil
                                }
                                ForEach(SydneyPlaceCategory.allCases, id: \.self) { cat in
                                    FilterChip(title: cat.rawValue, icon: cat.iconName, isSelected: selectedCategory == cat) {
                                        selectedCategory = cat
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 10)
                    .background(PawPlanTheme.background)

                    if isMapView {
                        // MapKit View with interactive pins
                        ZStack(alignment: .bottom) {
                            Map(coordinateRegion: $region, annotationItems: places) { place in
                                MapAnnotation(coordinate: place.coordinate) {
                                    Button {
                                        selectedPlace = place
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: place.category.colorHex))
                                                .frame(width: 32, height: 32)
                                                .shadow(radius: 4)

                                            Image(systemName: place.category.iconName)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            .ignoresSafeArea(edges: .bottom)

                            // Selected place preview card
                            if let place = selectedPlace {
                                SydneyPlaceCard(place: place, showClose: true) {
                                    selectedPlace = nil
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    } else {
                        // List View
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(places) { place in
                                    SydneyPlaceCard(place: place, showClose: false) {
                                        selectedPlace = place
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                    }
                }
            }
            .navigationTitle("Sydney Pet Guide")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedPlace) { place in
                SydneyPlaceDetailSheet(place: place)
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon = icon {
                    Image(systemName: icon).font(.system(size: 11, weight: .bold))
                }
                Text(title).font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSelected ? Color(hex: "#080F20") : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(isSelected ? PawPlanTheme.electricTurquoise : PawPlanTheme.cardBackgroundElevated))
            .overlay(Capsule().stroke(isSelected ? Color.clear : PawPlanTheme.cardBorder, lineWidth: 1))
        }
    }
}

private struct SydneyPlaceCard: View {
    let place: SydneyPetPlace
    var showClose: Bool = false
    let onCloseOrTap: () -> Void

    var body: some View {
        Button(action: onCloseOrTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: place.category.colorHex).opacity(0.25))
                            .frame(width: 40, height: 40)
                        Image(systemName: place.category.iconName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: place.category.colorHex))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(place.name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text("\(place.suburb) • \(place.council)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(PawPlanTheme.textSecondary)
                    }

                    Spacer()

                    if showClose {
                        Button(action: onCloseOrTap) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(PawPlanTheme.textSecondary)
                        }
                    }
                }

                Text(place.description)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(PawPlanTheme.textSecondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    if place.isOffLeash {
                        BadgePill(title: "Off-Leash", color: PawPlanTheme.electricTurquoise)
                    }
                    if place.waterAvailable {
                        BadgePill(title: "Water Bowl", color: PawPlanTheme.lightCyan)
                    }
                    if place.isFenced {
                        BadgePill(title: "Fenced", color: PawPlanTheme.medication)
                    }
                    Spacer()
                    Text("Details ›")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(PawPlanTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(PawPlanTheme.cardBorder, lineWidth: 1.2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct BadgePill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.15)))
    }
}

public struct SydneyPlaceDetailSheet: View {
    let place: SydneyPetPlace
    @Environment(\.dismiss) var dismiss

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title header
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(place.category.rawValue.uppercased())
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(hex: place.category.colorHex))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color(hex: place.category.colorHex).opacity(0.15)))
                                Spacer()
                            }

                            Text(place.name)
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(.white)

                            Text("\(place.address)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About This Location")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text(place.description)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16).fill(PawPlanTheme.cardBackgroundElevated))
                        .padding(.horizontal, 20)

                        // Hours & Off-Leash Rules
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Council & Operational Rules")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text(place.hoursOrNotes)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                                .lineSpacing(3)
                            Text("Authority: \(place.council)")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(PawPlanTheme.electricTurquoise)
                                .padding(.top, 4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16).fill(PawPlanTheme.cardBackgroundElevated))
                        .padding(.horizontal, 20)

                        // Actions (Phone, Directions, Council Link)
                        VStack(spacing: 12) {
                            if let phone = place.contactPhone {
                                Link(destination: URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))")!) {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                        Text("Call \(phone)")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                    }
                                    .foregroundColor(Color(hex: "#080F20"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(RoundedRectangle(cornerRadius: 14).fill(PawPlanTheme.turquoiseGradient))
                                }
                            }

                            if let sourceURL = place.officialSourceURL, let url = URL(string: sourceURL) {
                                Link(destination: url) {
                                    HStack {
                                        Image(systemName: "safari.fill")
                                        Text("View Council Website")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(RoundedRectangle(cornerRadius: 14).fill(PawPlanTheme.cardBackgroundElevated))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
        }
    }
}
