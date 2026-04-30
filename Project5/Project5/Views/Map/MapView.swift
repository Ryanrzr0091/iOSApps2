import SwiftUI
import MapKit

struct CrimeAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let incident: CrimeIncident
}

struct MapView: View {

    @EnvironmentObject private var viewModel: CrimeViewModel
    @EnvironmentObject private var bookmarks: BookmarkRepository

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369),
        span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    )

    @State private var selectedAnnotation: CrimeAnnotation?
    @State private var showDetailSheet = false
    @State private var showFilterSheet = false

    private var annotations: [CrimeAnnotation] {
        viewModel.filteredIncidents.map {
            CrimeAnnotation(id: $0.id, coordinate: $0.coordinate, incident: $0)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                map
                filterButton
            }
            .navigationTitle("DC Crime Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    statusBadge
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedAnnotation) { annotation in
                IncidentDetailView(incident: annotation.incident)
                    .environmentObject(bookmarks)
                    .presentationDetents([.medium])
            }
        }
    }

    private var map: some View {
        Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                CrimePinView(offense: annotation.incident.offense)
                    .onTapGesture {
                        selectedAnnotation = annotation
                    }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .overlay(loadingOverlay)
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if case .loading = viewModel.viewState {
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading incidents...")
                        .font(.caption)
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 100)
            }
        }
    }

    private var filterButton: some View {
        Button {
            showFilterSheet = true
        } label: {
            Image(systemName: viewModel.filter.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .font(.title2)
                .foregroundStyle(viewModel.filter.isActive ? .red : .accentColor)
                .padding(14)
                .background(.ultraThinMaterial, in: Circle())
        }
        .padding(.trailing, 16)
        .padding(.bottom, 90)
    }

    private var statusBadge: some View {
        Text("\(viewModel.filteredCount) incidents")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

struct CrimePinView: View {
    let offense: CrimeIncident.OffenseType

    var body: some View {
        ZStack {
            Circle()
                .fill(pinColor.opacity(0.25))
                .frame(width: 28, height: 28)
            Circle()
                .fill(pinColor)
                .frame(width: 14, height: 14)
                .shadow(color: pinColor.opacity(0.5), radius: 3)
        }
    }

    private var pinColor: Color {
        switch offense {
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
