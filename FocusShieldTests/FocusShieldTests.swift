import XCTest
@testable import FocusShield

final class FocusShieldTests: XCTestCase {

    // MARK: - GracePool Tests

    func testGracePoolInitialState() {
        let pool = GracePool()
        XCTAssertEqual(pool.dailyGracesRemaining, 3)
        XCTAssertEqual(pool.graceMinutes, 2)
        XCTAssertEqual(pool.totalGracesUsedToday, 0)
        XCTAssertTrue(pool.hasGracesRemaining)
    }

    func testGracePoolUseGrace() {
        var pool = GracePool()
        XCTAssertTrue(pool.useGrace())
        XCTAssertEqual(pool.dailyGracesRemaining, 2)
        XCTAssertEqual(pool.totalGracesUsedToday, 1)
    }

    func testGracePoolExhaustion() {
        var pool = GracePool()
        XCTAssertTrue(pool.useGrace())
        XCTAssertTrue(pool.useGrace())
        XCTAssertTrue(pool.useGrace())
        XCTAssertFalse(pool.useGrace()) // Should fail, no graces left
        XCTAssertEqual(pool.dailyGracesRemaining, 0)
        XCTAssertFalse(pool.hasGracesRemaining)
    }

    func testGracePoolDisplayRemaining() {
        var pool = GracePool()
        XCTAssertEqual(pool.displayRemaining, "3 graces remaining")

        _ = pool.useGrace()
        _ = pool.useGrace()
        XCTAssertEqual(pool.displayRemaining, "1 grace remaining")

        _ = pool.useGrace()
        XCTAssertEqual(pool.displayRemaining, "No graces left today")
    }

    // MARK: - AppLimit Tests

    func testAppLimitProgress() {
        var limit = AppLimit(name: "Social", dailyMinutes: 30)
        XCTAssertEqual(limit.progress, 0)

        limit.usedMinutesToday = 15
        XCTAssertEqual(limit.progress, 0.5, accuracy: 0.01)

        limit.usedMinutesToday = 30
        XCTAssertEqual(limit.progress, 1.0, accuracy: 0.01)
    }

    func testAppLimitRemainingMinutes() {
        var limit = AppLimit(name: "Social", dailyMinutes: 30)
        XCTAssertEqual(limit.remainingMinutes, 30)

        limit.usedMinutesToday = 15
        XCTAssertEqual(limit.remainingMinutes, 15)

        limit.usedMinutesToday = 35
        XCTAssertEqual(limit.remainingMinutes, 0) // Should not go negative
    }

    func testAppLimitIsExceeded() {
        var limit = AppLimit(name: "Social", dailyMinutes: 30)
        XCTAssertFalse(limit.isExceeded)

        limit.usedMinutesToday = 29
        XCTAssertFalse(limit.isExceeded)

        limit.usedMinutesToday = 30
        XCTAssertTrue(limit.isExceeded)

        limit.usedMinutesToday = 35
        XCTAssertTrue(limit.isExceeded)
    }

    func testAppLimitStatusColor() {
        var limit = AppLimit(name: "Social", dailyMinutes: 100)

        limit.usedMinutesToday = 50
        XCTAssertEqual(limit.statusColor, "focusPrimary") // < 80%

        limit.usedMinutesToday = 85
        XCTAssertEqual(limit.statusColor, "warning") // >= 80%, < 100%

        limit.usedMinutesToday = 100
        XCTAssertEqual(limit.statusColor, "danger") // >= 100%
    }

    // MARK: - UserProgress Tests

    func testUserProgressInitialState() {
        let progress = UserProgress()
        XCTAssertEqual(progress.currentStreak, 0)
        XCTAssertEqual(progress.longestStreak, 0)
        XCTAssertEqual(progress.totalDaysWithinLimits, 0)
        XCTAssertEqual(progress.totalDaysTracked, 0)
        XCTAssertEqual(progress.successRate, 0)
    }

    func testUserProgressRecordSuccessfulDay() {
        var progress = UserProgress()
        let record = DailyRecord(withinAllLimits: true)
        progress.recordDay(record)

        XCTAssertEqual(progress.currentStreak, 1)
        XCTAssertEqual(progress.longestStreak, 1)
        XCTAssertEqual(progress.totalDaysWithinLimits, 1)
        XCTAssertEqual(progress.totalDaysTracked, 1)
        XCTAssertEqual(progress.successRate, 1.0, accuracy: 0.01)
    }

    func testUserProgressRecordFailedDay() {
        var progress = UserProgress()

        // Record 3 successful days
        for _ in 0..<3 {
            let record = DailyRecord(withinAllLimits: true)
            progress.recordDay(record)
        }
        XCTAssertEqual(progress.currentStreak, 3)

        // Record a failed day
        let failedRecord = DailyRecord(withinAllLimits: false)
        progress.recordDay(failedRecord)

        XCTAssertEqual(progress.currentStreak, 0) // Streak reset
        XCTAssertEqual(progress.longestStreak, 3) // Longest preserved
        XCTAssertEqual(progress.totalDaysWithinLimits, 3)
        XCTAssertEqual(progress.totalDaysTracked, 4)
    }

    func testUserProgressSuccessRate() {
        var progress = UserProgress()

        progress.recordDay(DailyRecord(withinAllLimits: true))
        progress.recordDay(DailyRecord(withinAllLimits: true))
        progress.recordDay(DailyRecord(withinAllLimits: false))
        progress.recordDay(DailyRecord(withinAllLimits: true))

        XCTAssertEqual(progress.successRate, 0.75, accuracy: 0.01) // 3/4
        XCTAssertEqual(progress.displaySuccessRate, "75%")
    }

    // MARK: - DailyRecord Tests

    func testDailyRecordSuccessScore() {
        var record = DailyRecord()
        XCTAssertEqual(record.successScore, 1.0, accuracy: 0.01)

        record.limitExceededCount = 2
        XCTAssertEqual(record.successScore, 0.6, accuracy: 0.01) // 1.0 - 0.4

        record.emergencyAccessCount = 1
        XCTAssertEqual(record.successScore, 0.3, accuracy: 0.01) // 1.0 - 0.4 - 0.3

        record.doneChosenCount = 4
        XCTAssertEqual(record.successScore, 0.5, accuracy: 0.01) // 0.3 + 0.2 bonus
    }

    func testDailyRecordDisplayScreenTime() {
        var record = DailyRecord()

        record.totalScreenTimeMinutes = 45
        XCTAssertEqual(record.displayScreenTime, "45m")

        record.totalScreenTimeMinutes = 90
        XCTAssertEqual(record.displayScreenTime, "1h 30m")

        record.totalScreenTimeMinutes = 120
        XCTAssertEqual(record.displayScreenTime, "2h 0m")
    }

    // MARK: - Achievement Tests

    func testAchievementProgress() {
        var achievement = Achievement(definition: .streak7)
        XCTAssertEqual(achievement.progress, 0)
        XCTAssertFalse(achievement.isUnlocked)

        achievement.updateProgress(3)
        XCTAssertEqual(achievement.progress, 3.0/7.0, accuracy: 0.01)
        XCTAssertFalse(achievement.isUnlocked)

        achievement.updateProgress(7)
        XCTAssertEqual(achievement.progress, 1.0, accuracy: 0.01)
        XCTAssertTrue(achievement.isUnlocked)
        XCTAssertNotNil(achievement.unlockedAt)
    }

    func testAchievementDisplayProgress() {
        var achievement = Achievement(definition: .done10)
        XCTAssertEqual(achievement.displayProgress, "0/10")

        achievement.updateProgress(5)
        XCTAssertEqual(achievement.displayProgress, "5/10")

        achievement.updateProgress(10)
        XCTAssertEqual(achievement.displayProgress, "Completed")
    }

    // MARK: - AchievementsManager Tests

    func testAchievementsManagerInitialization() {
        let manager = AchievementsManager()
        XCTAssertEqual(manager.totalCount, AchievementDefinition.allCases.count)
        XCTAssertEqual(manager.unlockedCount, 0)
    }

    func testAchievementsManagerUpdate() {
        var manager = AchievementsManager()
        manager.updateAchievement(AchievementDefinition.firstDay.rawValue, progress: 1)

        XCTAssertEqual(manager.unlockedCount, 1)
        XCTAssertTrue(manager.achievement(for: .firstDay)?.isUnlocked ?? false)
    }

    // MARK: - QuietHours Tests

    func testQuietHoursDisplayString() {
        let quietHours = QuietHours(startHour: 22, endHour: 8)
        XCTAssertEqual(quietHours.displayString, "10:00 PM - 8:00 AM")

        let noonToMidnight = QuietHours(startHour: 12, endHour: 0)
        XCTAssertEqual(noonToMidnight.displayString, "12:00 PM - 12:00 AM")

        let midnightToNoon = QuietHours(startHour: 0, endHour: 12)
        XCTAssertEqual(midnightToNoon.displayString, "12:00 AM - 12:00 PM")
    }

    func testQuietHoursSpanningMidnight() {
        let quietHours = QuietHours(startHour: 22, endHour: 6, isEnabled: true)

        // When start > end, it spans midnight
        XCTAssertTrue(quietHours.startHour > quietHours.endHour)
    }

    // MARK: - Validation Tests

    func testEmailValidation() {
        XCTAssertTrue(Validation.isValidEmail("test@example.com"))
        XCTAssertTrue(Validation.isValidEmail("user.name+tag@domain.co.uk"))
        XCTAssertFalse(Validation.isValidEmail("invalid"))
        XCTAssertFalse(Validation.isValidEmail("@nodomain.com"))
        XCTAssertFalse(Validation.isValidEmail("no@tld"))
        XCTAssertFalse(Validation.isValidEmail(""))
    }

    func testPhoneValidation() {
        XCTAssertTrue(Validation.isValidPhoneNumber("1234567890"))
        XCTAssertTrue(Validation.isValidPhoneNumber("(123) 456-7890"))
        XCTAssertTrue(Validation.isValidPhoneNumber("+1 123 456 7890"))
        XCTAssertFalse(Validation.isValidPhoneNumber("12345")) // Too short
        XCTAssertFalse(Validation.isValidPhoneNumber("")) // Empty
    }

    func testNameValidation() {
        XCTAssertTrue(Validation.isValidName("John"))
        XCTAssertTrue(Validation.isValidName("Mary Jane"))
        XCTAssertTrue(Validation.isValidName("O'Brien"))
        XCTAssertFalse(Validation.isValidName(""))
        XCTAssertFalse(Validation.isValidName("123")) // No letters
    }

    func testSanitization() {
        XCTAssertEqual(Validation.sanitize("  hello  "), "hello")
        XCTAssertEqual(Validation.sanitizeEmail("  User@Example.COM  "), "user@example.com")
        XCTAssertEqual(Validation.sanitizePhoneNumber("(123) 456-7890"), "1234567890")
        XCTAssertEqual(Validation.sanitizePhoneNumber("+1 123 456 7890"), "+11234567890")
    }

    // MARK: - AppSettings Tests

    func testAppSettingsDefaults() {
        let settings = AppSettings()
        XCTAssertEqual(settings.appearanceMode, .automatic)
        XCTAssertFalse(settings.proFeaturesEnabled)
        XCTAssertTrue(settings.hapticsEnabled)
        XCTAssertFalse(settings.reducedMotion)
    }

    func testAppearanceModeColorScheme() {
        XCTAssertNil(AppearanceMode.automatic.colorScheme)
        XCTAssertEqual(AppearanceMode.light.colorScheme, .light)
        XCTAssertEqual(AppearanceMode.dark.colorScheme, .dark)
    }

    // MARK: - CommitmentMode Tests

    func testCommitmentModeProperties() {
        XCTAssertNil(CommitmentMode.gentle.editCooldownHours)
        XCTAssertEqual(CommitmentMode.standard.editCooldownHours, 24)
        XCTAssertNil(CommitmentMode.locked.editCooldownHours)

        XCTAssertFalse(CommitmentMode.gentle.requiresContactApproval)
        XCTAssertFalse(CommitmentMode.standard.requiresContactApproval)
        XCTAssertTrue(CommitmentMode.locked.requiresContactApproval)

        XCTAssertFalse(CommitmentMode.gentle.shieldsEnabled)
        XCTAssertTrue(CommitmentMode.standard.shieldsEnabled)
        XCTAssertTrue(CommitmentMode.locked.shieldsEnabled)
    }

    // MARK: - StreakStatus Tests

    func testStreakStatusNone() {
        let status = StreakStatus(currentStreak: 0, longestStreak: 10)
        if case .none = status {
            XCTAssertEqual(status.message, "Start your streak today")
        } else {
            XCTFail("Expected .none status")
        }
    }

    func testStreakStatusBuilding() {
        let status = StreakStatus(currentStreak: 3, longestStreak: 10)
        if case .building(let days) = status {
            XCTAssertEqual(days, 3)
        } else {
            XCTFail("Expected .building status")
        }
    }

    func testStreakStatusStrong() {
        let status = StreakStatus(currentStreak: 10, longestStreak: 20)
        if case .strong(let days) = status {
            XCTAssertEqual(days, 10)
        } else {
            XCTFail("Expected .strong status")
        }
    }

    func testStreakStatusRecord() {
        let status = StreakStatus(currentStreak: 15, longestStreak: 10)
        if case .record(let days) = status {
            XCTAssertEqual(days, 15)
        } else {
            XCTFail("Expected .record status")
        }
    }

    // MARK: - IntegrityEventType Tests

    func testIntegrityEventSeverity() {
        XCTAssertEqual(IntegrityEventType.accountabilityDisabled.severity, .critical)
        XCTAssertEqual(IntegrityEventType.permissionsRevoked.severity, .critical)
        XCTAssertEqual(IntegrityEventType.limitExceeded.severity, .high)
        XCTAssertEqual(IntegrityEventType.emergencyAccess.severity, .high)
        XCTAssertEqual(IntegrityEventType.graceUsed.severity, .medium)
        XCTAssertEqual(IntegrityEventType.doneChosen.severity, .low)
    }

    func testIntegrityEventShouldNotifyPartner() {
        XCTAssertTrue(IntegrityEventType.limitExceeded.shouldNotifyPartner)
        XCTAssertTrue(IntegrityEventType.emergencyAccess.shouldNotifyPartner)
        XCTAssertTrue(IntegrityEventType.accountabilityDisabled.shouldNotifyPartner)
        XCTAssertFalse(IntegrityEventType.graceUsed.shouldNotifyPartner)
        XCTAssertFalse(IntegrityEventType.doneChosen.shouldNotifyPartner)
    }

    // MARK: - GraceSession Tests

    func testGraceSessionRemainingSeconds() {
        let startTime = Date()
        let session = GraceSession(startTime: startTime, durationMinutes: 2, limitId: UUID())

        XCTAssertFalse(session.isExpired)
        XCTAssertEqual(session.remainingSeconds, 120, accuracy: 1) // ~2 minutes
    }

    // MARK: - WeeklySummary Tests

    func testWeeklySummaryCalculations() {
        let records = [
            DailyRecord(withinAllLimits: true, doneChosenCount: 2, emergencyAccessCount: 0),
            DailyRecord(withinAllLimits: true, doneChosenCount: 1, emergencyAccessCount: 0),
            DailyRecord(withinAllLimits: false, doneChosenCount: 0, emergencyAccessCount: 1),
            DailyRecord(withinAllLimits: true, doneChosenCount: 3, emergencyAccessCount: 0)
        ]

        let summary = WeeklySummary(records: records, weekStartDate: Date())

        XCTAssertEqual(summary.daysWithinLimits, 3)
        XCTAssertEqual(summary.totalDoneChosen, 6)
        XCTAssertEqual(summary.totalEmergencyAccess, 1)
        XCTAssertEqual(summary.successRate, 0.75, accuracy: 0.01)
    }

    // MARK: - ContactMethod Tests

    func testContactMethodMasking() {
        let email = ContactMethod.email(address: "john@example.com")
        XCTAssertEqual(email.maskedDisplayValue, "j**n@example.com")

        let shortEmail = ContactMethod.email(address: "ab@x.com")
        XCTAssertEqual(shortEmail.maskedDisplayValue, "**@x.com")

        let phone = ContactMethod.sms(phoneNumber: "1234567890")
        XCTAssertEqual(phone.maskedDisplayValue, "***-***-7890")
    }
}
