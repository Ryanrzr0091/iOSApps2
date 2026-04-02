import Foundation
import Combine

class NEOViewModel: ObservableObject {

    @Published var neos: [NearEarthObject] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let service = NEOService()

    @MainActor
    func loadNEOs() async {
        isLoading = true
        errorMessage = nil

        do {
            neos = try await service.fetchNEOs()
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    var hazardousCount: Int {
        neos.filter { $0.isPotentiallyHazardousAsteroid }.count
    }

    var totalCount: Int {
        neos.count
    }
}
