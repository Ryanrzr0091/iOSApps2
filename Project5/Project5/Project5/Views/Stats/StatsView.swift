import SwiftUI
import Charts

struct StatsView: View {

    @EnvironmentObject private var viewModel: CrimeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCards
                    offenseChart
                    shiftChart
                    wardChart
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Total Incidents",
                value: "\(viewModel.totalCount)",
                icon: "exclamationmark.shield.fill",
                color: .red
            )
            StatCard(
                title: "Showing",
                value: "\(viewModel.filteredCount)",
                icon: "line.3.horizontal.decrease.circle.fill",
                color: .blue
            )
            StatCard(
                title: "Most Common",
                value: viewModel.offenseCounts.first?.offense.displayName ?? "—",
                icon: "chart.bar.fill",
                color: .orange
            )
            StatCard(
                title: "Peak Shift",
                value: viewModel.shiftCounts.max(by: { $0.count < $1.count })?.shift.displayName ?? "—",
                icon: "clock.fill",
                color: .purple
            )
        }
    }

    private var offenseChart: some View {
        ChartCard(title: "Incidents by Offense Type") {
            Chart(viewModel.offenseCounts, id: \.offense) { item in
                BarMark(
                    x: .value("Count", item.count),
                    y: .value("Offense", item.offense.displayName)
                )
                .foregroundStyle(by: .value("Offense", item.offense.displayName))
                .annotation(position: .trailing) {
                    Text("\(item.count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .chartLegend(.hidden)
            .frame(height: CGFloat(viewModel.offenseCounts.count) * 36)
        }
    }

    private var shiftChart: some View {
        ChartCard(title: "Incidents by Shift") {
            Chart(viewModel.shiftCounts, id: \.shift) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Shift", item.shift.displayName))
                .annotation(position: .overlay) {
                    Text("\(item.count)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
            }
            .frame(height: 220)

            HStack(spacing: 16) {
                ForEach(viewModel.shiftCounts, id: \.shift) { item in
                    HStack(spacing: 4) {
                        Image(systemName: item.shift.icon)
                            .font(.caption)
                        Text(item.shift.displayName)
                            .font(.caption)
                    }
                }
            }
            .foregroundStyle(.secondary)
            .padding(.top, 4)
        }
    }

    private var wardChart: some View {
        ChartCard(title: "Incidents by Ward") {
            Chart(viewModel.wardCounts, id: \.ward) { item in
                BarMark(
                    x: .value("Ward", "Ward \(item.ward)"),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(.blue.gradient)
                .annotation(position: .top) {
                    Text("\(item.count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 200)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.title2.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
