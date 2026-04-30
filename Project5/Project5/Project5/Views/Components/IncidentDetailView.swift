import SwiftUI
import MapKit

struct IncidentDetailView: View {

    let incident: CrimeIncident
    @EnvironmentObject private var bookmarks: BookmarkRepository
    @Environment(\.dismiss) private var dismiss

    @State private var region: MKCoordinateRegion

    init(incident: CrimeIncident) {
        self.incident = incident
        _region = State(initialValue: MKCoordinateRegion(
            center: incident.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    miniMap
                    detailGrid
                    incidentMeta
                }
                .padding()
            }
            .navigationTitle(incident.offense.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    bookmarkButton
                }
            }
        }
    }

    private var miniMap: some View {
        Map(coordinateRegion: $region, annotationItems: [incident]) { item in
            MapAnnotation(coordinate: item.coordinate) {
                CrimePinView(offense: item.offense)
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .allowsHitTesting(false)
    }

    private var detailGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            DetailCell(label: "Block", value: incident.block, icon: "mappin.circle.fill")
            DetailCell(label: "Ward", value: "Ward \(incident.ward)", icon: "building.2.fill")
            DetailCell(label: "Shift", value: incident.shift.displayName, icon: incident.shift.icon)
            DetailCell(label: "Method", value: incident.method.displayName, icon: "exclamationmark.circle.fill")
        }
    }

    private var incidentMeta: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()

            DetailRow(label: "Report Date", value: Self.dateFormatter.string(from: incident.reportDate))
            DetailRow(label: "Incident ID", value: incident.id)
            DetailRow(label: "Neighborhood", value: incident.neighborhoodCluster)
        }
    }

    private var bookmarkButton: some View {
        Button {
            bookmarks.toggle(incident)
        } label: {
            Image(systemName: bookmarks.isSaved(incident) ? "bookmark.fill" : "bookmark")
                .foregroundStyle(bookmarks.isSaved(incident) ? .yellow : .accentColor)
        }
    }
}

struct DetailCell: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.medium))
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}
