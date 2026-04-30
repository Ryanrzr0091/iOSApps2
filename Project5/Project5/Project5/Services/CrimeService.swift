import Foundation

enum CrimeServiceError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "Invalid API URL."
        case .networkError(let e):  return "Network error: \(e.localizedDescription)"
        case .decodingError(let e): return "Failed to decode response: \(e.localizedDescription)"
        case .noData:               return "No data returned from server."
        }
    }
}

protocol CrimeServiceProtocol {
    func fetchRecentCrimes(limit: Int) async throws -> [CrimeIncident]
    func fetchCrimes(where clause: String, limit: Int) async throws -> [CrimeIncident]
}

final class CrimeService: CrimeServiceProtocol {

    private let baseURL = "https://maps2.dcgis.dc.gov/dcgis/rest/services/FEEDS/MPD/MapServer/2/query"

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchRecentCrimes(limit: Int = 500) async throws -> [CrimeIncident] {
        try await fetchCrimes(where: "1=1", limit: limit)
    }

    func fetchCrimes(where clause: String = "1=1", limit: Int = 500) async throws -> [CrimeIncident] {
        let url = try buildURL(whereClause: clause, limit: limit)
        let data = try await performRequest(url: url)
        let incidents = try decode(data: data)
        return incidents
    }

    private func buildURL(whereClause: String, limit: Int) throws -> URL {
        var components = URLComponents(string: baseURL)

        components?.queryItems = [
            URLQueryItem(name: "where",           value: whereClause),
            URLQueryItem(name: "outFields",       value: "*"),
            URLQueryItem(name: "f",               value: "json"),
            URLQueryItem(name: "resultRecordCount", value: "\(limit)"),
            URLQueryItem(name: "orderByFields",   value: "REPORT_DAT DESC")
        ]

        guard let url = components?.url else {
            throw CrimeServiceError.invalidURL
        }
        return url
    }

    private func performRequest(url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw CrimeServiceError.noData
            }
            return data
        } catch let error as CrimeServiceError {
            throw error
        } catch {
            throw CrimeServiceError.networkError(error)
        }
    }

    private func decode(data: Data) throws -> [CrimeIncident] {
        do {
            let response = try JSONDecoder().decode(CrimeResponse.self, from: data)
            return response.features.compactMap { CrimeIncident.from(feature: $0) }
        } catch {
            throw CrimeServiceError.decodingError(error)
        }
    }
}
