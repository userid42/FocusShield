import SwiftUI

struct DataExportView: View {
    @EnvironmentObject var persistence: PersistenceService
    @State private var selectedFormat: ExportFormat = .json
    @State private var selectedDateRange: DateRange = .allTime
    @State private var includeProgress = true
    @State private var includeAchievements = true
    @State private var includeLimits = true
    @State private var includeIntegrityLog = true
    @State private var isExporting = false
    @State private var showingShareSheet = false
    @State private var exportURL: URL?

    var body: some View {
        List {
            // Format Selection
            Section {
                ForEach(ExportFormat.allCases) { format in
                    Button {
                        selectedFormat = format
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(format.rawValue)
                                    .font(.bodyMedium)
                                    .foregroundColor(.primary)
                                Text(format.description)
                                    .font(.labelSmall)
                                    .foregroundColor(.neutral)
                            }

                            Spacer()

                            if selectedFormat == format {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.focusPrimary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Export Format")
            }

            // Date Range
            Section {
                ForEach(DateRange.allCases) { range in
                    Button {
                        selectedDateRange = range
                    } label: {
                        HStack {
                            Text(range.rawValue)
                                .font(.bodyMedium)
                                .foregroundColor(.primary)

                            Spacer()

                            if selectedDateRange == range {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.focusPrimary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Date Range")
            }

            // Data to Include
            Section {
                Toggle("Progress & Streaks", isOn: $includeProgress)
                    .tint(.focusPrimary)
                Toggle("Achievements", isOn: $includeAchievements)
                    .tint(.focusPrimary)
                Toggle("Limits & Settings", isOn: $includeLimits)
                    .tint(.focusPrimary)
                Toggle("Integrity Log", isOn: $includeIntegrityLog)
                    .tint(.focusPrimary)
            } header: {
                Text("Include Data")
            }

            // Export Button
            Section {
                Button {
                    exportData()
                } label: {
                    HStack {
                        Spacer()
                        if isExporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Data")
                        }
                        Spacer()
                    }
                    .font(.labelLarge)
                    .foregroundColor(.white)
                    .padding(.vertical, Spacing.sm)
                }
                .listRowBackground(Color.focusPrimary)
                .disabled(isExporting)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func exportData() {
        isExporting = true

        Task {
            // Simulate export preparation
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            let exportData = ExportData(
                exportDate: Date(),
                format: selectedFormat,
                dateRange: selectedDateRange,
                progress: includeProgress ? persistence.userProgress : nil,
                achievements: includeAchievements ? persistence.achievements : nil,
                limits: includeLimits ? persistence.appLimits : nil
            )

            // Create temp file
            let fileName = "FocusShield_Export_\(Date().formatted(.iso8601.year().month().day()))"
            let fileExtension = selectedFormat == .json ? "json" : "csv"
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(fileName)
                .appendingPathExtension(fileExtension)

            if let data = try? JSONEncoder().encode(exportData) {
                try? data.write(to: tempURL)
                exportURL = tempURL
            }

            await MainActor.run {
                isExporting = false
                showingShareSheet = true
            }
        }
    }
}

// MARK: - Export Format

enum ExportFormat: String, CaseIterable, Identifiable, Codable {
    case json = "JSON"
    case csv = "CSV"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .json: return "Detailed data format, best for backup"
        case .csv: return "Spreadsheet compatible format"
        }
    }
}

// MARK: - Date Range

enum DateRange: String, CaseIterable, Identifiable, Codable {
    case lastWeek = "Last 7 Days"
    case lastMonth = "Last 30 Days"
    case lastYear = "Last Year"
    case allTime = "All Time"

    var id: String { rawValue }
}

// MARK: - Export Data Model

struct ExportData: Codable {
    let exportDate: Date
    let format: ExportFormat
    let dateRange: DateRange
    let progress: UserProgress?
    let achievements: AchievementsData?
    let limits: [AppLimit]?
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        DataExportView()
            .environmentObject(PersistenceService.shared)
    }
}
