import Foundation

struct Repo {
    var fullName: String = ""
}

extension Repo {
    init(json: [String: Any]) {
        self.fullName = (json["full_name"] as? String) ?? ""
    }
}
