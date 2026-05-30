import Foundation

class RecentService {
    static let shared = RecentService()
    private let key = "recentTargets"
    private let maxCount = 5

    func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func add(path: String) {
        var recent = load()
        recent.removeAll { $0 == path }
        recent.insert(path, at: 0)
        if recent.count > maxCount {
            recent = Array(recent.prefix(maxCount))
        }
        UserDefaults.standard.set(recent, forKey: key)
    }

    func remove(path: String) {
        var recent = load()
        recent.removeAll { $0 == path }
        UserDefaults.standard.set(recent, forKey: key)
    }
}
