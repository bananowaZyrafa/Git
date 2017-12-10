import UIKit
import RxSwift

protocol SceneCoordinatorType {
    
    init(window: UIWindow)
    
    var currentViewController: UIViewController { get }
    
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Observable<Void>
    
    @discardableResult
    func pop(animated: Bool) -> Observable<Void>
    
    @discardableResult
    func popToRoot(animated: Bool) -> Observable<Void>
    
    @discardableResult
    func popToVC(_ viewController: UIViewController, animated: Bool) -> Observable<Void>
    
    @discardableResult
    func popVC(animated: Bool) -> Observable<Void>
    
}
