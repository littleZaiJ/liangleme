import Foundation
import SwiftUI
import SwiftData

@Observable
class TimerViewModel {
    var isRunning = false
    var elapsedTime: TimeInterval = 0
    var currentQuote = SarcasticQuotes.random()
    var currentRecord: WaitingRecord?
    var showRestoreAlert = false

    private var timer: Timer?
    private var quoteTimer: Timer?
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        checkForUnfinishedTimer()
    }

    // 检查是否有未完成的计时
    func checkForUnfinishedTimer() {
        guard let savedState = TimerPersistence.loadTimerState() else { return }

        // 如果有保存的计时状态，显示恢复提示
        if savedState.isRunning {
            showRestoreAlert = true
        }
    }

    // 恢复之前的计时
    func restoreTimer() {
        guard let savedState = TimerPersistence.loadTimerState(),
              let context = modelContext else { return }

        // 从数据库中查找对应的记录
        let descriptor = FetchDescriptor<WaitingRecord>(
            predicate: #Predicate { record in
                record.id == savedState.recordId && record.endTime == nil
            }
        )

        do {
            let records = try context.fetch(descriptor)
            if let record = records.first {
                currentRecord = record
                elapsedTime = Date().timeIntervalSince(savedState.startTime)
                isRunning = true

                startTimers()
            }
        } catch {
            print("Failed to restore timer: \(error)")
        }
    }

    // 放弃恢复，标记为已完成
    func discardUnfinishedTimer() {
        guard let savedState = TimerPersistence.loadTimerState(),
              let context = modelContext else { return }

        let descriptor = FetchDescriptor<WaitingRecord>(
            predicate: #Predicate { record in
                record.id == savedState.recordId && record.endTime == nil
            }
        )

        do {
            let records = try context.fetch(descriptor)
            if let record = records.first {
                // 标记为在app被杀时结束
                record.endTime = Date()
                try? context.save()
            }
        } catch {
            print("Failed to discard timer: \(error)")
        }

        TimerPersistence.clearTimerState()
    }

    func startTimer() {
        guard !isRunning else { return }

        isRunning = true
        currentRecord = WaitingRecord()

        if let context = modelContext {
            context.insert(currentRecord!)
            try? context.save()
        }

        // 保存计时状态
        if let record = currentRecord {
            let state = TimerState(
                recordId: record.id,
                startTime: record.startTime,
                isRunning: true
            )
            TimerPersistence.saveTimerState(state)
        }

        startTimers()
    }

    private func startTimers() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1

            // 定期更新持久化状态（每10秒）
            if Int(self.elapsedTime) % 10 == 0 {
                self.updatePersistedState()
            }
        }

        quoteTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.currentQuote = SarcasticQuotes.random()
        }
    }

    private func updatePersistedState() {
        guard let record = currentRecord else { return }
        let state = TimerState(
            recordId: record.id,
            startTime: record.startTime,
            isRunning: isRunning
        )
        TimerPersistence.saveTimerState(state)
    }

    func stopTimer() {
        guard isRunning else { return }

        timer?.invalidate()
        quoteTimer?.invalidate()
        timer = nil
        quoteTimer = nil

        currentRecord?.endTime = Date()

        if let context = modelContext {
            try? context.save()
        }

        // 清除保存的状态
        TimerPersistence.clearTimerState()

        isRunning = false
        elapsedTime = 0
        currentRecord = nil
        currentQuote = SarcasticQuotes.random()
    }

    func backgroundColor() -> Color {
        return Color.backgroundForElapsedTime(elapsedTime)
    }

    func formattedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
