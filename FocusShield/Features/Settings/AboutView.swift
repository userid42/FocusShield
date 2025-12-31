import SwiftUI

struct AboutView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        List {
            // App Info
            Section {
                VStack(spacing: Spacing.md) {
                    // App Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.focusPrimary, .focusSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: "shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .focusPrimary.opacity(0.3), radius: 10, y: 5)

                    VStack(spacing: 4) {
                        Text("FocusShield")
                            .font(.headlineLarge)

                        Text("Version \(appVersion) (\(buildNumber))")
                            .font(.labelMedium)
                            .foregroundColor(.neutral)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .listRowBackground(Color.clear)
            }

            // Mission
            Section {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Our Mission")
                        .font(.headlineMedium)

                    Text("FocusShield helps you build a healthier relationship with technology through mindful limits, accountability, and compassionate support when you struggle.")
                        .font(.bodyMedium)
                        .foregroundColor(.neutral)
                }
                .padding(.vertical, Spacing.sm)
            }

            // Links
            Section {
                Link(destination: URL(string: "https://focusshield.app")!) {
                    LinkRow(icon: "globe", title: "Website")
                }

                Link(destination: URL(string: "https://focusshield.app/privacy")!) {
                    LinkRow(icon: "hand.raised.fill", title: "Privacy Policy")
                }

                Link(destination: URL(string: "https://focusshield.app/terms")!) {
                    LinkRow(icon: "doc.text.fill", title: "Terms of Service")
                }
            } header: {
                Text("Legal")
            }

            // Social
            Section {
                Link(destination: URL(string: "https://twitter.com/focusshield")!) {
                    LinkRow(icon: "bubble.left.fill", title: "Twitter")
                }

                Link(destination: URL(string: "https://focusshield.app/community")!) {
                    LinkRow(icon: "person.3.fill", title: "Community")
                }

                Button {
                    requestAppReview()
                } label: {
                    LinkRow(icon: "star.fill", title: "Rate on App Store")
                }
                .buttonStyle(.plain)
            } header: {
                Text("Connect")
            }

            // Credits
            Section {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Built with ❤️")
                        .font(.headlineMedium)

                    Text("FocusShield is inspired by the belief that technology should serve us, not control us. Thank you for being part of this journey.")
                        .font(.bodyMedium)
                        .foregroundColor(.neutral)
                }
                .padding(.vertical, Spacing.sm)
            }

            // Acknowledgments
            Section {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Special Thanks")
                        .font(.labelLarge)

                    Text("• Apple Screen Time APIs")
                        .font(.labelMedium)
                        .foregroundColor(.neutral)
                    Text("• The Focus Community")
                        .font(.labelMedium)
                        .foregroundColor(.neutral)
                    Text("• Open Source Contributors")
                        .font(.labelMedium)
                        .foregroundColor(.neutral)
                }
                .padding(.vertical, Spacing.sm)
            } footer: {
                Text("© 2024 FocusShield. All rights reserved.")
                    .frame(maxWidth: .infinity)
                    .padding(.top, Spacing.lg)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func requestAppReview() {
        // Would trigger SKStoreReviewController
        HapticPattern.success()
    }
}

// MARK: - Link Row

struct LinkRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.focusPrimary)
                .frame(width: 24)

            Text(title)
                .font(.bodyMedium)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.system(size: 12))
                .foregroundColor(.neutral)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
