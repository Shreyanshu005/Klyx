import SwiftUI

/// A reusable futuristic glassmorphic container for dashboard widgets.
struct BentoCard<Content: View>: View {
    let content: Content
    var backgroundColor: Color = AppColors.cardBackground
    var cornerRadius: CGFloat = 32

    init(backgroundColor: Color = AppColors.cardBackground, cornerRadius: CGFloat = 32, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

#Preview {
    ZStack {
        AppColors.pureBlack.ignoresSafeArea()
        
        VStack(spacing: 20) {
            BentoCard(backgroundColor: AppColors.boxRed) {
                VStack(alignment: .leading) {
                    Text("Top Widget")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("1,234")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .frame(height: 140)

            BentoCard(backgroundColor: AppColors.boxYellow) {
                VStack(alignment: .leading) {
                    Text("Streak 🔥")
                        .font(.headline)
                        .foregroundStyle(.black)
                    Text("45 Days")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                }
            }
            .frame(height: 140)
        }
        .padding()
    }
}
