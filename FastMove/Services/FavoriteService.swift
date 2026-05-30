import Foundation

class FavoriteService {
    static let shared = FavoriteService()
    private let key = "favoriteFolders"

    func load() -> [FavoriteFolder] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let folders = try? JSONDecoder().decode([FavoriteFolder].self, from: data) else {
            return []
        }
        return folders.filter { FileManager.default.fileExists(atPath: $0.path) }
    }

    func save(_ folders: [FavoriteFolder]) {
        guard let data = try? JSONEncoder().encode(folders) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func add(name: String, path: String) -> [FavoriteFolder] {
        var folders = load()
        if !folders.contains(where: { $0.path == path }) {
            folders.append(FavoriteFolder(name: name, path: path))
            save(folders)
        }
        return folders
    }

    func remove(path: String) -> [FavoriteFolder] {
        var folders = load()
        folders.removeAll { $0.path == path }
        save(folders)
        return folders
    }

    func isFavorite(path: String) -> Bool {
        load().contains { $0.path == path }
    }
}
