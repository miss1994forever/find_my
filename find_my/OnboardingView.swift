import SwiftUI

struct OnboardingView: View {
    @Binding var isFirstLaunch: Bool
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 60)
            
            Text("What's New in\nFind My")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 50)
            
            VStack(alignment: .leading, spacing: 30) {
                FeatureRow(
                    icon: "macwindow", // 替代的系统图标，贴近屏幕加调节
                    title: "Match",
                    description: "Match the gradients by moving the Red, Green and Blue sliders for the left and right colors."
                )
                
                FeatureRow(
                    icon: "plus.slash.minus", // SFSymbol: -/+
                    title: "Precise",
                    description: "More precision with the steppers to get that 100 score."
                )
                
                FeatureRow(
                    icon: "checkmark.square", // 勾选框
                    title: "Score",
                    description: "A detailed score and comparsion of your gradient and the target gradient."
                )
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                // 点击继续，改变状态，收起引导页
                isFirstLaunch = false
            }) {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple) // 改为紫色
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}

// 提取的特性说明行组件
struct FeatureRow: View {
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .light))
                .foregroundColor(.purple) // 改为紫色
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    OnboardingView(isFirstLaunch: .constant(true))
}