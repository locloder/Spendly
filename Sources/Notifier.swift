import UserNotifications

enum Notifier {
    static func requestAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Ежемесячное напоминание в 9:00 за N дней до списания.
    static func schedule(_ s: Subscription) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [s.uid])

        let content = UNMutableNotificationContent()
        content.title = "Скоро списание: \(s.name)"
        content.body = s.remindDaysBefore == 0
            ? "Сегодня спишется \(s.price.money)"
            : "Через \(s.remindDaysBefore) дн. спишется \(s.price.money)"
        content.sound = .default

        var d = DateComponents()
        d.day = (s.billingDay - s.remindDaysBefore - 1 + 28) % 28 + 1
        d.hour = 9
        let trigger = UNCalendarNotificationTrigger(dateMatching: d, repeats: true)
        center.add(UNNotificationRequest(identifier: s.uid, content: content, trigger: trigger))
    }

    static func cancel(_ s: Subscription) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [s.uid])
    }
}
