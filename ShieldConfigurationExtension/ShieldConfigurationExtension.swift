import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Extension that provides custom shield UI when blocked apps are opened
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let userDefaults = UserDefaults(suiteName: "group.com.focusshield.app")

    /// Provides the shield configuration for a blocked application
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return createShieldConfiguration(
            title: "Take a Breath",
            subtitle: application.localizedDisplayName ?? "This app",
            primaryButtonLabel: "I'm Done",
            secondaryButtonLabel: "Options"
        )
    }

    /// Provides the shield configuration for a blocked application category
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return createShieldConfiguration(
            title: "Focus Time",
            subtitle: category.localizedDisplayName ?? "This category",
            primaryButtonLabel: "I'm Done",
            secondaryButtonLabel: "Options"
        )
    }

    /// Provides the shield configuration for a blocked web domain
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return createShieldConfiguration(
            title: "Stay Focused",
            subtitle: webDomain.domain ?? "This website",
            primaryButtonLabel: "I'm Done",
            secondaryButtonLabel: "Options"
        )
    }

    /// Provides the shield configuration for a blocked web domain in a category
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return createShieldConfiguration(
            title: "Stay Focused",
            subtitle: category.localizedDisplayName ?? "This category",
            primaryButtonLabel: "I'm Done",
            secondaryButtonLabel: "Options"
        )
    }

    // MARK: - Private Helpers

    private func createShieldConfiguration(
        title: String,
        subtitle: String,
        primaryButtonLabel: String,
        secondaryButtonLabel: String
    ) -> ShieldConfiguration {
        // Load custom message if set
        let customMessage = userDefaults?.string(forKey: "shield_custom_message")

        // Get commitment mode to determine strictness
        let commitmentMode = userDefaults?.string(forKey: "commitment_mode") ?? "standard"

        // Determine colors based on mode
        let backgroundColor = ShieldConfiguration.BackgroundStyle.color(
            UIColor(red: 0.047, green: 0.051, blue: 0.059, alpha: 1.0)
        )

        let primaryColor = UIColor(red: 0.310, green: 0.275, blue: 0.898, alpha: 1.0)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: createShieldIcon(),
            title: ShieldConfiguration.Label(
                text: title,
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: customMessage ?? "You set limits on \(subtitle). What would you like to do?",
                color: UIColor.white.withAlphaComponent(0.7)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: primaryButtonLabel,
                color: .white
            ),
            primaryButtonBackgroundColor: primaryColor,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: secondaryButtonLabel,
                color: primaryColor
            )
        )
    }

    private func createShieldIcon() -> UIImage? {
        // Create a simple shield icon programmatically
        let size = CGSize(width: 60, height: 60)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let primaryColor = UIColor(red: 0.310, green: 0.275, blue: 0.898, alpha: 1.0)

            // Draw circle background
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
            primaryColor.withAlphaComponent(0.2).setFill()
            circlePath.fill()

            // Draw shield symbol in center
            let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
            if let shieldImage = UIImage(systemName: "shield.fill", withConfiguration: config) {
                let imageSize = shieldImage.size
                let imageRect = CGRect(
                    x: (size.width - imageSize.width) / 2,
                    y: (size.height - imageSize.height) / 2,
                    width: imageSize.width,
                    height: imageSize.height
                )
                primaryColor.setFill()
                shieldImage.withTintColor(primaryColor, renderingMode: .alwaysOriginal)
                    .draw(in: imageRect)
            }
        }
    }
}
