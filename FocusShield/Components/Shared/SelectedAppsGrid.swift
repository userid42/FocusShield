import SwiftUI
import FamilyControls

// MARK: - Selected Apps Grid

struct SelectedAppsGrid: View {
    let applicationCount: Int
    let categoryCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Selected")
                .font(.labelMedium)
                .foregroundColor(.neutral)

            HStack(spacing: Spacing.md) {
                if applicationCount > 0 {
                    SelectionBadge(
                        icon: "app.fill",
                        count: applicationCount,
                        label: applicationCount == 1 ? "app" : "apps"
                    )
                }

                if categoryCount > 0 {
                    SelectionBadge(
                        icon: "square.grid.2x2.fill",
                        count: categoryCount,
                        label: categoryCount == 1 ? "category" : "categories"
                    )
                }

                Spacer()
            }
        }
        .padding(Spacing.md)
        .background(Color.focusPrimary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Selection Badge

struct SelectionBadge: View {
    let icon: String
    let count: Int
    let label: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.focusPrimary)

            Text("\(count) \(label)")
                .font(.labelMedium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color.cardBackground)
        .clipShape(Capsule())
    }
}

// MARK: - App Selection Summary

struct AppSelectionSummary: View {
    let applicationCount: Int
    let categoryCount: Int
    let webDomainCount: Int

    var isEmpty: Bool {
        applicationCount == 0 && categoryCount == 0 && webDomainCount == 0
    }

    var totalCount: Int {
        applicationCount + categoryCount + webDomainCount
    }

    var body: some View {
        if isEmpty {
            Text("No apps selected")
                .font(.bodyMedium)
                .foregroundColor(.neutral)
        } else {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.success)

                Text("\(totalCount) item\(totalCount == 1 ? "" : "s") selected")
                    .font(.bodyMedium)
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        SelectedAppsGrid(applicationCount: 5, categoryCount: 2)

        AppSelectionSummary(
            applicationCount: 3,
            categoryCount: 1,
            webDomainCount: 0
        )

        AppSelectionSummary(
            applicationCount: 0,
            categoryCount: 0,
            webDomainCount: 0
        )
    }
    .padding()
    .background(Color.backgroundStart)
}
