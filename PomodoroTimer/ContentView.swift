//
//  ContentView.swift
//  PomodoroTimer
//
//  Created by 程信傑 on 2025/2/17.
//

import Combine
import SwiftUI
import WidgetKit

// App主要介面
struct ContentView: View {
    @State private var timer = PomodoroTimer.defaultTimer
    @State private var timeRemaining: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerCancellable: Cancellable?

    var body: some View {
        VStack {
            Text(timeString(from: timer.remainingSeconds))
                .font(.system(size: 48, weight: .bold))

            HStack(spacing: 20) {
                Button(action: toggleTimer) {
                    Image(systemName: timer.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }

                Button(action: resetTimer) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 44))
                }
            }
        }
        .onAppear(perform: setupTimer)
        .onChange(of: timer.isRunning) { isRunning in
            if isRunning {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }

    private func setupTimer() {
        // 設置通知權限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            // 處理授權結果
        }
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timer.remainingSeconds > 0 {
                    timer.remainingSeconds -= 1
                    saveTimer()
                } else {
                    timer.isRunning = false
                    notifyCompletion()
                }
            }
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private func toggleTimer() {
        timer.isRunning.toggle()
        saveTimer()
    }

    private func resetTimer() {
        timer = PomodoroTimer.defaultTimer
        saveTimer()
    }

    private func stopTimer() {
        timerCancellable?.cancel()
    }

    private func notifyCompletion() {
        let content = UNMutableNotificationContent()
        content.title = "番茄鐘完成"
        content.body = "休息一下吧！"
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func saveTimer() {
        if let data = try? JSONEncoder().encode(timer) {
            UserDefaults.group.set(data, forKey: "PomodoroTimer")
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    ContentView()
}
