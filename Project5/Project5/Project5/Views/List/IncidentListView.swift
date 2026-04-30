import SwiftUI

struct IncidentListView: View {

    @EnvironmentObject private var viewModel: CrimeViewModel
    @EnvironmentObject private var bookmarks: BookmarkRepository

    @State private var showFilterSheet = false

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .loading:
                    loadingView
                case .error(let msg):
                    errorView(msg)
                default:
                    listContent
                }
            }
            .navigationTitle("Incidents")
            .searchable(text: $viewModel.filter.searchText, prompt: "Search block, offense...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    sortMenu
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterView()
                    .environmentObject(viewModel)
            }
        }
    }

    private var listContent: some View {
        List(viewModel.filteredIncidents) { incident in
            NavigationLink {
                IncidentDetailView(incident: incident)
                    .environmentObject(bookmarks)
            } label: {
                IncidentRowView(incident: incident)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.filteredIncidents.isEmpty {
                emptyState
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Fetching latest incidents...")
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundStyle(.red)
            Text("Failed to load data")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await viewModel.refresh() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No incidents match your filters")
                .foregroundStyle(.secondary)
            Button("Clear Filters") {
                viewModel.resetFilters()
            }
            .buttonStyle(.bordered)
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort by", selection: $viewModel.sortOption) {
                ForEach(SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }

    private var filterButton: some View {
        Button {
            showFilterSheet = true
        } label: {
            Image(systemName: viewModel.filter.isActive
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
                .foregroundStyle(viewModel.filter.isActive ? .red : .accentColor)
        }
    }
}

struct IncidentRowView: View {
    let incident: CrimeIncident

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(offenseColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: incident.offense.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(offenseColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(incident.offense.displayName)
                    .font(.subheadline.weight(.semibold))
                Text(incident.block)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Label(incident.shift.displayName, systemImage: incident.shift.icon)
                    Text("·")
                    Text("Ward \(incident.ward)")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(Self.dateFormatter.string(from: incident.reportDate))
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }

    private var offenseColor: Color {
        switch incident.offense {
        case .theft, .theftFromAuto: return .blue
        case .motorVehicle:          return .cyan
        case .assault:               return .orange
        case .burglary:              return .yellow
        case .robbery:               return .red
        case .arson:                 return .purple
        case .homicide:              return .black
        case .sexAbuse:              return .pink
        case .unknown:               return .gray
        }
    }
}
