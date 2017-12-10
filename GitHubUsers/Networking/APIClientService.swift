import Foundation
import RxSwift

protocol APIClientServiceType {
    
    func fetchUsers() -> Observable<[User]>
    func fetchRepos(for url: URL?) -> Observable<[Repo]>
    func fetchAvatar(for url: URL?) -> Observable<UIImage>
    
}
enum APIError: Error {
    case invalidURL
    case parsingError
    case imageDataError
    case invalidResponseType
    case JSONSerializationError
    case invalidDataReceived
    case unknownError
}

final class APIClientService {
    
    typealias JSONArray = [[String: Any]]
    fileprivate let baseURL = URL(string:"https://api.github.com/users")
    
    static let shared = APIClientService()
    private init () {}
    
    
}

extension APIClientService: APIClientServiceType {
    
    func fetchUsers() -> Observable<[User]> {
        guard let url = baseURL else {
            return .error(APIError.invalidURL)
        }
        return usersRequest(url: url).flatMap { json -> Observable<[User]> in
            guard let jsonArr = json as? JSONArray else {
                return .error(APIError.parsingError)
            }
            return .just(jsonArr.map(User.init))
        }
        
    }
    
    private func usersRequest(url: URL) -> Observable<Any> {
        return Observable.create{ observer in
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    observer.onError(error)
                    observer.onCompleted()
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    observer.onError(APIError.invalidResponseType)
                    observer.onCompleted()
                    return
                }
                guard let data = data else {
                    observer.onError(APIError.invalidDataReceived)
                    observer.onCompleted()
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    observer.onNext(jsonData)
                    observer.onCompleted()
                    
                } catch {
                    observer.onError(APIError.JSONSerializationError)
                    observer.onCompleted()
                }
            }).resume()
            return Disposables.create()
        }
        
    }
    
    func fetchRepos(for url: URL?) -> Observable<[Repo]> {
        guard let url = url else {
            return .error(APIError.invalidURL)
        }
        
        return usersRequest(url: url).flatMap { json -> Observable<[Repo]> in
            guard let jsonArr = json as? JSONArray else {
                return .error(APIError.parsingError)
            }
            return .just(jsonArr.map(Repo.init))
        }
    }
    
    func fetchAvatar(for url: URL?) -> Observable<UIImage> {
        guard let url = url else {
            return .error(APIError.invalidURL)
        }
        let request = URLRequest(url: url)
        
        return URLSession.shared.rx.data(request: request).flatMap{ imageData -> Observable<UIImage> in
            guard let image = UIImage(data: imageData) else {
                return .error(APIError.imageDataError)
            }
            return .just(image)
        }
        
    }
    
    
    
}
