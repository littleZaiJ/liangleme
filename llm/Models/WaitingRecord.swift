import Foundation
import SwiftData

@Model
final class WaitingRecord {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var targetName: String

    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }

    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil, targetName: String = "The One") {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.targetName = targetName
    }
}
