//
//  ContentView.swift
//  find_my
//
//  Created by haojun on 2026/4/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    // 默认视角设为跟随用户位置
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
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
                // 将地图的控件（如右上角的定位图标）整体往下推 40 points，避免遮挡
                .safeAreaPadding(.top, 40)
                
                // 顶部毛玻璃效果：高度设为0，通过忽略安全区自动延伸填满整个顶部状态栏区域
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 0)
                    .ignoresSafeArea(edges: .top)
                
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
                .safeAreaPadding(.top, 40)
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 0)
                    .ignoresSafeArea(edges: .top)
            }
            .tabItem {
                Label("Devices", systemImage: "laptopcomputer.and.iphone")
            }
            
            ZStack(alignment: .top) {
                Map(position: $position) {
                    UserAnnotation()
                }
                .mapControls { MapUserLocationButton() }
                .safeAreaPadding(.top, 40)
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 0)
                    .ignoresSafeArea(edges: .top)
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
    }
}

#Preview {
    ContentView()
}
