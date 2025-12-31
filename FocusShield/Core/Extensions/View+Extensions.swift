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
    /// Apply focus spring animation with a specific value to animate on
    func focusSpringAnimation<V: Equatable>(value: V) -> some View {
        self.animation(.spring(response: 0.4, dampingFraction: 0.7), value: value)
    }

    /// Apply focus spring animation (use when you don't have a specific value)
    func focusSpring() -> Animation {
        .spring(response: 0.4, dampingFraction: 0.7)
    }
}

// MARK: - Navigation Extensions

extension View {
    /// Hide the navigation bar in a compatible way for iOS 16+
    @ViewBuilder
    func hideNavigationBar() -> some View {
        if #available(iOS 16.0, *) {
            self.toolbar(.hidden, for: .navigationBar)
        } else {
            self.navigationBarHidden(true)
        }
    }
}

// MARK: - Accessibility Extensions

extension View {
    /// Add semantic accessibility information for screen readers
    func accessibilityCard(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
}
