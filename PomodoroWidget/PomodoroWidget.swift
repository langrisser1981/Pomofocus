//
//  PomodoroWidget.swift
//  PomodoroWidget
//
//  Created by 程信傑 on 2025/2/17.
//

import SwiftUI
import WidgetKit

// 設定Widget Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), timer: .defaultTimer)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), timer: .defaultTimer)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let timer = getCurrentTimer() // 從UserDefaults獲取當前計時器狀態

        // 每秒更新一次Widget
        for offset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .second, value: offset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, timer: timer)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func getCurrentTimer() -> PomodoroTimer {
        // 從UserDefaults讀取計時器狀態
        if let data = UserDefaults.group.data(forKey: "PomodoroTimer"),
           let timer = try? JSONDecoder().decode(PomodoroTimer.self, from: data)
        {
            return timer
        }
        return .defaultTimer
    }
}

// 定義Widget的Entry結構
struct SimpleEntry: TimelineEntry {
    let date: Date
    let timer: PomodoroTimer
}

// Widget的主視圖
struct PomodoroWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(timeString(from: entry.timer.remainingSeconds))
                .font(.system(size: 32, weight: .bold))

            HStack {
                Button(action: toggleTimer) {
                    Image(systemName: entry.timer.isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                }

                Button(action: resetTimer) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                }
            }
        }
        .padding()
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private func toggleTimer() {
        var timer = entry.timer
        timer.isRunning.toggle()
        saveTimer(timer)
    }

    private func resetTimer() {
        let timer = PomodoroTimer.defaultTimer
        saveTimer(timer)
    }

    private func saveTimer(_ timer: PomodoroTimer) {
        if let data = try? JSONEncoder().encode(timer) {
            UserDefaults.group.set(data, forKey: "PomodoroTimer")
        }
    }
}

// Widget配置
struct PomodoroWidget: Widget {
    let kind: String = "PomodoroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PomodoroWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PomodoroWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("番茄鐘")
        .description("在桌面上管理你的番茄鐘")
//        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    PomodoroWidget()
} timeline: {
    SimpleEntry(date: Date(), timer: .defaultTimer)
    SimpleEntry(date: Date(), timer: .defaultTimer)
}
