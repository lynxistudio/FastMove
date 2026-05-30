import Foundation

struct FavoriteFolder: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let path: String

    init(name: String, path: String) {
        self.id = UUID()
        self.name = name
        self.path = path
    }
}
