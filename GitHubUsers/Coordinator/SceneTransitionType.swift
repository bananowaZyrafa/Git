import Foundation
import UIKit

enum SceneTransitionType {
    case root
    case push(animated: Bool)
    case modal(animated: Bool)
    
    case pushToVC(stackPath: [UIViewController], animated: Bool)
}
