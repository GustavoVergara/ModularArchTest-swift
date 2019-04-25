//
//  SearchListViewController.swift
//  MATSearchListModule
//
//  Created by Gustavo Vergara Garcia on 03/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit
import MATKit
import RxSwift
import RxCocoa

class SearchListViewController: UIViewController, ViewModelBindable {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchBar = UISearchBar()
    
    let getMoreButton: UIButton = {
        let getMoreUsersButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        getMoreUsersButton.setTitle("Get More", for: .normal)
        getMoreUsersButton.setTitle("Unable to get more", for: .disabled)
        getMoreUsersButton.setTitleColor(.blue, for: .normal)
        getMoreUsersButton.setTitleColor(.lightGray, for: .disabled)
        return getMoreUsersButton
    }()
    
    // MARK: - Properties
    
    var disposeBag: DisposeBag?
    
    // MARK: - Constructors
    
    init() {
        super.init(nibName: "SearchListViewController", bundle: Bundle(for: SearchListViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UIViewController Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchBar.showsSearchResultsButton = true
        self.navigationItem.titleView = self.searchBar
        
        self.tableView.register(RxTableViewCell.self, forCellReuseIdentifier: "RxTableViewCell")
        
        self.tableView.tableFooterView = self.getMoreButton
    }
    
    // MARK: - Bindings
    
    func bind(to viewModel: SearchListViewModel) {
        self.loadViewIfNeeded()
        let disposeBag = DisposeBag()
        
        // In
        
        self.searchBar.rx.searchButtonClicked
            .withLatestFrom(self.searchBar.rx.text)
            .bind(to: viewModel.input.search)
            .disposed(by: disposeBag)
        
//        self.searchBar.rx.text
//            .throttle(1, scheduler: MainScheduler.instance)
//            .bind(to: viewModel.input.search)
//            .disposed(by: disposeBag)
        
//        self.tableView.rx.willDisplayCell
//            .map({ Double($0.indexPath.row) })
//            .withLatestFrom(viewModel.output.users, resultSelector: { $0 / Double($1.count) })
//            .filter({ $0 > 0.7 })
//            .ignoreValues()
//            .bind(to: viewModel.input.getMoreUsers)
//            .disposed(by: disposeBag)
        
        self.tableView.rx.prefetchRows
            .withLatestFrom(viewModel.output.users) { (indeces, users) in indeces.map({ users[$0.row] }) }
            .map({ $0.compactMap(viewModel.output.prefetchAvatar) })
            .subscribe(onNext: { [weak disposeBag] (disposables) in
                disposeBag?.insert(disposables)
            })
            .disposed(by: disposeBag)
        
        self.getMoreButton.rx.tap
            .bind(to: viewModel.input.getMoreUsers)
            .disposed(by: disposeBag)
        
        self.tableView.rx.modelSelected(User.self)
            .bind(to: viewModel.input.selectUser)
            .disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] in self?.tableView?.deselectRow(at: $0, animated: true) })
            .disposed(by: disposeBag)
        
        // Out
        
        viewModel.output.isSearching
            .drive(self.view.rx.hasLoadingOverlay)
            .disposed(by: disposeBag)
        
        viewModel.output.isGettingMoreUsers
            .drive(self.getMoreButton.rx.hasLoadingOverlay)
            .disposed(by: disposeBag)
        
        self.tableView.rx.items(viewModel.output.users.asObservable()) ({ (tableView, row, user) -> UITableViewCell in
            let cell = RxTableViewCell(style: .subtitle, reuseIdentifier: "RxTableViewCell")
            
            cell.textLabel?.text = user.login
            cell.detailTextLabel?.text = String(user.id)
            cell.detailTextLabel?.textColor = .darkGray
            if let imageView = cell.imageView {
                let imageSize = CGSize(width: 44, height: 44)
                imageView.layer.cornerRadius = imageSize.width / 2
                imageView.clipsToBounds = true
                Driver.just(R.image.github_octocat()!)
                    .concat(viewModel.output.avatar(for: user))
                    .map({ $0 .af_imageScaled(to: imageSize) })
                    .drive(imageView.rx.image)
                    .disposed(by: cell.disposeBag)
                
                viewModel.output.isGettingImage(for: user)
                    .drive(imageView.rx.hasLoadingOverlay)
                    .disposed(by: cell.disposeBag)
            }
            
            return cell
        }).disposed(by: disposeBag)
        
        viewModel.output.error
            .emit(onNext: { [weak self] (error) in
                switch error {
                case .loginNotFound:
                    self?.utils.presentAlert(title: "Nome de usuário não pode estar vazio.")
                case .unhandledError:
                    self?.utils.presentAlert(title: "Erro inesperado.")
                }
            })
            .disposed(by: disposeBag)
        
        self.disposeBag = disposeBag
    }
    
}
