import Foundation
import SwiftData

@Observable
class StatsViewModel {
    var records: [WaitingRecord] = []

    var totalWastedTime: TimeInterval {
        records.reduce(0) { $0 + $1.duration }
    }

    var averageResponseTime: TimeInterval {
        guard !records.isEmpty else { return 0 }
        return totalWastedTime / Double(records.count)
    }

    var simpIndex: Int {
        let averageHours = averageResponseTime / 3600
        return min(100, Int(averageHours * 10))
    }

    func formattedTotalTime() -> String {
        let hours = Int(totalWastedTime) / 3600
        let minutes = Int(totalWastedTime) / 60 % 60
        return "\(hours)小时 \(minutes)分钟"
    }

    func formattedAverageTime() -> String {
        let hours = Int(averageResponseTime) / 3600
        let minutes = Int(averageResponseTime) / 60 % 60
        return "\(hours)小时 \(minutes)分钟"
    }

    func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return "\(hours)小时 \(minutes)分钟"
        } else if minutes > 0 {
            return "\(minutes)分钟 \(seconds)秒"
        } else {
            return "\(seconds)秒"
        }
    }

    func loadRecords(from context: ModelContext) {
        let descriptor = FetchDescriptor<WaitingRecord>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )

        do {
            records = try context.fetch(descriptor).filter { $0.endTime != nil }
        } catch {
            print("Failed to fetch records: \(error)")
            records = []
        }
    }
}
