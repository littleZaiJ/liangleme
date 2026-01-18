import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Label("停尸房", systemImage: "timer")
                }

            StatsView()
                .tabItem {
                    Label("病历单", systemImage: "chart.bar")
                }

            AnalysisView()
                .tabItem {
                    Label("尸检科", systemImage: "doc.text.magnifyingglass")
                }
        }
        .tint(.white)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WaitingRecord.self, inMemory: true)
}
