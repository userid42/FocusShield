import SwiftUI

// MARK: - Template Chip

struct TemplateChip: View {
    let template: AppGroupTemplate
    var isSelected: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticPattern.selection()
            onTap()
        }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: template.iconName)
                    .font(.system(size: 14))

                Text(template.rawValue)
                    .font(.labelMedium)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(isSelected ? Color.focusPrimary : Color.cardBackground)
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.neutral.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Template Chips Row

struct TemplateChipsRow: View {
    @Binding var selectedTemplates: Set<AppGroupTemplate>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(AppGroupTemplate.allCases) { template in
                    TemplateChip(
                        template: template,
                        isSelected: selectedTemplates.contains(template)
                    ) {
                        if selectedTemplates.contains(template) {
                            selectedTemplates.remove(template)
                        } else {
                            selectedTemplates.insert(template)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        HStack(spacing: Spacing.sm) {
            TemplateChip(template: .shortForm, isSelected: true) {}
            TemplateChip(template: .social, isSelected: false) {}
        }

        TemplateChipsRow(selectedTemplates: .constant([.shortForm, .social]))
    }
    .padding(.vertical)
    .background(Color.backgroundStart)
}
