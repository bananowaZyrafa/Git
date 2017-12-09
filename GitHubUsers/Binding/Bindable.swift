import Foundation
import UIKit
import RxSwift

protocol BindableType {
    associatedtype GenericViewModelType
    
    var viewModel: GenericViewModelType! { get set }
    
    func bindViewModel()
}

extension BindableType where Self: UIViewController {
    mutating func bindViewModel(to model: Self.GenericViewModelType) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}
