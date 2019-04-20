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

class SearchListViewController: UIViewController, UISearchControllerDelegate, ViewModelBindable {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchBar = UISearchBar()//(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
    
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
        
        
        self.tableView.rx.items(viewModel.output.users.asObservable()) ({ (tableView, row, user) -> UITableViewCell in
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            
            cell.textLabel?.text = user.login
            cell.detailTextLabel?.text = String(user.id)
            cell.detailTextLabel?.textColor = .darkGray
            if let imageView = cell.imageView {
                viewModel.output.avatarURL(for: user)
                    .drive(imageView.rx.image)
                    .disposed(by: disposeBag)
                viewModel.output.isGettingImage(for: user)
                    .drive(imageView.rx.hasLoadingOverlay)
                    .disposed(by: disposeBag)
            }
            
            return cell
        }).disposed(by: disposeBag)
        
        self.disposeBag = disposeBag
    }
    
    // MARK: - UISearchController Delegate
    
//    // These methods are called when automatic presentation or dismissal occurs. They will not be called if you present or dismiss the search controller yourself.
//    func willPresentSearchController(_ searchController: UISearchController) {
//
//    }
//
//    func didPresentSearchController(_ searchController: UISearchController) {
//
//    }
//
//    func willDismissSearchController(_ searchController: UISearchController) {
//
//    }
//
//    func didDismissSearchController(_ searchController: UISearchController) {
//
//    }
    
    
    // Called after the search controller's search bar has agreed to begin editing or when 'active' is set to YES. If you choose not to present the controller yourself or do not implement this method, a default presentation is performed on your behalf.
    func presentSearchController(_ searchController: UISearchController) {

    }

    
}
