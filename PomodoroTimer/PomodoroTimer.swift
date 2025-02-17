//
//  PomodoroTimer.swift
//  PomodoroTimer
//
//  Created by 程信傑 on 2025/2/17.
//

import Foundation
import SwiftUI

// 番茄鐘的狀態模型
struct PomodoroTimer: Codable {
    var isRunning: Bool
    var remainingSeconds: Int
    var totalSeconds: Int

    static let defaultTimer = PomodoroTimer(isRunning: false, remainingSeconds: 1500, totalSeconds: 1500)
}

extension UserDefaults {
    static var group: UserDefaults {
        UserDefaults(suiteName: "group.com.example.pomodorotimer")!
    }
}

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                print("通知權限已獲得")
            }
        }
    }

    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "番茄鐘完成"
        content.body = "休息一下吧！"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
