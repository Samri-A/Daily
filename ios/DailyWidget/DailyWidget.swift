import WidgetKit
import SwiftUI

private let appGroupId = "group.com.example.myhabit"

struct TaskEntry: TimelineEntry {
    let date: Date
    let completedCount: Int
    let totalCount: Int
    let percentage: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), completedCount: 2, totalCount: 5, percentage: 40)
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        let timeline = Timeline(entries: [makeEntry()], policy: .atEnd)
        completion(timeline)
    }

    private func makeEntry() -> TaskEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let completed = defaults?.integer(forKey: "completedCount") ?? 0
        let total = defaults?.integer(forKey: "totalCount") ?? 0
        let pct = defaults?.integer(forKey: "percentage") ?? 0
        return TaskEntry(date: Date(), completedCount: completed, totalCount: total, percentage: pct)
    }
}

struct DailyWidgetEntryView: View {
    let entry: TaskEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Progress")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)

            ProgressView(value: Double(entry.percentage), total: 100)
                .tint(.black)
                .scaleEffect(x: 1, y: 2, anchor: .center)

            VStack(spacing: 4) {
                Text("\(entry.percentage)%")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)

                Text("\(entry.completedCount)/\(entry.totalCount) completed")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(Color.white)
        .widgetBackground(Color.white)
    }
}

extension View {
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(color, for: .widget)
        } else {
            self
        }
    }
}

@main
struct DailyWidget: Widget {
    let kind = "DailyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily")
        .description("Track your daily task progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
