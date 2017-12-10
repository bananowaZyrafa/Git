
import Foundation
import RxSwift
import Action

protocol ReposViewModelOutputsType {
    var repos: Variable<[Repo]> {get}
}

protocol ReposViewModelActionsType {
    var pop: CocoaAction { get }
}

protocol ReposViewModelType: class {
    var outputs: ReposViewModelOutputsType { get }
    var actions: ReposViewModelActionsType { get }
}

final class ReposViewModel: ReposViewModelType {
    
    var outputs: ReposViewModelOutputsType { return self }
    var actions: ReposViewModelActionsType { return self }
    
    private let coordinator: SceneCoordinatorType
    private var user: User
    
    var repos = Variable<[Repo]>([])
    
    
    init(user: User, coordinator: SceneCoordinatorType) {
        self.user = user
        self.coordinator = coordinator
        bindOutputs()
    }
    
    private func bindOutputs() {
        repos.value = user.repos
    }
    
    lazy var pop: CocoaAction = { [weak self] _ in
        return CocoaAction {
            return self?.coordinator.popVC(animated: true) ?? .empty()
        }
        }()
    
}

extension ReposViewModel: ReposViewModelOutputsType, ReposViewModelActionsType {}
