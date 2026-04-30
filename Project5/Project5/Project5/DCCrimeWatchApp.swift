import SwiftUI
import FirebaseCore

@main
struct DCCrimeWatchApp: App {

    let persistence = PersistenceController.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
                .environment(\.managedObjectContext, persistence.context)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

struct RootView: View {

    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        switch authVM.authState {
        case .loading:
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 48))
                        .foregroundStyle(.red)
                    ProgressView()
                }
            }

        case .signedOut:
            LoginView()

        case .signedIn:
            ContentView()
        }
    }
}

struct ContentView: View {

    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var viewModel = CrimeViewModel()
    @StateObject private var bookmarks = BookmarkRepository()
    @State private var showSignOutConfirm = false

    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            IncidentListView()
                .tabItem {
                    Label("Incidents", systemImage: "list.bullet")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }

            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle.fill")
                }
        }
        .environmentObject(viewModel)
        .environmentObject(bookmarks)
        .task {
            await viewModel.loadIncidents()
        }
    }
}
