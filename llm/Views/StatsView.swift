import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 20) {
                            StatCard(
                                title: "累计等待时长",
                                value: viewModel.formattedTotalTime(),
                                subtitle: "浪费的人生"
                            )

                            StatCard(
                                title: "平均响应时间",
                                value: viewModel.formattedAverageTime(),
                                subtitle: "对方的平均速度"
                            )

                            HStack(spacing: 0) {
                                Text("卑微指数: ")
                                    .font(.system(size: 24, design: .serif))
                                    .foregroundColor(.white)

                                Text("\(viewModel.simpIndex)")
                                    .font(.system(size: 36, weight: .bold, design: .serif))
                                    .foregroundColor(viewModel.simpIndex > 90 ? .red : .white)

                                Text(" / 100")
                                    .font(.system(size: 24, design: .serif))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.deadGrey.opacity(0.3))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(viewModel.simpIndex > 90 ? Color.red : Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal)

                            if viewModel.simpIndex > 90 {
                                Text("⚠️ 红色警报：建议立即停止卑微")
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("历史记录")
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            if viewModel.records.isEmpty {
                                Text("暂无记录")
                                    .font(.system(size: 16, design: .serif))
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 40)
                            } else {
                                ForEach(viewModel.records, id: \.id) { record in
                                    RecordRow(record: record, viewModel: viewModel)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("病历单")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadRecords(from: modelContext)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 16, design: .serif))
                .foregroundColor(.white.opacity(0.7))

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.system(size: 12, design: .serif))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deadGrey.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct RecordRow: View {
    let record: WaitingRecord
    let viewModel: StatsViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.startTime, style: .date)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.white)

                Text(record.startTime, style: .time)
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            HStack(spacing: 8) {
                Text(viewModel.formattedDuration(record.duration))
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(.white)

                if record.duration > 86400 {
                    Text("💀")
                        .font(.system(size: 20))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.deadGrey.opacity(0.2))
        )
        .padding(.horizontal)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: WaitingRecord.self, inMemory: true)
}
