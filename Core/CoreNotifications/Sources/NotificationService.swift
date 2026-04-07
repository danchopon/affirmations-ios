import Foundation
import UserNotifications
import OSLog

private let logger = Logger(subsystem: "com.affirmations", category: "Notifications")

public final class NotificationService: Sendable {
    public static let shared = NotificationService()
    private init() {}

    public func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            logger.error("Notification permission request failed: \(error)")
            return false
        }
    }

    public func scheduleDailyReminder(at time: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Time for your check-in"
        content.body = "How are you feeling today?"
        content.sound = .default

        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_checkin", content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            logger.info("Daily reminder scheduled at \(components.hour ?? 0):\(String(format: "%02d", components.minute ?? 0))")
        } catch {
            logger.error("Failed to schedule reminder: \(error)")
        }
    }

    public func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_checkin"])
    }
}
