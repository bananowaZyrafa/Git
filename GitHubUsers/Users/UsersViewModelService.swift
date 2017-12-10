
import Foundation
import RxSwift

protocol UsersViewModelServiceType {
    
    func fetchUsers() -> Observable<[User]>
    func fetchAvatar(for url: URL?) -> Observable<UIImage>
    func fetchRepos(for url: URL?) -> Observable<[Repo]>
}

struct UsersViewModelService: UsersViewModelServiceType {
    
    private let apiClientService = APIClientService.shared
    
    init() {
        
    }
    
    func fetchUsers() -> Observable<[User]> {
        return apiClientService.fetchUsers()
    }
    
    func fetchAvatar(for url: URL?) -> Observable<UIImage> {
        return apiClientService.fetchAvatar(for: url)
    }
    
    func fetchRepos(for url: URL?) -> Observable<[Repo]> {
        return apiClientService.fetchRepos(for: url)
    }
    
    
}
