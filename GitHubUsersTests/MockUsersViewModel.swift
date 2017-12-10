@testable
import GitHubUsers
import Foundation
import RxTest
import RxBlocking
import RxSwift

class MockUsersViewModel: UsersViewModelType {
    
    var inputs: UsersViewModelInputsType { return self }
    var outputs: UsersViewModelOutputsType { return self }
    var actions: UsersViewModelActionsType { return self }
    
    var presentReposForUser = PublishSubject<IndexPath>()
    
    private let mockUsersViewModelService: UsersViewModelServiceType
    var usersVariable = Variable<[User]>([])
    
    private var disposeBag = DisposeBag()
    
    init(service: UsersViewModelServiceType) {
        self.mockUsersViewModelService = service
        
        bindOutputs()
    }
    
    private func bindOutputs() {
        
        let usersResponse = mockUsersViewModelService.fetchUsers().shareReplay(1)
        usersResponse.bind(to: usersVariable).disposed(by: disposeBag)
        
        usersResponse
            .flatMap {
                return Observable.from($0)
            }
            .flatMap { [weak self] user -> Observable<(User, UIImage)> in
                guard let safeSelf = self else {
                    return .error(APIError.unknownError)
                }
                
                let avatarObservable = safeSelf.mockUsersViewModelService.fetchAvatar(for: user.avatarURL)
                let userObservable = Observable.just(user)
                
                return Observable.zip(userObservable, avatarObservable)
            }.subscribe(onNext: { [weak self] (fetchedUser, image) in
                guard let safeSelf = self else {return}
                safeSelf.usersVariable.value = safeSelf.usersVariable.value.map{ [weak self] user in
                    guard let safeSelf = self else {return user}
                    return safeSelf.userWith(image: image, from: fetchedUser, for: user)
                }
            }).disposed(by: disposeBag)
        
        usersResponse
            .flatMap {
                return Observable.from($0)
            }
            .flatMap { [weak self] user -> Observable<(User, [Repo])> in
                guard let safeSelf = self else {
                    return .error(APIError.unknownError)
                }
                let repoObservable = safeSelf.mockUsersViewModelService.fetchRepos(for: user.reposURL)
                let userObservable = Observable.just(user)
                
                return Observable.zip(userObservable, repoObservable)
            }.subscribe(onNext: { [weak self] (fetchedUser, repos) in
                guard let safeSelf = self else {return}
                safeSelf.usersVariable.value = safeSelf.usersVariable.value.map { [weak self] user in
                    guard let safeSelf = self else {return user}
                    return safeSelf.userWith(repos: repos, from: fetchedUser, for: user)
                }
            }).disposed(by: disposeBag)
    }
    
    private func userWith(image: UIImage, from fetchedUser: User, for user: User) -> User {
        if fetchedUser.userID == user.userID {
            var userCopy = user
            userCopy.avatarImage = image
            return userCopy
        }
        return user
    }
    
    private func userWith(repos: [Repo], from fetchedUser: User, for user: User) -> User {
        if fetchedUser.userID == user.userID {
            var userCopy = user
            userCopy.repos = repos
            return userCopy
        }
        return user
    }
    
}

extension MockUsersViewModel: UsersViewModelInputsType ,UsersViewModelOutputsType, UsersViewModelActionsType {}


