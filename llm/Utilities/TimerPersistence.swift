import Foundation

struct TimerState: Codable {
    let recordId: UUID
    let startTime: Date
    let isRunning: Bool
}

class TimerPersistence {
    private static let key = "currentTimerState"

    static func saveTimerState(_ state: TimerState) {
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    static func loadTimerState() -> TimerState? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let state = try? JSONDecoder().decode(TimerState.self, from: data) else {
            return nil
        }
        return state
    }

    static func clearTimerState() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
