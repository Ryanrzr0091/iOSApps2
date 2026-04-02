import SwiftUI

struct NEODetailView: View {
    let neo: NearEarthObject

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    heroHeader

                    if neo.isPotentiallyHazardousAsteroid {
                        hazardBanner
                    }

                    sectionTitle("Size Estimate")
                    diameterCard

                    sectionTitle("Closest Approach")
                    if let approach = neo.firstCloseApproach {
                        approachCard(approach)
                    } else {
                        Text("No close approach data available.")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding(.horizontal)
                    }

                    sectionTitle("Brightness")
                    magnitudeCard

                    Link(destination: URL(string: neo.nasaJplUrl)!) {
                        HStack {
                            Image(systemName: "globe")
                            Text("View on NASA JPL")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                        .padding()
                        .background(Color.orange.opacity(0.12))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle(neo.cleanName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var heroHeader: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            neo.isPotentiallyHazardousAsteroid
                                ? Color.red.opacity(0.4) : Color.blue.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)

            Image(systemName: "circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.9), Color.gray.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .white.opacity(0.1), radius: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private var hazardBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text("Potentially Hazardous Asteroid")
                .font(.subheadline.bold())
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.25))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.5), lineWidth: 1)
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var diameterCard: some View {
        InfoCard {
            HStack {
                statBox(
                    label: "Min Diameter",
                    value: String(format: "%.1f m", neo.diameterMetersMin)
                )
                Divider().background(Color.gray.opacity(0.3))
                statBox(
                    label: "Max Diameter",
                    value: String(format: "%.1f m", neo.diameterMetersMax)
                )
            }
            .frame(height: 70)
        }
    }

    private func approachCard(_ approach: CloseApproachData) -> some View {
        InfoCard {
            VStack(spacing: 14) {
                detailRow(icon: "calendar",
                          label: "Date",
                          value: approach.closeApproachDate)
                Divider().background(Color.gray.opacity(0.15))
                detailRow(icon: "moon.fill",
                          label: "Miss Distance",
                          value: approach.missDistance.formattedLunar)
                Divider().background(Color.gray.opacity(0.15))
                detailRow(icon: "arrow.left.and.right",
                          label: "Distance (km)",
                          value: approach.missDistance.formattedKm)
                Divider().background(Color.gray.opacity(0.15))
                detailRow(icon: "speedometer",
                          label: "Velocity",
                          value: approach.relativeVelocity.formattedKmH)
                Divider().background(Color.gray.opacity(0.15))
                detailRow(icon: "globe",
                          label: "Orbiting",
                          value: approach.orbitingBody)
            }
        }
    }

    private var magnitudeCard: some View {
        InfoCard {
            detailRow(
                icon: "sun.max.fill",
                label: "Absolute Magnitude (H)",
                value: String(format: "%.2f", neo.absoluteMagnitudeH)
            )
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.bold())
            .foregroundColor(.orange)
            .tracking(1.5)
            .padding(.horizontal)
    }

    private func statBox(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .monospaced).bold())
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 20)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
    }
}


struct InfoCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal)
    }
}

#Preview {
    // Preview with mock data
    let mockApproach = CloseApproachData(
        closeApproachDate: "2024-04-10",
        relativeVelocity: RelativeVelocity(kilometersPerHour: "72340"),
        missDistance: MissDistance(kilometers: "4823000", lunar: "12.5"),
        orbitingBody: "Earth"
    )
    let mockDiameter = EstimatedDiameter(
        meters: DiameterRange(estimatedDiameterMin: 120.3, estimatedDiameterMax: 269.0)
    )
    let mockNEO = NearEarthObject(
        id: "3542519",
        name: "(2010 PK9)",
        nasaJplUrl: "https://ssd.jpl.nasa.gov/tools/sbdb_lookup.html#/?sstr=3542519",
        absoluteMagnitudeH: 19.7,
        estimatedDiameter: mockDiameter,
        isPotentiallyHazardousAsteroid: true,
        closeApproachData: [mockApproach]
    )

    NavigationStack {
        NEODetailView(neo: mockNEO)
    }
}
