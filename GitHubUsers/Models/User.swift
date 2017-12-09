import Foundation
import UIKit

struct User {
    var userID: Int?
    var login: String?
    private var avatarURLString: String = ""
    var avatarURL: URL? {
        return URL(string: avatarURLString)
    }
    var reposURL: URL? {
        return URL(string: reposURLString)
    }
    private var reposURLString: String = ""
    var avatarImage: UIImage?
    var repos: [Repo] = []
    
    init(userJSON: [String: Any]) {
        self.userID = userJSON["id"] as? Int
        self.login = userJSON["login"] as? String
        self.avatarURLString = (userJSON["avatar_url"] as? String) ?? ""
        self.reposURLString = (userJSON["repos_url"] as? String) ?? ""
    }
    
}
