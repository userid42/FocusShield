import SwiftUI
import FamilyControls

struct AppSelectionView: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    @EnvironmentObject var screenTimeService: ScreenTimeService
    @State private var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @State private var showingPicker = false
    @State private var selectedTemplates: Set<AppGroupTemplate> = []

    private var hasSelection: Bool {
        !selectedApps.applicationTokens.isEmpty ||
        !selectedApps.categoryTokens.isEmpty
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.labelLarge)
                    .foregroundColor(.focusPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.md)

            // Header
            VStack(spacing: Spacing.sm) {
                Text("Pick your distractions")
                    .font(.displayMedium)

                Text("Which apps pull you in?")
                    .font(.bodyMedium)
                    .foregroundColor(.neutral)
            }

            // Template suggestions
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Quick select")
                    .font(.labelMedium)
                    .foregroundColor(.neutral)
                    .padding(.horizontal, Spacing.md)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(AppGroupTemplate.allCases) { template in
                            TemplateChip(
                                template: template,
                                isSelected: selectedTemplates.contains(template),
                                onTap: {
                                    if selectedTemplates.contains(template) {
                                        selectedTemplates.remove(template)
                                    } else {
                                        selectedTemplates.insert(template)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }

            // Selection summary
            if hasSelection {
                SelectedAppsGrid(
                    applicationCount: selectedApps.applicationTokens.count,
                    categoryCount: selectedApps.categoryTokens.count
                )
                .padding(.horizontal, Spacing.md)
                .transition(.fadeAndSlide)
            }

            Spacer()

            // Add apps button
            Button {
                showingPicker = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(hasSelection ? "Edit Selection" : "Select Apps")
                }
                .font(.labelLarge)
                .foregroundColor(.focusPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.focusPrimary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            }
            .padding(.horizontal, Spacing.md)

            // Hint
            if !hasSelection {
                Text("We recommend selecting 3-5 apps to start")
                    .font(.labelSmall)
                    .foregroundColor(.neutral)
            }

            Spacer()

            // Continue button
            PrimaryButton(title: "Continue") {
                screenTimeService.saveSelection(selectedApps)
                onContinue()
            }
            .disabled(!hasSelection)
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.lg)
        }
        .familyActivityPicker(
            isPresented: $showingPicker,
            selection: $selectedApps
        )
        .animation(.smooth, value: hasSelection)
    }
}

#Preview {
    AppSelectionView(
        onContinue: {},
        onBack: {}
    )
    .environmentObject(ScreenTimeService.shared)
}
