import SwiftUI

struct AccountView: View {

    @EnvironmentObject private var authVM: AuthViewModel
    @State private var showSignOutConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.15))
                                .frame(width: 52, height: 52)
                            Text(initials)
                                .font(.title3.bold())
                                .foregroundStyle(.red)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(authVM.currentUserEmail ?? "Unknown")
                                .font(.subheadline.weight(.medium))
                                .lineLimit(1)
                            Text("DC Crime Watch Member")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("About") {
                    LabeledContent("Data Source", value: "DC Open Data / MPD")
                    LabeledContent("Coverage", value: "Last 30 days")
                    LabeledContent("Version", value: "1.0.0")
                }

                Section {
                    Button(role: .destructive) {
                        showSignOutConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Account")
            .confirmationDialog(
                "Sign Out",
                isPresented: $showSignOutConfirm,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    authVM.signOut()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }

    private var initials: String {
        guard let email = authVM.currentUserEmail,
              let first = email.first else { return "?" }
        return String(first).uppercased()
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthViewModel())
}
