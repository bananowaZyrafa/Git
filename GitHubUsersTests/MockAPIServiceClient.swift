
@testable
import GitHubUsers
import Foundation
import RxSwift

final class MOCKAPIClientService: APIClientServiceType {
    
    static let shared = MOCKAPIClientService()
    
    typealias JSONArray = [[String: Any]]
    
    public var fetchUsersCalled = false
    public var fetchReposCalled = false
    public var fetchAvatarCalled = false
    public var mockRequestCalled = false
    
    func fetchUsers() -> Observable<[User]> {
        fetchUsersCalled = true
        return mockRequest(for: "UsersResponse").flatMap { json -> Observable<[User]> in
            guard let jsonArr = json as? JSONArray else {
                return .error(APIError.parsingError)
            }
            return .just(jsonArr.map(User.init))
        }
    }
    
    func fetchRepos(for url: URL?) -> Observable<[Repo]> {
        fetchReposCalled = true
        return mockRequest(for: "ReposResponse").flatMap { json -> Observable<[Repo]> in
            guard let jsonArr = json as? JSONArray else {
                return .error(APIError.parsingError)
            }
            return .just(jsonArr.map(Repo.init))
        }
    }
    
    func fetchAvatar(for url: URL?) -> Observable<UIImage> {
        fetchAvatarCalled = true
        return .just(UIImage())
    }
    
    private func mockRequest(for resource: String) -> Observable<Any> {
        mockRequestCalled = true
        let path = Bundle.main.path(forResource: resource, ofType: "JSON")
        return Observable.create { observer in
            guard let jsonData = try? Data(contentsOf: URL.init(fileURLWithPath: path!), options: Data.ReadingOptions.dataReadingMapped) else {
                observer.onError(APIError.invalidDataReceived)
                observer.onCompleted()
                return Disposables.create()
            }
            guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) else {
                observer.onError(APIError.JSONSerializationError)
                observer.onCompleted()
                return Disposables.create()
            }
            observer.onNext(json)
            observer.onCompleted()
            return Disposables.create()
        }
        
    }
}
