import XCTest

final class FocusShieldUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // Reset app state for testing
        app.launchArguments = ["--uitesting"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Onboarding Flow Tests

    func testOnboardingWelcomeScreen() throws {
        app.launch()

        // Verify welcome screen elements
        XCTAssertTrue(app.staticTexts["Welcome to FocusShield"].waitForExistence(timeout: 5))
    }

    func testOnboardingGoalSelection() throws {
        app.launch()

        // Navigate through welcome
        if app.buttons["Get Started"].exists {
            app.buttons["Get Started"].tap()
        }

        // Verify goal selection options
        XCTAssertTrue(app.staticTexts["Stop doomscrolling"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Be present at home"].exists)
        XCTAssertTrue(app.staticTexts["Focus at work"].exists)
        XCTAssertTrue(app.staticTexts["Sleep better"].exists)
    }

    // MARK: - Settings Tests

    func testSettingsNavigation() throws {
        // Skip onboarding for settings tests
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Navigate to Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        // Verify settings sections exist
        XCTAssertTrue(app.staticTexts["Pro Features"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Appearance"].exists)
        XCTAssertTrue(app.staticTexts["Commitment Mode"].exists)
    }

    func testProFeaturesToggle() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()

        // Find and toggle Pro features
        let proToggle = app.switches["Pro Features"]
        if proToggle.waitForExistence(timeout: 3) {
            let initialValue = proToggle.value as? String == "1"
            proToggle.tap()

            // Verify toggle changed
            let newValue = proToggle.value as? String == "1"
            XCTAssertNotEqual(initialValue, newValue)
        }
    }

    func testAppearanceSettings() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()

        // Tap on Appearance
        let appearanceRow = app.staticTexts["Appearance"]
        XCTAssertTrue(appearanceRow.waitForExistence(timeout: 3))
        appearanceRow.tap()

        // Verify appearance options
        XCTAssertTrue(app.staticTexts["Light"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Dark"].exists)
        XCTAssertTrue(app.staticTexts["Automatic"].exists)
    }

    func testAppearanceModeSelection() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Navigate to Settings > Appearance
        app.tabBars.buttons["Settings"].tap()
        app.staticTexts["Appearance"].tap()

        // Select Dark mode
        let darkOption = app.buttons["Dark"]
        if darkOption.waitForExistence(timeout: 3) {
            darkOption.tap()

            // Verify selection (checkmark should appear)
            XCTAssertTrue(app.images["checkmark.circle.fill"].exists)
        }
    }

    // MARK: - Dashboard Tests

    func testDashboardLoads() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Verify dashboard tab is selected by default
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 5))
        XCTAssertTrue(dashboardTab.isSelected)
    }

    func testDashboardRefresh() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Pull to refresh on dashboard
        let scrollView = app.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 3) {
            scrollView.swipeDown()

            // App should not crash and content should still be visible
            XCTAssertTrue(scrollView.exists)
        }
    }

    // MARK: - Limits Tests

    func testLimitsTabNavigation() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Navigate to Limits tab
        let limitsTab = app.tabBars.buttons["Limits"]
        XCTAssertTrue(limitsTab.waitForExistence(timeout: 5))
        limitsTab.tap()

        // Verify limits screen loads
        XCTAssertTrue(app.navigationBars["Limits"].waitForExistence(timeout: 3))
    }

    // MARK: - Progress Tests

    func testProgressTabNavigation() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Navigate to Progress tab
        let progressTab = app.tabBars.buttons["Progress"]
        XCTAssertTrue(progressTab.waitForExistence(timeout: 5))
        progressTab.tap()

        // Verify progress screen loads
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 3))
    }

    // MARK: - Accessibility Tests

    func testSettingsAccessibility() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()

        // Verify accessibility labels exist
        let proFeatureCell = app.cells.containing(.staticText, identifier: "Pro Features").firstMatch
        if proFeatureCell.waitForExistence(timeout: 3) {
            XCTAssertTrue(proFeatureCell.isAccessibilityElement || proFeatureCell.descendants(matching: .any).count > 0)
        }
    }

    func testMinimumTouchTargets() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()

        // Check that toggle buttons meet minimum 44pt touch target
        let toggles = app.switches.allElementsBoundByIndex
        for toggle in toggles {
            if toggle.exists {
                let frame = toggle.frame
                XCTAssertGreaterThanOrEqual(frame.height, 44, "Toggle should meet minimum touch target height")
            }
        }
    }

    // MARK: - Reset Data Tests

    func testResetDataConfirmation() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()

        // Scroll to find Reset button
        let resetButton = app.buttons["Reset All Data"]
        if resetButton.waitForExistence(timeout: 5) {
            resetButton.tap()

            // Verify confirmation alert appears
            XCTAssertTrue(app.alerts["Reset All Data?"].waitForExistence(timeout: 3))

            // Cancel the reset
            app.alerts.buttons["Cancel"].tap()
            XCTAssertFalse(app.alerts["Reset All Data?"].exists)
        }
    }

    // MARK: - Tab Navigation Tests

    func testTabNavigation() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        // Test all tabs
        let tabs = ["Dashboard", "Limits", "Progress", "Settings"]
        for tabName in tabs {
            let tab = tabBar.buttons[tabName]
            XCTAssertTrue(tab.exists, "Tab \(tabName) should exist")
            tab.tap()
            XCTAssertTrue(tab.isSelected, "Tab \(tabName) should be selected after tap")
        }
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        if #available(iOS 15.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

// MARK: - Snapshot Tests

extension FocusShieldUITests {

    func testSettingsSnapshot() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        app.tabBars.buttons["Settings"].tap()

        // Take snapshot for visual regression testing
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Settings Screen"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testAppearanceSettingsSnapshot() throws {
        app.launchArguments.append("--skip-onboarding")
        app.launch()

        app.tabBars.buttons["Settings"].tap()
        app.staticTexts["Appearance"].tap()

        // Take snapshot
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Appearance Settings"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
