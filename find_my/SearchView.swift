import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var heading: Double = 0.0
    
    init() {
        startUpdating()
    }
    
    func startUpdating() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] (data, error) in
                guard let data = data else { return }
                let yaw = data.attitude.yaw
                DispatchQueue.main.async {
                    self?.heading = yaw * 180.0 / .pi
                }
            }
        }
    }
    
    func stopUpdating() {
        motionManager.stopDeviceMotionUpdates()
    }
}

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    let deviceName: String
    
    @StateObject private var motionManager = MotionManager()
    @State private var distance: Double = 14.0
    @State private var targetHeading: Double = 45.0 // Mock target heading
    
    var body: some View {
        ZStack {
            // Dark gradient background matching Find My UWB interface
            LinearGradient(gradient: Gradient(colors: [Color.black, Color(white: 0.15)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FINDING")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Text(deviceName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                Spacer()
                
                // Rotational IMU Arrow Indicator
                ZStack {
                    let relAngle = (-motionManager.heading + targetHeading).truncatingRemainder(dividingBy: 360)
                    let angle = relAngle >= 0 ? relAngle : relAngle + 360
                    
                    // Convert to signed angle (-180 to 180) to make zero-crossing (top) perfectly continuous and stable
                    let signedAngle = angle > 180 ? angle - 360 : angle
                    let arcLength = abs(signedAngle)
                    let trackRotation = -90.0 - (signedAngle < 0 ? arcLength : 0)
                    
                    // Dotted track outline from top to arrow
                    let dashLine = StrokeStyle(lineWidth: 6, lineCap: .round, dash: [4, 20])
                    Circle()
                        .trim(from: 0.0, to: CGFloat(arcLength / 360.0))
                        .stroke(style: dashLine)
                        .foregroundColor(.white.opacity(0.3))
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(trackRotation))
                        .animation(.linear(duration: 0.1), value: signedAngle)
                    
                    // Dynamic target dot at arrow's location
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .offset(x: 125)
                        .rotationEffect(.degrees(signedAngle - 90))
                        .animation(.linear(duration: 0.1), value: signedAngle)

                    // Origin top dot at 12 o'clock
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .offset(x: 125)
                        .rotationEffect(.degrees(-90))
                    
                    Image(systemName: "location.north.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.3), radius: 20)
                        // Uses IMU yaw dynamically pointing towards a relative static target offset
                        .rotationEffect(.degrees(signedAngle))
                        .animation(.linear(duration: 0.1), value: signedAngle)
                }
                
                Spacer()
                
                // Bottom UI
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(Int(distance)) ft")
                        .font(.system(size: 48, weight: .regular))
                        .foregroundColor(.white)
                    Text("to your \(directionText)")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }
    
    // Dynamic text logic referencing the real relative angle calculated via IMU
    var directionText: String {
        let relativeAngle = (-motionManager.heading + targetHeading).truncatingRemainder(dividingBy: 360)
        let normalized = relativeAngle >= 0 ? relativeAngle : relativeAngle + 360
        
        switch normalized {
        case 0..<45, 315..<360:
            return "front"
        case 45..<135:
            return "right"
        case 135..<225:
            return "back"
        case 225..<315:
            return "left"
        default:
            return "right"
        }
    }
}
