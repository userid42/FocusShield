import SwiftUI

struct ShieldOptionButton: View {
    let option: ShieldOption
    let action: () -> Void

    private var backgroundColor: Color {
        switch option {
        case .done: return .focusPrimary
        case .grace: return .white
        case .request: return .white
        case .emergency: return .danger.opacity(0.1)
        }
    }

    private var foregroundColor: Color {
        switch option {
        case .done: return .white
        case .grace, .request: return .primary
        case .emergency: return .danger
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: option.iconName)
                    .font(.system(size: 24))

                Text(option.rawValue)
                    .font(.labelLarge)

                Text(option.subtitle)
                    .font(.labelSmall)
                    .foregroundColor(option == .done ? .white.opacity(0.8) : .neutral)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        HStack(spacing: Spacing.md) {
            ShieldOptionButton(option: .done) {}
            ShieldOptionButton(option: .grace) {}
        }
        HStack(spacing: Spacing.md) {
            ShieldOptionButton(option: .request) {}
            ShieldOptionButton(option: .emergency) {}
        }
    }
    .padding()
    .background(Color.black.opacity(0.3))
}
