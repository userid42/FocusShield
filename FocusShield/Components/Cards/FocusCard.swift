import SwiftUI

// MARK: - Focus Card

struct FocusCard<Content: View>: View {
    let content: () -> Content
    var padding: CGFloat = Spacing.md

    init(
        padding: CGFloat = Spacing.md,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(Color.adaptiveCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            .shadow(color: .black.opacity(0.02), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Section Card

struct SectionCard<Content: View>: View {
    let title: String
    var icon: String? = nil
    var accessibilityLabel: String? = nil
    let content: () -> Content

    init(
        title: String,
        icon: String? = nil,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.focusPrimary)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.headlineMedium)
                    .foregroundColor(.adaptiveText)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            content()
        }
        .padding(Spacing.md)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Elevated Card

struct ElevatedCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(Spacing.md)
            .background(Color.adaptiveSurface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        FocusCard {
            Text("Simple card content")
        }

        SectionCard(title: "Today's Budgets", icon: "clock.fill") {
            Text("Budget content here")
        }

        ElevatedCard {
            Text("Elevated card content")
        }
    }
    .padding()
    .background(LinearGradient.backgroundGradient)
}
