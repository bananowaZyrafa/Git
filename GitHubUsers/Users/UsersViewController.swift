import UIKit
import RxSwift
import RxCocoa

class UsersViewController: UIViewController, BindableType {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: UsersViewModelType!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        bindViewModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
    }
    
    func bindViewModel() {
        viewModel.outputs.usersVariable.asDriver().drive(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs.usersVariable.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        configureUserCell(cell, with: viewModel.outputs.usersVariable.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    private func configureUserCell(_ cell: UserTableViewCell, with user: User) {
        cell.avatarImage.image = user.avatarImage
        cell.loginLabel.text = user.login
        cell.repoCountLabel.text = "\(user.repos.count)"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.presentReposForUser.onNext(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
