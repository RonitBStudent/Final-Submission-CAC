//
//  MapView.swift
//  Congressional App Challenge (DR)
//
//  Created by GitHub Copilot on 10/9/25.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - MKMapItem Extension to make it Identifiable
extension MKMapItem: Identifiable {
    public var id: String {
        return "\(placemark.coordinate.latitude)-\(placemark.coordinate.longitude)-\(name ?? "unknown")"
    }
}

struct MapView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var searchText = ""
    @State private var mapItems: [MKMapItem] = []
    @State private var showingList = false
    @State private var selectedMapItem: MKMapItem?
    @State private var showingDirections = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                themeManager.selectedEyeColor.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section
                    headerSection
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Search section
                    searchSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                    
                    // Map section
                    mapSection
                    
                    // Quick action buttons
                    quickActionsSection
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            requestLocationPermission()
            searchNearbyEyeCare()
        }
        .sheet(isPresented: $showingList) {
            EyeCareListView(
                mapItems: mapItems,
                onItemSelected: { item in
                    selectedMapItem = item
                    showingList = false
                    showingDirections = true
                },
                themeColor: themeManager.selectedEyeColor.primaryColor
            )
        }
        .sheet(isPresented: $showingDirections) {
            if let selectedItem = selectedMapItem {
                DirectionsView(
                    destination: selectedItem,
                    themeColor: themeManager.selectedEyeColor.primaryColor
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: themeManager.selectedEyeColor.gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: themeManager.selectedEyeColor.primaryColor.opacity(0.3), radius: 15, x: 0, y: 8)
                
                Image(systemName: "location.fill")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Find Eye Care Nearby")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: themeManager.selectedEyeColor.gradientColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Locate ophthalmologists and eye care professionals in your area")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.selectedEyeColor.primaryColor)
                
                TextField("Search for eye care specialists...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        searchForEyeCare()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchNearbyEyeCare()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            
            // Quick search buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickSearchButton(title: "Ophthalmologists", icon: "eye.fill") {
                        searchForSpecific("ophthalmologists")
                    }
                    QuickSearchButton(title: "Optometrists", icon: "eyeglasses") {
                        searchForSpecific("optometrists")
                    }
                    QuickSearchButton(title: "Retina Specialists", icon: "circle.grid.hex.fill") {
                        searchForSpecific("retina specialists")
                    }
                    QuickSearchButton(title: "Eye Surgery", icon: "cross.case.fill") {
                        searchForSpecific("eye surgery centers")
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Map Section
    private var mapSection: some View {
        ZStack {
            // Simplified Map with better annotation handling
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: mapItems) { item in
                MapPin(coordinate: item.placemark.coordinate, tint: themeManager.selectedEyeColor.primaryColor)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .onTapGesture { location in
                // Handle map taps to find nearby annotations
                let mapPoint = location
                findNearestAnnotation(at: mapPoint)
            }
            
            // Simplified current location button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: centerOnUserLocation) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(themeManager.selectedEyeColor.primaryColor)
                                    .shadow(radius: 6)
                            )
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .frame(height: 300)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ActionCard(
                    title: "View List",
                    subtitle: "\(mapItems.count) locations",
                    icon: "list.bullet",
                    color: themeManager.selectedEyeColor.primaryColor
                ) {
                    showingList = true
                }
                
                ActionCard(
                    title: "Refresh",
                    subtitle: "Update results",
                    icon: "arrow.clockwise",
                    color: .blue
                ) {
                    searchNearbyEyeCare()
                }
            }
            
            HStack(spacing: 16) {
                ActionCard(
                    title: "Emergency",
                    subtitle: "Find nearest ER",
                    icon: "cross.circle.fill",
                    color: .red
                ) {
                    searchForEmergencyEyeCare()
                }
                
                ActionCard(
                    title: "Apple Maps",
                    subtitle: "Open full app",
                    icon: "map.fill",
                    color: .green
                ) {
                    openAppleMaps()
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func requestLocationPermission() {
        locationManager.requestLocationPermission()
    }
    
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            withAnimation {
                region.center = location.coordinate
            }
        }
    }
    
    private func searchNearbyEyeCare() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "eye doctor ophthalmologist optometrist"
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self.mapItems = response.mapItems
                }
            }
        }
    }
    
    private func searchForEyeCare() {
        guard !searchText.isEmpty else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText + " eye care"
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self.mapItems = response.mapItems
                }
            }
        }
    }
    
    private func searchForSpecific(_ query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self.mapItems = response.mapItems
                }
            }
        }
    }
    
    private func searchForEmergencyEyeCare() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "emergency room hospital eye emergency"
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self.mapItems = response.mapItems
                }
            }
        }
    }
    
    private func openAppleMaps() {
        let coordinate = region.center
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = "Eye Care Search"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue
        ])
    }
    
    private func findNearestAnnotation(at point: CGPoint) {
        // For simplicity, show the list view when user taps the map
        // This avoids the complexity of converting screen coordinates to map coordinates
        if !mapItems.isEmpty {
            showingList = true
        }
    }
}

// MARK: - Supporting Views

struct QuickSearchButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue)
                    .shadow(radius: 4)
            )
        }
    }
}

struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
            )
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            manager.startUpdatingLocation()
        case .denied, .restricted:
            isAuthorized = false
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}

// MARK: - Eye Care List View
struct EyeCareListView: View {
    let mapItems: [MKMapItem]
    let onItemSelected: (MKMapItem) -> Void
    let themeColor: Color
    
    var body: some View {
        NavigationView {
            List(mapItems, id: \.self) { item in
                EyeCareListRow(mapItem: item, themeColor: themeColor) {
                    onItemSelected(item)
                }
            }
            .navigationTitle("Eye Care Locations")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EyeCareListRow: View {
    let mapItem: MKMapItem
    let themeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "cross.circle.fill")
                    .font(.title2)
                    .foregroundColor(themeColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mapItem.name ?? "Eye Care Center")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let address = mapItem.placemark.title {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    if let phone = mapItem.phoneNumber {
                        Text(phone)
                            .font(.caption)
                            .foregroundColor(themeColor)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Directions View
struct DirectionsView: View {
    let destination: MKMapItem
    let themeColor: Color
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Destination info
                VStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(themeColor)
                    
                    Text(destination.name ?? "Eye Care Center")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let address = destination.placemark.title {
                        Text(address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        destination.openInMaps(launchOptions: [
                            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                        ])
                    }) {
                        HStack {
                            Image(systemName: "car.fill")
                            Text("Get Driving Directions")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        destination.openInMaps(launchOptions: [
                            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
                        ])
                    }) {
                        HStack {
                            Image(systemName: "figure.walk")
                            Text("Get Walking Directions")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    if let phone = destination.phoneNumber {
                        Button(action: {
                            if let url = URL(string: "tel:\(phone)") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Call \(phone)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Directions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MapView()
        .environmentObject(ThemeManager())
}
