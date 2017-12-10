import Foundation
import UIKit

enum Scene {
    case usersScene(UsersViewModel)
    case reposScene(ReposViewModel)
}

extension Scene {
    
    func viewController() -> UIViewController {
        
        switch self {
            
        case .usersScene(let viewModel):
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let userVC = storyboard.instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
            let nc = UINavigationController(rootViewController: userVC)
            var vc = nc.viewControllers.first as! UsersViewController
            vc.bindViewModel(to: viewModel)
            return nc
            
        case .reposScene(let viewModel):
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var reposVC = storyboard.instantiateViewController(withIdentifier: "ReposViewController") as! ReposViewController
            reposVC.bindViewModel(to: viewModel)
            return reposVC
        }
    }
    
}
