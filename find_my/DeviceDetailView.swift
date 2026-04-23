import SwiftUI

struct DeviceModel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let desc: String
    let status: String
    let icon: String
}

struct DeviceDetailView: View {
    let device: DeviceModel
    var onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(device.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(device.desc)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        HStack(spacing: 4) {
                            Text("1 minute ago")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Image(systemName: "battery.100")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                // Buttons HStack
                HStack(spacing: 12) {
                    actionButton(icon: "play.circle.fill", color: .blue, title: "Play Sound", subtitle: "Off")
                    actionButton(icon: "arrow.turn.up.right", color: .blue, title: "Directions", subtitle: "2.6 miles • 19 min")
                }
                // 使用 fixedSize 让按键高度一致对齐
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // 模拟 List 的样式，放在 ScrollView 里避免 SwiftUI 高度不足时的强行居中裁剪
                VStack(spacing: 0) {
                    Button(action: {}) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.red)
                                Text("Mark As Lost")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Activate")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.clear)
    }
    
    private func actionButton(icon: String, color: Color, title: String, subtitle: String) -> some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2) // 允许换行以防超出变窄
                }
            }
            // 关键：将 maxHeight 也设为 .infinity，保证它能撑满 HStack 里的同行等高高度
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .background(Color(.systemBackground).opacity(0.6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
