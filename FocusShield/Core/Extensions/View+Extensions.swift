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

    /// Apply an elevated card style with subtle teal accent
    func elevatedCardStyle() -> some View {
        self
            .padding(Spacing.md)
            .background(
                ZStack {
                    Color.cardBackground
                    LinearGradient.subtleGradient
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadow(color: Color.focusPrimary.opacity(0.08), radius: 12, x: 0, y: 4)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
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

    /// Conditional modifier with else clause
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
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
    /// Respects reduced motion accessibility setting
    func focusSpringAnimation<V: Equatable>(value: V) -> some View {
        self.modifier(ReducedMotionAnimationModifier(value: value))
    }

    /// Apply focus spring animation (use when you don't have a specific value)
    func focusSpring() -> Animation {
        .spring(response: 0.4, dampingFraction: 0.7)
    }

    /// Apply a smooth animation that respects reduced motion settings
    func smoothAnimation<V: Equatable>(value: V) -> some View {
        self.modifier(SmoothAnimationModifier(value: value))
    }
}

// MARK: - Reduced Motion Animation Modifier

private struct ReducedMotionAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let value: V

    func body(content: Content) -> some View {
        if reduceMotion {
            content.animation(.easeInOut(duration: 0.1), value: value)
        } else {
            content.animation(.spring(response: 0.4, dampingFraction: 0.7), value: value)
        }
    }
}

private struct SmoothAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let value: V

    func body(content: Content) -> some View {
        if reduceMotion {
            content.animation(.linear(duration: 0.15), value: value)
        } else {
            content.animation(.smooth(duration: 0.3), value: value)
        }
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

    /// Mark as a button with a label
    func accessibilityButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }

    /// Mark as a header for screen reader navigation
    func accessibilityHeader(_ label: String? = nil) -> some View {
        self
            .if(label != nil) { view in
                view.accessibilityLabel(label!)
            }
            .accessibilityAddTraits(.isHeader)
    }

    /// Configure for VoiceOver with custom actions
    func accessibilityActions(@ViewBuilder _ actions: () -> some View) -> some View {
        self.accessibilityElement(children: .contain)
    }

    /// Add accessibility value for progress indicators
    func accessibilityProgress(value: Double, label: String) -> some View {
        self
            .accessibilityValue("\(Int(value * 100)) percent")
            .accessibilityLabel(label)
    }
}

// MARK: - Focus State Extensions

extension View {
    /// Improve focus ring visibility for accessibility
    @ViewBuilder
    func focusRingStyle() -> some View {
        if #available(iOS 17.0, *) {
            self.focusEffectDisabled(false)
        } else {
            self
        }
    }
}
