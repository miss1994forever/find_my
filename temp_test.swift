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
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            // List for extra options
            List {
                Section {
                    Button(action: {}) {
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
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
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
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemBackground).opacity(0.6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

