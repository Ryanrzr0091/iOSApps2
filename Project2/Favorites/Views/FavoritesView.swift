import SwiftUI

struct FavoritesView: View {

    @EnvironmentObject private var favorites: FavoritesViewModel

    var favoriteCities: [CityModel] {
        favorites.cities.filter { $0.isFavorite }
    }

    var favoriteHobbies: [HobbyModel] {
        favorites.hobbies.filter { $0.isFavorite }
    }

    var favoriteBooks: [BookModel] {
        favorites.books.filter { $0.isFavorite }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favoriteCities.isEmpty && favoriteHobbies.isEmpty && favoriteBooks.isEmpty {
                    ContentUnavailableView(
                        "No Favorites Yet",
                        systemImage: "star",
                        description: Text("Tap the heart on any city, hobby, or book to save it here.")
                    )
                } else {
                    List {
                        if !favoriteCities.isEmpty {
                            Section("Cities") {
                                ForEach(favoriteCities) { city in
                                    HStack {
                                        Image(city.cityImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 44, height: 44)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        Text(city.cityName)
                                            .font(.body)
                                        Spacer()
                                        Button(action: {
                                            favorites.toggleFavoriteCity(city: city)
                                        }) {
                                            Image(systemName: "heart.fill")
                                                .foregroundStyle(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        if !favoriteHobbies.isEmpty {
                            Section("Hobbies") {
                                ForEach(favoriteHobbies) { hobby in
                                    HStack {
                                        Text(hobby.hobbyIcon)
                                            .font(.title2)
                                        Text(hobby.hobbyName)
                                            .font(.body)
                                        Spacer()
                                        Button(action: {
                                            favorites.toggleFavoriteHobby(hobby: hobby)
                                        }) {
                                            Image(systemName: "heart.fill")
                                                .foregroundStyle(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        if !favoriteBooks.isEmpty {
                            Section("Books") {
                                ForEach(favoriteBooks) { book in
                                    HStack {
                                        Text("📖")
                                            .font(.title2)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(book.bookTitle)
                                                .font(.body)
                                            Text(book.bookAuthor)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Button(action: {
                                            favorites.toggleFavoriteBook(book: book)
                                        }) {
                                            Image(systemName: "heart.fill")
                                                .foregroundStyle(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(FavoritesViewModel())
}