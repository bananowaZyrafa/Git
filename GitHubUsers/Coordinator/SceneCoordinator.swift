import UIKit
import RxSwift
import RxCocoa

final class SceneCoordinator: SceneCoordinatorType {
    
    fileprivate var window: UIWindow
    var currentViewController: UIViewController
    var currentNavDidShowObserver: Disposable?
    
    required init(window: UIWindow) {
        self.window = window
        currentViewController = window.rootViewController!
    }
    
    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            return navigationController.viewControllers.first!
        } else {
            return viewController
        }
    }
    
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        let viewController = scene.viewController()
        switch type {
        case .root:
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            window.rootViewController = viewController
            subject.onCompleted()
            
        case .push(let animated):
            guard let navigationController = currentViewController.navigationController else {
                fatalError("Can't push a view controller without a current navigation controller")
            }
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            navigationController.pushViewController(viewController, animated: animated)
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            
        case .modal(let animated):
            currentViewController.present(viewController, animated: animated) {
                subject.onCompleted()
            }
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            
        case .pushToVC(let stack, let animated):
            guard let navigationController = currentViewController.navigationController else {
                fatalError("Can't push a view controller without a current navigation controller")
            }
            
            var controllers = navigationController.viewControllers
            stack.forEach { controllers.append($0) }
            controllers.append(viewController)
            
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            navigationController.setViewControllers(controllers, animated: animated)
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            
        default:
            break
        }
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
    
    @discardableResult
    func pop(animated: Bool) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        if let presenter = currentViewController.presentingViewController {
            currentViewController.dismiss(animated: animated) {
                self.currentViewController = SceneCoordinator.actualViewController(for: presenter)
                subject.onCompleted()
            }
        } else if let navigationController = currentViewController.navigationController {
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .take(1)
                .map { _ in }
                .bind(to: subject)
            
            guard navigationController.popViewController(animated: animated) != nil else {
                fatalError("can't navigate back from \(currentViewController)")
            }
            currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
        } else {
            fatalError("Not a modal, no navigation controller: can't navigate back from \(currentViewController)")
        }
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
    
    @discardableResult
    func popToRoot(animated: Bool) -> Observable<Void> {
        
        let subject = PublishSubject<Void>()
        if let navigationController = currentViewController.navigationController {
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .take(1)
                .map { _ in }
                .bind(to: subject)
            
            guard navigationController.popToRootViewController(animated: animated) != nil else {
                fatalError("can't navigate back to root VC from \(currentViewController)")
            }
            currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.first!)
        }
        
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
    
    @discardableResult
    func popToVC(_ viewController: UIViewController, animated: Bool) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        if let navigationController = currentViewController.navigationController {
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .take(1)
                .map { _ in }
                .bind(to: subject)
            
            guard navigationController.popToViewController(viewController, animated: animated) != nil else {
                fatalError("can't navigate back to VC from \(currentViewController)")
            }
            currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
        }
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
    
    func popVC(animated: Bool) -> Observable<Void> {
        
        let subject = PublishSubject<Void>()
        
        guard let navigationController = currentViewController.navigationController else {
            fatalError("No navigation controller: can't navigate back from \(currentViewController)")
        }
        
        if let currentNavDidShowObserver = currentNavDidShowObserver {
            currentNavDidShowObserver.dispose()
        }
        
        currentNavDidShowObserver = navigationController.rx.delegate
            .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
            .map { _ in }
            .bind(to: subject)
        
        currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
        
        return subject.asObservable()
            .take(1)
    }
}
