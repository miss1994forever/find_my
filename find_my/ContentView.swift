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
            FindMyMap(position: $position)
                .tabItem {
                    Label("People", systemImage: "person.2.fill")
                }
            
            FindMyMap(position: $position)
                .tabItem {
                    Label("Devices", systemImage: "laptopcomputer.and.iphone")
                }
            
            FindMyMap(position: $position)
                .tabItem {
                    Label("Items", systemImage: "airtag")
                }
            
            FindMyMap(position: $position)
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

// 提取一个通用的地图视图组件，以保持四个界面完全一致的样式和点击行为
struct FindMyMap: View {
    @Binding var position: MapCameraPosition
    
    var body: some View {
        ZStack(alignment: .top) {
            // 添加定位点并绑定相机视角
            Map(position: $position) {
                UserAnnotation() // 显示用户当前位置的蓝点
            }
            .mapControls {
                // MapUserLocationButton 可以自动在“只是跟随”和“跟随且附带指南针/视线方向(Heading)”两种状态间切换
                MapUserLocationButton() // 蓝色飞机/箭头图标
                MapPitchToggle()        // 3D视角切换
                MapCompass()            // 指南针
                MapScaleView()          // 比例尺
            }
            .mapStyle(.standard(elevation: .realistic))
            // 使用 safeAreaInset 自动处理顶部毛玻璃和控件避让
            .safeAreaInset(edge: .top) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    // 若想让毛玻璃有一定高度包裹顶部，稍微给一点 height，如果只想覆盖状态栏，可以给个较小的值
                    .frame(height: 20)
            }
        }
    }
}

#Preview {
    ContentView()
}
