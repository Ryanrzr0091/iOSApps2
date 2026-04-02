import Foundation

class NEOService {

    private let apiKey = "YAGt3gffyLSxgDXT56gYlG7LbESvGhSlD2IeYR8L"
    private let baseURL = "https://api.nasa.gov/neo/rest/v1/feed"

    func fetchNEOs() async throws -> [NearEarthObject] {
        let today = formattedDate(Date())
        let nextWeek = formattedDate(Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date())

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "start_date", value: today),
            URLQueryItem(name: "end_date",   value: nextWeek),
            URLQueryItem(name: "api_key",    value: apiKey)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(NASANeoResponse.self, from: data)

        let allNEOs = decoded.nearEarthObjects.values.flatMap { $0 }
        return allNEOs.sorted {
            if $0.isPotentiallyHazardousAsteroid != $1.isPotentiallyHazardousAsteroid {
                return $0.isPotentiallyHazardousAsteroid
            }
            let d0 = Double($0.firstCloseApproach?.missDistance.kilometers ?? "0") ?? 0
            let d1 = Double($1.firstCloseApproach?.missDistance.kilometers ?? "0") ?? 0
            return d0 < d1
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
