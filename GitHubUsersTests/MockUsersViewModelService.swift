@testable
import GitHubUsers
import Foundation
import RxSwift

struct MockUsersViewModelService: UsersViewModelServiceType {
    
    private let mockAPIClientService = MOCKAPIClientService.shared
    
    func fetchUsers() -> Observable<[User]> {
        return mockAPIClientService.fetchUsers()
    }
    
    func fetchRepos(for url: URL?) -> Observable<[Repo]> {
        return mockAPIClientService.fetchRepos(for: nil)
    }
    
    func fetchAvatar(for url: URL?) -> Observable<UIImage> {
        return mockAPIClientService.fetchAvatar(for: nil)
    }
    
}
