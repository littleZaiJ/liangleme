import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TimerViewModel()
    @State private var showingStopAlert = false

    var body: some View {
        ZStack {
            viewModel.backgroundColor()
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: viewModel.elapsedTime)

            VStack(spacing: 50) {
                Text(viewModel.currentQuote)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 60)

                Spacer()

                if viewModel.isRunning {
                    Text(viewModel.formattedTime())
                        .font(.system(size: 72, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }

                Button(action: {
                    if viewModel.isRunning {
                        showingStopAlert = true
                    } else {
                        viewModel.startTimer()
                    }
                }) {
                    Text(viewModel.isRunning ? "对方已回，结束卑微" : "消息已发，开始卑微")
                        .font(.system(size: 20, design: .serif))
                        .foregroundColor(.white)
                        .padding(.vertical, 30)
                        .padding(.horizontal, 40)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 280, height: 280)
                        )
                }
                .frame(width: 280, height: 280)

                Spacer()
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        .alert("确认对方回消息了吗？", isPresented: $showingStopAlert) {
            Button("取消", role: .cancel) { }
            Button("确认") {
                viewModel.stopTimer()
            }
        } message: {
            Text("停止计时后，数据将被记录")
        }
        .alert("发现未完成的计时", isPresented: $viewModel.showRestoreAlert) {
            Button("继续计时") {
                viewModel.restoreTimer()
            }
            Button("放弃", role: .destructive) {
                viewModel.discardUnfinishedTimer()
            }
        } message: {
            Text("检测到上次app被关闭时有正在进行的计时，是否继续？")
        }
    }
}

#Preview {
    TimerView()
        .modelContainer(for: WaitingRecord.self, inMemory: true)
}
