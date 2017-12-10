
import Foundation
import RxSwift
import Action

protocol UsersViewModelInputsType {
    var presentReposForUser: PublishSubject<IndexPath> {get}
}

protocol UsersViewModelOutputsType {
    var usersVariable: Variable<[User]> {get}
}

protocol UsersViewModelActionsType {
    //    var performRequestForFetchingUsers: Action<Void, [User]> {get}
}

protocol UsersViewModelType: class {
    var inputs: UsersViewModelInputsType { get }
    var outputs: UsersViewModelOutputsType { get }
    var actions: UsersViewModelActionsType { get }
}

final class UsersViewModel: UsersViewModelType {
    
    var inputs: UsersViewModelInputsType { return self }
    var actions: UsersViewModelActionsType { return self }
    var outputs: UsersViewModelOutputsType { return self }
    
    private let usersViewModelService: UsersViewModelServiceType
    private let coordinator: SceneCoordinatorType
    
    var presentReposForUser: PublishSubject<IndexPath>
    
    var usersVariable = Variable<[User]>([])
    private var error = PublishSubject<APIError>()
//    var errorMessage = Observable<String>()
    
    private let disposeBag: DisposeBag
    
    init(service: UsersViewModelServiceType, coordinator: SceneCoordinatorType) {
        
        self.usersViewModelService = service
        self.coordinator = coordinator
        disposeBag = DisposeBag()
        
        presentReposForUser = PublishSubject()
        
        bindInputs()
        bindOutputs()
        
    }
    
    private func bindInputs() {
        presentReposForUser.flatMap(selectedUser).bind(to: pushScene.inputs).disposed(by: disposeBag)
    }
    
    private func bindOutputs() {
        
        let usersResponse = usersViewModelService.fetchUsers().shareReplay(1)
        usersResponse.bind(to: usersVariable).disposed(by: disposeBag)
        
        usersResponse
            .flatMap {
                return Observable.from($0)
            }
            .flatMap { [weak self] user -> Observable<(User, UIImage)> in
                guard let safeSelf = self else {
                    return .error(APIError.unknownError)
                }
                
                let avatarObservable = safeSelf.usersViewModelService.fetchAvatar(for: user.avatarURL)
                let userObservable = Observable.just(user)
                
                return Observable.zip(userObservable, avatarObservable)
            }.subscribe(onNext: { [weak self] (fetchedUser, image) in
                guard let safeSelf = self else {return}
                safeSelf.usersVariable.value = safeSelf.usersVariable.value.map{ [weak self] user in
                    guard let safeSelf = self else {return user}
                    return safeSelf.userWith(image: image, from: fetchedUser, for: user)
                }
                }, onError: { [weak self ](error) in
                    guard let safeSelf = self else { return}
                    if let apiError = error as? APIError {
                        safeSelf.error.onNext(apiError)
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
                let repoObservable = safeSelf.usersViewModelService.fetchRepos(for: user.reposURL)
                let userObservable = Observable.just(user)
                
                return Observable.zip(userObservable, repoObservable)
            }.subscribe(onNext: { [weak self] (fetchedUser, repos) in
                guard let safeSelf = self else {return}
                safeSelf.usersVariable.value = safeSelf.usersVariable.value.map { [weak self] user in
                    guard let safeSelf = self else {return user}
                    return safeSelf.userWith(repos: repos, from: fetchedUser, for: user)
                }
                }, onError: { [weak self ](error) in
                    guard let safeSelf = self else { return}
                    if let apiError = error as? APIError {
                        safeSelf.error.onNext(apiError)
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
    
    
    //    lazy var performFetchUsers: Action<Void, [User]> = {
    //
    //    }()
    
    lazy var pushScene: Action<User, Void> = {
        return Action { [weak self] user in
            guard let safeSelf = self else {return .empty()}
            let reposViewModel = ReposViewModel(user: user, coordinator: safeSelf.coordinator)
            let reposScene = Scene.reposScene(reposViewModel)
            return safeSelf.coordinator.transition(to: reposScene, type: .push(animated: true))
        }
    }()
    
    func selectedUser(indexPath: IndexPath) -> Observable<User> {
        return Observable.just(usersVariable.value[indexPath.row])
    }
    
    
}

extension UsersViewModel: UsersViewModelInputsType, UsersViewModelOutputsType, UsersViewModelActionsType {}
