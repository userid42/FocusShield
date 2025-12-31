import SwiftUI

struct LimitsListView: View {
    @EnvironmentObject var persistence: PersistenceService
    @State private var showingAddLimit = false
    @State private var editingLimit: AppLimit?

    var body: some View {
        NavigationStack {
            Group {
                if persistence.limits.isEmpty {
                    NoLimitsEmptyState {
                        showingAddLimit = true
                    }
                } else {
                    List {
                        ForEach(persistence.limits) { limit in
                            LimitRow(limit: limit)
                                .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.md, bottom: Spacing.sm, trailing: Spacing.md))
                                .listRowBackground(Color.clear)
                                .onTapGesture {
                                    editingLimit = limit
                                }
                        }
                        .onDelete(perform: deleteLimit)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Limits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddLimit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLimit) {
                EditLimitView(limit: nil) { newLimit in
                    persistence.addLimit(newLimit)
                }
            }
            .sheet(item: $editingLimit) { limit in
                EditLimitView(limit: limit) { updatedLimit in
                    persistence.updateLimit(updatedLimit)
                }
            }
        }
    }

    private func deleteLimit(at offsets: IndexSet) {
        for index in offsets {
            let limit = persistence.limits[index]
            persistence.removeLimit(id: limit.id)
        }
    }
}

// MARK: - Limit Row

struct LimitRow: View {
    let limit: AppLimit

    private var progressColor: Color {
        if limit.progress >= 1.0 { return .danger }
        if limit.progress >= 0.8 { return .warning }
        return .focusPrimary
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Progress ring
            CircularProgressView(progress: limit.progress, color: progressColor)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(limit.displayName)
                    .font(.headlineMedium)

                HStack(spacing: Spacing.xs) {
                    Text("\(limit.usedMinutesToday)m / \(limit.effectiveDailyLimit)m")
                        .font(.labelMedium)
                        .foregroundColor(.neutral)

                    if limit.isExceeded {
                        Text("Exceeded")
                            .font(.labelSmall)
                            .foregroundColor(.danger)
                    }
                }
            }

            Spacer()

            // Status indicator
            Circle()
                .fill(limit.isActive ? Color.success : Color.neutral.opacity(0.3))
                .frame(width: 10, height: 10)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.neutral)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

#Preview {
    LimitsListView()
        .environmentObject(PersistenceService.shared)
}
