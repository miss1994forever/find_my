//
//  ContentView.swift
//  find_my
//
//  Created by haojun on 2026/4/22.
//

import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location authorization status changed: \(manager.authorizationStatus.rawValue)")
    }
}

struct ContentView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @StateObject private var locationManager = LocationManager()
    @State private var selectedTab: String = "Devices"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TabScreen(tabName: "People", position: $position)
                .tabItem { Label("People", systemImage: "person.2.fill") }
                .tag("People")
            
            TabScreen(tabName: "Devices", position: $position)
                .tabItem { Label("Devices", systemImage: "laptopcomputer.and.iphone") }
                .tag("Devices")
            
            TabScreen(tabName: "Items", position: $position)
                .tabItem { Label("Items", systemImage: "airtag") }
                .tag("Items")
            
            NavigationView {
                Text("Me Settings")
                    .navigationTitle("Me")
            }
            .tabItem { Label("Me", systemImage: "person.circle.fill") }
            .tag("Me")
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
}

struct TabScreen: View {
    var tabName: String
    @Binding var position: MapCameraPosition
    
    @State private var sheetHeight: CGFloat = 350
    let minHeight: CGFloat = 110
    let midHeight: CGFloat = 350
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 250
    
    var body: some View {
        ZStack(alignment: .bottom) {
            FindMyMap(position: $position)
                .safeAreaPadding(.bottom, sheetHeight)
            
            // 自定义的底部常驻面板 (Custom Bottom Sheet)
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                
                HStack {
                    Text(tabName)
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 0) {
                        if tabName == "Devices" {
                            DeviceRow(name: "Tania's iPhone", desc: "This iPhone", status: "With You", icon: "iphone")
                            Divider().padding(.leading, 56)
                            DeviceRow(name: "Tania's AirPods Pro", desc: "Jefferson Square • 2 min. ago", status: "2 mi", icon: "airpodspro")
                            Divider().padding(.leading, 56)
                            DeviceRow(name: "Tania's Apple Watch", desc: "Jefferson Square • 1 min. ago", status: "2 mi", icon: "applewatch")
                            Divider().padding(.leading, 56)
                            DeviceRow(name: "Tania's iPad Pro", desc: "Alamo Square • Now", status: "2 mi", icon: "ipad.gen1")
                        } else {
                            Text("\(tabName) List is empty.")
                                .foregroundColor(.secondary)
                                .padding(.top, 20)
                        }
                    }
                }
            }
            .frame(height: sheetHeight, alignment: .top)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newHeight = sheetHeight - value.translation.height
                        if newHeight > minHeight - 20 && newHeight < maxHeight + 50 {
                            sheetHeight = newHeight
                        }
                    }.onEnded { value in
                        let target = sheetHeight - value.predictedEndTranslation.height
                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                            if target > midHeight + 100 {
                                sheetHeight = maxHeight
                            } else if target > minHeight + 60 {
                                sheetHeight = midHeight
                            } else {
                                sheetHeight = minHeight
                            }
                        }
                    }
            )
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct DeviceRow: View {
    var name: String
    var desc: String
    var status: String
    var icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(desc)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(status)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
    }
}

struct FindMyMap: View {
    @Binding var position: MapCameraPosition
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
            MapCompass()
            MapScaleView()
        }
        .mapStyle(.standard(elevation: .realistic))
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 8)
                .background(.ultraThinMaterial, ignoresSafeAreaEdges: .top)
        }
    }
}

#Preview {
    ContentView()
}
