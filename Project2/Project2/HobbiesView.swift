import SwiftUI

struct HobbiesView: View {

    @EnvironmentObject var favorites: FavoritesViewModel
    @Binding var searchText: String

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(favorites.filteredHobbies(searchText: searchText)) { hobby in
                    HobbyRowView(hobby: hobby)
                }
            }
            .padding()
        }
    }
}

#Preview {
    HobbiesView(searchText: .constant(""))
        .environmentObject(FavoritesViewModel())
}
