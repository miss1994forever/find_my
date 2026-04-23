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
    
    // 面板初始高度，从 110 改为 65，使其正好包裹顶部把手与标题栏，隐藏下方的 List 内容
    @State private var sheetHeight: CGFloat = 60
    let minHeight: CGFloat = 55
    let midHeight: CGFloat = 300
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 150
    
    var body: some View {
        ZStack(alignment: .bottom) {
            FindMyMap(position: $position)
                // 拖拽面板时不再动态改变地图的安全区域，保持固定避让，这样不管面板怎么拉，背后的地图都不会跟着晃动
                .safeAreaPadding(.bottom, minHeight)
            
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
                        if tabName == "People" {
                            DeviceRow(name: "Qiongfang Chen", desc: "Wenzhou, Zhejiang • Now", status: "160 mi", icon: "person.crop.circle.fill")
                        } else if tabName == "Devices" {
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
            // 使用系统的半透明材质（与原生 Tab Bar 的毛玻璃极为接近），且只对顶部切圆角
            .background(.regularMaterial)
            .clipShape(
                UnevenRoundedRectangle(topLeadingRadius: 24, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 24)
            )
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
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
            // 不再使用 .edgesIgnoringSafeArea(.bottom)，保证正好落在 Tab Bar 的顶端
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
        // 移除死板的白色背景，让它透出底下的毛玻璃
        .background(Color.clear)
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
