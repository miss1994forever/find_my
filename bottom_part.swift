
struct ContentView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @StateObject private var locationManager = LocationManager()
    @State private var selectedTab: String = "Devices"
    
    // 使用 AppStorage，确保仅在首次打开应用时（或者状态变回true时）弹出 Onboarding
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    
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
            
            TabScreen(tabName: "Me", position: $position)
                .tabItem { Label("Me", systemImage: "person.circle.fill") }
                .tag("Me")
        }
        .onAppear {
            locationManager.requestPermission()
        }
        // 当 isFirstLaunch 为真时全屏蒙层显示 OnboardingView
        .fullScreenCover(isPresented: $isFirstLaunch) {
            OnboardingView(isFirstLaunch: $isFirstLaunch)
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
            FindMyMap(tabName: tabName, position: $position)
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
                
                List {
                    if tabName == "People" {
                        DeviceRow(name: "Xiaoming", desc: "Hangzhou, Zhejiang • Now", status: "160 mi", icon: "person.crop.circle.fill")
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(.gray.opacity(0.3)) // 控制分割线颜色
                    } else if tabName == "Devices" {
                        DeviceRow(name: "Haojun's iPhone", desc: "This iPhone", status: "With You", icon: "iphone")
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(.gray.opacity(0.3))
                        DeviceRow(name: "Haojun's AirPods Pro", desc: "Zhejiang University Yuquan Campus 3 Dining Hall • 2 min. ago", status: "2 mi", icon: "airpodspro")
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(.gray.opacity(0.3))
                        DeviceRow(name: "Haojun's iPad Pro", desc: "Zhejiang University Yuquan Campus Library • Now", status: "2 mi", icon: "ipad.gen1")
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(.gray.opacity(0.3))
                    } else {
                        Text("\(tabName) List is empty.")
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                // iOS 16+: 隐藏系统列表的默认灰色背景，以免遮蔽我们写好的半透明材质面板
                .scrollContentBackground(.hidden)
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
        .padding(.vertical, 8)
        // 移除死板的白色背景，让它透出底下的毛玻璃
        .background(Color.clear)
    }
}


struct FindMyMap: View {
    var tabName: String
    @Binding var position: MapCameraPosition
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            
            // 为 Devices 界面添加一些静态的模拟设备标注 (基于加州或者常见模拟器总部)
            if tabName == "Devices" {
                Annotation("Haojun's iPhone", coordinate: CLLocationCoordinate2D(latitude: 30.2635, longitude: 120.1200)) {
                    ZStack {
                        Circle().fill(.white).frame(width: 36, height: 36)
                        Image(systemName: "iphone").foregroundColor(.black)
                    }
                    .shadow(radius: 4)
                }
                Annotation("Haojun's AirPods Pro", coordinate: CLLocationCoordinate2D(latitude: 30.2658, longitude: 120.1222)) {
                    ZStack {
                        Circle().fill(.white).frame(width: 36, height: 36)
                        Image(systemName: "airpodspro").foregroundColor(.black)
                    }
                    .shadow(radius: 4)
                }
                Annotation("Haojun's iPad Pro", coordinate: CLLocationCoordinate2D(latitude: 30.2630, longitude: 120.1203)) {
                    ZStack {
                        Circle().fill(.white).frame(width: 36, height: 36)
                        Image(systemName: "ipad.gen1").foregroundColor(.black)
                    }
                    .shadow(radius: 4)
                    // 向上偏移图标，避免视觉上重叠
                    .offset(y: -30)
                    // 将占位体积设为0，防止 MapKit 的防碰撞机制隐藏背后的原生 POI (如图书馆图标和文字)
                    .frame(width: 0, height: 0)
                }
            }
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
