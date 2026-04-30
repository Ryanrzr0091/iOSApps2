import SwiftUI

struct FilterView: View {

    @EnvironmentObject private var viewModel: CrimeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                offenseSection
                shiftSection
                wardSection
            }
            .navigationTitle("Filter Incidents")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.resetFilters()
                    }
                    .foregroundStyle(.red)
                    .disabled(!viewModel.filter.isActive)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var offenseSection: some View {
        Section("Offense Type") {
            ForEach(CrimeIncident.OffenseType.allCases.filter { $0 != .unknown }, id: \.self) { offense in
                Toggle(isOn: Binding(
                    get: { viewModel.filter.offenseTypes.contains(offense) },
                    set: { isOn in
                        if isOn {
                            viewModel.filter.offenseTypes.insert(offense)
                        } else {
                            viewModel.filter.offenseTypes.remove(offense)
                        }
                    }
                )) {
                    Label(offense.displayName, systemImage: offense.icon)
                }
            }
        }
    }

    private var shiftSection: some View {
        Section("Shift") {
            ForEach(CrimeIncident.Shift.allCases.filter { $0 != .unknown }, id: \.self) { shift in
                Toggle(isOn: Binding(
                    get: { viewModel.filter.shifts.contains(shift) },
                    set: { isOn in
                        if isOn {
                            viewModel.filter.shifts.insert(shift)
                        } else {
                            viewModel.filter.shifts.remove(shift)
                        }
                    }
                )) {
                    Label(shift.displayName, systemImage: shift.icon)
                }
            }
        }
    }

    private var wardSection: some View {
        Section("Ward") {
            ForEach(viewModel.availableWards, id: \.self) { ward in
                Toggle(isOn: Binding(
                    get: { viewModel.filter.wards.contains(ward) },
                    set: { isOn in
                        if isOn {
                            viewModel.filter.wards.insert(ward)
                        } else {
                            viewModel.filter.wards.remove(ward)
                        }
                    }
                )) {
                    Text("Ward \(ward)")
                }
            }
        }
    }
}
