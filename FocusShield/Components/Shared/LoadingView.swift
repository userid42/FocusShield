import SwiftUI

// MARK: - Loading View

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)

            Text(message)
                .font(.bodyMedium)
                .foregroundColor(.neutral)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundStart.ignoresSafeArea())
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    var message: String = "Loading..."

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)

                Text(message)
                    .font(.bodyMedium)
                    .foregroundColor(.white)
            }
            .padding(Spacing.xl)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
    }
}

// MARK: - Shimmer Effect

struct ShimmerView: View {
    @State private var isAnimating = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.neutral.opacity(0.1),
                Color.neutral.opacity(0.2),
                Color.neutral.opacity(0.1)
            ]),
            startPoint: isAnimating ? .trailing : .leading,
            endPoint: isAnimating ? .leading : .trailing
        )
        .animation(
            .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Skeleton View

struct SkeletonView: View {
    var height: CGFloat = 20

    var body: some View {
        RoundedRectangle(cornerRadius: CornerRadius.small)
            .fill(Color.neutral.opacity(0.1))
            .frame(height: height)
            .overlay(ShimmerView())
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        LoadingView()
            .frame(height: 200)

        VStack(spacing: Spacing.sm) {
            SkeletonView(height: 20)
            SkeletonView(height: 60)
            SkeletonView(height: 20)
                .frame(width: 200)
        }
        .padding()
    }
}
