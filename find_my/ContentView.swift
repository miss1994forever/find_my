//
//  ContentView.swift
//  find_my
//
//  Created by haojun on 2026/4/22.
//

import SwiftUI
import MapKit
import CoreLocation

// 1. 创建一个用于管理和请求定位权限的类
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    // 调用此方法主动触发弹窗
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    // 监听权限改变状态（可选，用于调试）
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location authorization status changed: \(manager.authorizationStatus.rawValue)")
    }
}

struct ContentView: View {
    // 默认视角设为跟随用户位置
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // 维持着用于系统级请求权限的管理实例
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        TabView {
            ZStack(alignment: .top) {
                // 添加定位点并绑定相机视角
                Map(position: $position) {
                    UserAnnotation() // 显示用户当前位置的蓝点
                }
                .mapControls {
                    MapUserLocationButton() // 添加返回当前位置的按钮（蓝色飞机图标）
                    MapCompass()            // 添加指南针
                    MapScaleView()          // 添加比例尺
                    MapPitchToggle()        // 3D视角切换
                }
                .mapStyle(.standard(elevation: .realistic))
                // 使用 safeAreaInset 自动处理顶部毛玻璃和控件避让
                .safeAreaInset(edge: .top) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        // 若想让毛玻璃有一定高度包裹顶部，稍微给一点 height，如果只想覆盖状态栏，可以给个较小的值
                        .frame(height: 20)
                }
                
                // 这里可以添加底部的浮动面板 (Bottom Sheet)
            }
            .tabItem {
                Label("People", systemImage: "person.2.fill")
            }
            
            ZStack(alignment: .top) {
                Map(position: $position) {
                    UserAnnotation()
                }
                .mapControls { MapUserLocationButton() }
                .safeAreaInset(edge: .top) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: 20)
                }
            }
            .tabItem {
                Label("Devices", systemImage: "laptopcomputer.and.iphone")
            }
            
            ZStack(alignment: .top) {
                Map(position: $position) {
                    UserAnnotation()
                }
                .mapControls { MapUserLocationButton() }
                .safeAreaInset(edge: .top) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: 20)
                }
            }
            .tabItem {
                Label("Items", systemImage: "airtag")
            }
            
            NavigationView {
                Text("Me Settings")
                    .navigationTitle("Me")
            }
            .tabItem {
                Label("Me", systemImage: "person.circle.fill")
            }
        }
        .onAppear {
            // 当主视图首次加载时请求权限弹窗
            locationManager.requestPermission()
        }
    }
}

#Preview {
    ContentView()
}
