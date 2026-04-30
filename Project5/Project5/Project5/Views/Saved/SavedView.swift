import SwiftUI
import CoreData

struct SavedView: View {

    @EnvironmentObject private var bookmarks: BookmarkRepository
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedIncident.savedDate, ascending: false)],
        animation: .default
    )
    private var savedIncidents: FetchedResults<SavedIncident>

    var body: some View {
        NavigationStack {
            Group {
                if savedIncidents.isEmpty {
                    emptyState
                } else {
                    savedList
                }
            }
            .navigationTitle("Saved")
        }
    }

    private var savedList: some View {
        List {
            ForEach(savedIncidents) { saved in
                SavedRowView(saved: saved)
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No Saved Incidents")
                .font(.headline)
            Text("Tap the bookmark icon on any incident to save it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        offsets.forEach { index in
            let item = savedIncidents[index]
            if let id = item.id {
                bookmarks.removeByID(id)
            }
            context.delete(item)
        }
        try? context.save()
    }
}

struct SavedRowView: View {
    let saved: SavedIncident

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(saved.offense ?? "Unknown Offense")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "bookmark.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }

            Text(saved.block ?? "Unknown Block")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if saved.ward > 0 {
                    Label("Ward \(saved.ward)", systemImage: "mappin.circle")
                }
                if let date = saved.reportDate {
                    Label(Self.dateFormatter.string(from: date), systemImage: "calendar")
                }
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)

            if let savedDate = saved.savedDate {
                Text("Saved \(Self.dateFormatter.string(from: savedDate))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
