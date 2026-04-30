import Foundation
import Combine
import CoreLocation

struct CrimeFilter {
    var offenseTypes: Set<CrimeIncident.OffenseType> = []
    var shifts: Set<CrimeIncident.Shift>             = []
    var wards: Set<Int>                              = []
    var searchText: String                           = ""

    var isActive: Bool {
        !offenseTypes.isEmpty || !shifts.isEmpty || !wards.isEmpty || !searchText.isEmpty
    }

    mutating func reset() {
        offenseTypes = []
        shifts       = []
        wards        = []
        searchText   = ""
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case dateDesc  = "Newest First"
    case dateAsc   = "Oldest First"
    case offense   = "Offense Type"
    case ward      = "Ward"

    var id: String { rawValue }
}

enum ViewState {
    case idle
    case loading
    case loaded
    case error(String)
}

final class CrimeViewModel: ObservableObject {

    @Published private(set) var incidents: [CrimeIncident] = []
    @Published private(set) var filteredIncidents: [CrimeIncident] = []
    @Published private(set) var viewState: ViewState = .idle

    @Published var filter = CrimeFilter()
    @Published var sortOption: SortOption = .dateDesc
    @Published var selectedIncident: CrimeIncident?

    var offenseCounts: [(offense: CrimeIncident.OffenseType, count: Int)] {
        let grouped = Dictionary(grouping: incidents, by: \.offense)
        return grouped.map { ($0.key, $0.value.count) }
                      .sorted { $0.count > $1.count }
    }

    var shiftCounts: [(shift: CrimeIncident.Shift, count: Int)] {
        let grouped = Dictionary(grouping: incidents, by: \.shift)
        return CrimeIncident.Shift.allCases.compactMap { shift in
            guard let count = grouped[shift]?.count, count > 0 else { return nil }
            return (shift, count)
        }
    }

    var wardCounts: [(ward: Int, count: Int)] {
        let grouped = Dictionary(grouping: incidents, by: \.ward)
        return grouped.map { ($0.key, $0.value.count) }
                      .filter { $0.ward > 0 }
                      .sorted { $0.ward < $1.ward }
    }

    var availableWards: [Int] {
        Array(Set(incidents.map(\.ward))).filter { $0 > 0 }.sorted()
    }

    var totalCount: Int { incidents.count }
    var filteredCount: Int { filteredIncidents.count }

    private let service: CrimeServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(service: CrimeServiceProtocol = CrimeService()) {
        self.service = service
        setupFilterPipeline()
    }

    func loadIncidents() async {
        await MainActor.run { viewState = .loading }
        do {
            let data = try await service.fetchRecentCrimes(limit: 500)
            await MainActor.run {
                incidents = data
                viewState = .loaded
            }
        } catch {
            await MainActor.run { viewState = .error(error.localizedDescription) }
        }
    }

    func refresh() async {
        await loadIncidents()
    }

    private func setupFilterPipeline() {
        Publishers.CombineLatest3(
            $incidents,
            $filter,
            $sortOption
        )
        .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
        .map { [weak self] incidents, filter, sort in
            self?.applyFiltersAndSort(to: incidents, filter: filter, sort: sort) ?? []
        }
        .assign(to: &$filteredIncidents)
    }

    private func applyFiltersAndSort(
        to incidents: [CrimeIncident],
        filter: CrimeFilter,
        sort: SortOption
    ) -> [CrimeIncident] {
        var result = incidents

        if !filter.offenseTypes.isEmpty {
            result = result.filter { filter.offenseTypes.contains($0.offense) }
        }

        if !filter.shifts.isEmpty {
            result = result.filter { filter.shifts.contains($0.shift) }
        }

        if !filter.wards.isEmpty {
            result = result.filter { filter.wards.contains($0.ward) }
        }

        if !filter.searchText.isEmpty {
            let query = filter.searchText.lowercased()
            result = result.filter {
                $0.block.lowercased().contains(query) ||
                $0.offense.displayName.lowercased().contains(query) ||
                $0.neighborhoodCluster.lowercased().contains(query)
            }
        }

        switch sort {
        case .dateDesc:  result.sort { $0.reportDate > $1.reportDate }
        case .dateAsc:   result.sort { $0.reportDate < $1.reportDate }
        case .offense:   result.sort { $0.offense.displayName < $1.offense.displayName }
        case .ward:      result.sort { $0.ward < $1.ward }
        }

        return result
    }

    func resetFilters() {
        filter.reset()
    }
}
