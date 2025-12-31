import SwiftUI

struct AppGroupsView: View {
    @State private var selectedTemplate: AppGroupTemplate?

    var body: some View {
        List {
            Section {
                ForEach(AppGroupTemplate.allCases) { template in
                    AppGroupRow(template: template, isSelected: selectedTemplate == template) {
                        selectedTemplate = template
                    }
                }
            } header: {
                Text("Quick Templates")
            } footer: {
                Text("Select a template to quickly apply common app groups.")
            }
        }
        .navigationTitle("App Groups")
    }
}

// MARK: - App Group Row

struct AppGroupRow: View {
    let template: AppGroupTemplate
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.md) {
                Image(systemName: template.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.focusPrimary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(template.rawValue)
                        .font(.headlineMedium)
                        .foregroundColor(.primary)

                    Text(template.description)
                        .font(.labelSmall)
                        .foregroundColor(.neutral)
                }

                Spacer()

                Text("\(template.suggestedLimit)m")
                    .font(.labelMedium)
                    .foregroundColor(.neutral)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.focusPrimary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppGroupsView()
    }
}
