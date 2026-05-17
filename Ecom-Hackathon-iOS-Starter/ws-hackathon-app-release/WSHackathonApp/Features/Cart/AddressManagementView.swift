//
//  AddressManagementView.swift
//  WSHackathonApp
//

import SwiftUI
import MapKit
import CoreLocation
import Combine




// MARK: - Address Management View
struct AddressManagementView: View {
    @ObservedObject var addressManager = AddressManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showingAddEditSheet = false
    @State private var addressToEdit: UserAddress? = nil
    
    // Luxury Editorial Theme Colors
    private let ivory = Color(red: 250/255, green: 247/255, blue: 240/255)     // #FAF7F0 Base page background
    private let walnut = Color(red: 42/255, green: 37/255, blue: 32/255)       // #2A2520 Ink - deep primary typography
    private let tan = Color(red: 221/255, green: 211/255, blue: 194/255)       // #DDD3C2 Stone Warm
    private let warmShadow = Color(red: 62/255, green: 40/255, blue: 28/255).opacity(0.04)
    private let zeptoPink = Color(red: 42/255, green: 37/255, blue: 32/255)    // Elegant primary black to match home tab
    
    var body: some View {
        ZStack {
            ivory.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    }
                    
                    Spacer()
                    
                    Text("Saved Addresses")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(walnut)
                    
                    Spacer()
                    
                    // Invisible spacer to balance the back button
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("SELECT DELIVERY LOCATION")
                            .font(.system(size: 10, weight: .bold))
                            .kerning(1.5)
                            .foregroundColor(walnut.opacity(0.5))
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        
                        if addressManager.savedAddresses.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 48))
                                    .foregroundColor(walnut.opacity(0.2))
                                
                                Text("No saved addresses yet")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(walnut)
                                
                                Text("Add an address to start ordering")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(addressManager.savedAddresses) { addr in
                                    let isActive = addressManager.activeAddress?.id == addr.id
                                    
                                    HStack(spacing: 16) {
                                        // Left Indicator Checkmark
                                        Button(action: {
                                            addressManager.selectActiveAddress(addr)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .stroke(isActive ? zeptoPink : tan, lineWidth: isActive ? 2 : 1)
                                                    .frame(width: 20, height: 20)
                                                
                                                if isActive {
                                                    Circle()
                                                        .fill(zeptoPink)
                                                        .frame(width: 10, height: 10)
                                                }
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        // Info Block
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(addr.name)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(walnut)
                                            
                                            Text(addr.fullAddressString)
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        // Actions Row
                                        HStack(spacing: 16) {
                                            Button(action: {
                                                addressToEdit = addr
                                                showingAddEditSheet = true
                                            }) {
                                                Image(systemName: "pencil")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(walnut.opacity(0.6))
                                                    .frame(width: 32, height: 32)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            Button(action: {
                                                addressManager.deleteAddress(addr.id)
                                            }) {
                                                Image(systemName: "trash")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.red.opacity(0.8))
                                                    .frame(width: 32, height: 32)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isActive ? zeptoPink : Color.clear, lineWidth: 1.5)
                                    )
                                    .shadow(color: warmShadow, radius: 6, x: 0, y: 3)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                
                // Add New Address Button (Styled exactly like Home tab native button)
                Button(action: {
                    addressToEdit = nil
                    showingAddEditSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Add New Address")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(walnut)
                    .cornerRadius(25)
                    .shadow(color: walnut.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(SpringPressButtonStyle())
                .padding(16)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddEditSheet) {
            AddressEditMapView(addressToEdit: addressToEdit) {
                showingAddEditSheet = false
            }
        }
    }
}

// MARK: - Interactive Map Selection and Fields View
struct AddressEditMapView: View {
    let addressToEdit: UserAddress?
    let onDismiss: () -> Void
    
    @State private var currentStep: EditStep = .mapSelection
    @StateObject private var locationHelper = MapLocationHelper()
    @StateObject private var gpsManager = GPSLocationManager()
    
    // Form States
    @State private var searchText = ""
    @State private var addressName = "Home"
    @State private var houseNo = ""
    @State private var buildingName = ""
    @State private var areaStreet = ""
    @State private var landmark = ""
    @State private var receiverName = ""
    @State private var receiverPhone = ""
    
    // Color Palette
    private let ivory = Color(red: 250/255, green: 247/255, blue: 240/255)
    private let walnut = Color(red: 26/255, green: 29/255, blue: 40/255) // Dark Charcoal
    private let tan = Color(red: 221/255, green: 211/255, blue: 194/255)
    private let zeptoPink = Color(red: 26/255, green: 29/255, blue: 40/255) // Elegant primary black to match native buttons
    
    enum EditStep {
        case mapSelection
        case detailsForm
    }
    
    var body: some View {
        ZStack {
            ivory.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Switches dynamically based on currentStep)
                headerView
                
                if currentStep == .mapSelection {
                    mapSelectionStepView
                } else {
                    detailsFormStepView
                }
            }
        }
        .onAppear {
            if let addr = addressToEdit {
                addressName = addr.name
                houseNo = addr.houseNo
                buildingName = addr.building
                areaStreet = addr.areaStreet
                landmark = addr.landmark
                receiverName = addr.receiverName ?? ""
                receiverPhone = addr.receiverPhone ?? ""
                
                locationHelper.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: addr.latitude, longitude: addr.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015) // Deep Zoom for footprint clarity!
                )
            } else {
                // Default to Pune, India!
                locationHelper.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 18.5204, longitude: 73.8567),
                    span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015) // Deep Zoom!
                )
                gpsManager.requestLocation()
            }
        }
        .onChange(of: gpsManager.userLocation) { _, newLoc in
            if let loc = newLoc?.coordinate, addressToEdit == nil {
                // Instantly center map on user's live coordinates!
                withAnimation {
                    locationHelper.region = MKCoordinateRegion(
                        center: loc,
                        span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
                    )
                }
            }
        }
        .onChange(of: locationHelper.reverseGeocodedAddressString) { _, newString in
            if areaStreet.isEmpty {
                areaStreet = newString
            }
        }
    }
    
    // Header View with native circle bar buttons
    private var headerView: some View {
        HStack {
            if currentStep == .mapSelection {
                // Circular Cancel Button (matching size 44x44 of existing bar buttons)
                Button(action: { onDismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(walnut)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                }
            } else {
                // Circular Back Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .mapSelection
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(walnut)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                }
            }
            
            Spacer()
            
            Text(currentStep == .mapSelection ? "Select Your Location" : "Add Address Details")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(walnut)
            
            Spacer()
            
            // Invisible placeholder spacer to center title nicely
            Spacer().frame(width: 44)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        locationHelper.searchLocation(query: searchText)
    }
    
    // Full Screen Map Step View (Map starts directly below header)
    private var mapSelectionStepView: some View {
        VStack(spacing: 0) {
            // Interactive Search Bar (Zepto Style)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search for apartment, street name...", text: $searchText, onCommit: {
                    performSearch()
                })
                .font(.system(size: 14))
                .foregroundColor(walnut)
                .submitLabel(.search)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            ZStack(alignment: .bottomTrailing) {
                // Interactive Map View
                ZStack {
                    MapViewRepresentable(region: $locationHelper.region)
                    
                    // ZEPTOPINK floating needle pin with tooltip speech callout box!
                    VStack(spacing: 0) {
                        // Tooltip speech card
                        VStack(spacing: 2) {
                            Text("Order will be delivered here")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            Text("Place the pin to your exact location")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 26/255, green: 29/255, blue: 40/255))
                        .cornerRadius(6)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                        
                        // Small down pointing speech bubble stem
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 7))
                            .foregroundColor(Color(red: 26/255, green: 29/255, blue: 40/255))
                            .rotationEffect(.degrees(180))
                            .offset(y: -2)
                        
                        // Red Needle Pin structure for highly clear map placement!
                        ZStack {
                            // Anchor base ring
                            Ellipse()
                                .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
                                .frame(width: 14, height: 6)
                                .offset(y: 19)
                            
                            // Vertical needle
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 16, height: 16)
                                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: 2, height: 18)
                            }
                        }
                    }
                    .offset(y: -22) // Anchor pin bottom mathematically to center coordinates
                    .allowsHitTesting(false) // Passes drags through directly to MKMapView
                }
                .zIndex(1)
                
                // Floating GPS Locate Me button
                Button(action: {
                    gpsManager.requestLocation()
                    if let userLoc = gpsManager.userLocation?.coordinate {
                        withAnimation {
                            locationHelper.region.center = userLoc
                        }
                    }
                }) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 18))
                        .foregroundColor(zeptoPink)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
                .zIndex(6)
            }
            
            // Bottom Address Location Card (Vibrant Pink Action Confirm)
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(locationHelper.mainStreetName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(walnut)
                    
                    Text(locationHelper.subAreaDetails)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Button(action: {
                    if areaStreet.isEmpty {
                        areaStreet = locationHelper.reverseGeocodedAddressString
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .detailsForm
                    }
                }) {
                    Text("Confirm Location")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(walnut)
                        .cornerRadius(25)
                        .shadow(color: walnut.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(SpringPressButtonStyle())
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
        }
    }
    
    // Details Form Step View with short fixed map at the top
    private var detailsFormStepView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Short Fixed Map representing selected location
                ZStack {
                    MapViewRepresentable(region: .constant(locationHelper.region))
                        .frame(height: 130)
                        .disabled(true) // Static look on final screen
                    
                    // Fixed red pin aligned to center
                    ZStack {
                        Ellipse()
                            .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 12, height: 5)
                            .offset(y: 15)
                        
                        VStack(spacing: 0) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 14, height: 14)
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 2, height: 14)
                        }
                    }
                    .offset(y: -14)
                }
                .frame(height: 130)
                .overlay(
                    Rectangle()
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                
                // Location summary banner
                HStack(spacing: 12) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(zeptoPink)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(locationHelper.mainStreetName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(walnut)
                        
                        Text(locationHelper.subAreaDetails)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button("Change") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .mapSelection
                        }
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(zeptoPink)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.black.opacity(0.06)),
                    alignment: .bottom
                )
                
                // Form Fields matching Zepto Add Address details structure!
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Add address Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add address")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(walnut)
                            .padding(.top, 16)
                        
                        customFormTextField(placeholder: "House No. & Floor", text: $houseNo)
                        
                        customFormTextField(placeholder: "Building & Block No. (Optional)", text: $buildingName)
                        
                        customFormTextField(placeholder: "Landmark & Area Name (Optional)", text: $landmark)
                    }
                    
                    // Add address label Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add address label")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(walnut)
                        
                        HStack(spacing: 12) {
                            ForEach(["Home", "Work", "Other"], id: \.self) { type in
                                let isSelected = addressName == type
                                let icon: String = {
                                    switch type {
                                    case "Home": return "house"
                                    case "Work": return "briefcase"
                                    default: return "mappin"
                                    }
                                }()
                                
                                Button(action: { addressName = type }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: icon)
                                            .font(.system(size: 13))
                                        Text(type)
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(isSelected ? zeptoPink.opacity(0.1) : Color.white)
                                    .foregroundColor(isSelected ? zeptoPink : Color.secondary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(isSelected ? zeptoPink : Color.black.opacity(0.08), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Receiver details Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Receiver details")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(walnut)
                        
                        customFormTextField(placeholder: "Receiver's Name", text: $receiverName, rightIcon: "person.crop.square")
                        
                        customFormTextField(placeholder: "Receiver's Phone Number", text: $receiverPhone, leftPrefix: "+91 ")
                    }
                    .padding(.bottom, 24)
                    
                    // Save Address Submit button (Styled exactly like Home tab native button)
                    Button(action: {
                        saveAndDismiss()
                    }) {
                        Text("SAVE ADDRESS")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(canSave ? walnut : Color.secondary.opacity(0.4))
                            .cornerRadius(25)
                            .shadow(color: canSave ? walnut.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(SpringPressButtonStyle())
                    .disabled(!canSave)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var canSave: Bool {
        !houseNo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !receiverName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !receiverPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveAndDismiss() {
        let center = locationHelper.region.center
        let id = addressToEdit?.id ?? UUID().uuidString
        
        let cleanedPhone = receiverPhone.hasPrefix("+91") ? receiverPhone : "+91 " + receiverPhone
        
        let newAddress = UserAddress(
            id: id,
            name: addressName,
            latitude: center.latitude,
            longitude: center.longitude,
            houseNo: houseNo,
            building: buildingName,
            areaStreet: areaStreet,
            landmark: landmark,
            receiverName: receiverName,
            receiverPhone: cleanedPhone
        )
        
        if addressToEdit == nil {
            AddressManager.shared.addAddress(newAddress)
        } else {
            AddressManager.shared.updateAddress(newAddress)
        }
        onDismiss()
    }
    
    @ViewBuilder
    private func customFormTextField(placeholder: String, text: Binding<String>, rightIcon: String? = nil, leftPrefix: String? = nil) -> some View {
        HStack(spacing: 8) {
            if let prefix = leftPrefix {
                Text(prefix)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(walnut)
            }
            
            TextField(placeholder, text: text)
                .font(.system(size: 14))
                .foregroundColor(walnut)
            
            if let icon = rightIcon {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Core GPS Location Manager
class GPSLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var permissionGranted = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            permissionGranted = true
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.userLocation = location
            manager.stopUpdatingLocation() // Stop to save battery and prevent loops
        }
    }
}

// MARK: - Map Kit Location Helper & Reverse Geocoder
class MapLocationHelper: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 18.5204, longitude: 73.8567), // Defaults to Pune, India central
        span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015) // Zoomed in closer!
    ) {
        didSet {
            debouncedReverseGeocode()
        }
    }
    
    @Published var reverseGeocodedAddressString = ""
    @Published var mainStreetName = "Locating..."
    @Published var subAreaDetails = "Determining neighborhood details..."
    
    private var lastGeocodedCoordinate: CLLocationCoordinate2D?
    private var timer: Timer?
    
    func debouncedReverseGeocode() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            let center = self.region.center
            
            // Check delta to avoid infinite geocoder requests
            if let last = self.lastGeocodedCoordinate {
                let latDiff = abs(last.latitude - center.latitude)
                let lonDiff = abs(last.longitude - center.longitude)
                if latDiff < 0.0001 && lonDiff < 0.0001 { return }
            }
            
            self.lastGeocodedCoordinate = center
            self.performGeocode(center)
        }
    }
    
    private func performGeocode(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil, let placemark = placemarks?.first else { return }
            
            DispatchQueue.main.async {
                let name = placemark.name ?? ""
                let subThoroughfare = placemark.subThoroughfare ?? ""
                let thoroughfare = placemark.thoroughfare ?? ""
                let subLocality = placemark.subLocality ?? ""
                let locality = placemark.locality ?? ""
                
                // Extract primary street/lane
                let streetPart = thoroughfare.isEmpty ? name : thoroughfare
                let subLocPart = subLocality.isEmpty ? locality : subLocality
                
                self.mainStreetName = streetPart.isEmpty ? "Selected Location" : streetPart
                
                // Formulate suburb, city details
                let detailParts = [subThoroughfare, subLocPart, locality].filter { !$0.isEmpty && $0 != streetPart }
                self.subAreaDetails = detailParts.isEmpty ? "Pune, India" : detailParts.joined(separator: ", ")
                
                // Complete unified address string
                let components = [name, subThoroughfare, thoroughfare, subLocality, locality].filter { !$0.isEmpty }
                var uniqueComponents: [String] = []
                for comp in components {
                    if !uniqueComponents.contains(comp) {
                        uniqueComponents.append(comp)
                    }
                }
                
                self.reverseGeocodedAddressString = uniqueComponents.joined(separator: ", ")
            }
        }
    }
    
    func searchLocation(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self, let response = response, let mapItem = response.mapItems.first else { return }
            
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.region = MKCoordinateRegion(
                        center: mapItem.placemark.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
                    )
                }
            }
        }
    }
}

// MARK: - MapViewRepresentable
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.region = mapView.region
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Only update if center is noticeably different, to avoid loop feedback jitters
        let currentCenter = uiView.region.center
        let targetCenter = region.center
        let latDiff = abs(currentCenter.latitude - targetCenter.latitude)
        let lonDiff = abs(currentCenter.longitude - targetCenter.longitude)
        
        if latDiff > 0.0001 || lonDiff > 0.0001 {
            uiView.setRegion(region, animated: true)
        }
    }
}
