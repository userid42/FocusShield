import SwiftUI

// MARK: - View Extensions

extension View {
    /// Apply a card style with background and shadow
    func cardStyle() -> some View {
        self
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            .shadow(color: .black.opacity(0.02), radius: 2, x: 0, y: 1)
    }

    /// Apply standard horizontal padding
    func horizontalPadding() -> some View {
        self.padding(.horizontal, Spacing.md)
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply a gradient background that ignores safe area
    func gradientBackground() -> some View {
        self.background(
            LinearGradient.backgroundGradient
                .ignoresSafeArea()
        )
    }

    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Conditional Modifiers

extension View {
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
}

// MARK: - Animation Extensions

extension View {
    func focusSpringAnimation() -> some View {
        self.animation(.spring(response: 0.4, dampingFraction: 0.7), value: UUID())
    }
}
