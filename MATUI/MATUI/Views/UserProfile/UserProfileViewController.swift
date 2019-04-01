//
//  UserProfileViewController.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 27/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit
import MATKit
import RxSwift
import RxCocoa

public class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ViewModelBindable {
    
    // MARK: - Outlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var repositories: [Repository] = []
    
    var disposeBag: DisposeBag?
    
    let selectRepositoryRelay = PublishRelay<Repository>()
    
    // MARK: - Contructors
    
    public init() {
        super.init(nibName: R.nib.userProfileViewController.name, bundle: R.nib.userProfileViewController.bundle)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UIViewController Overrides
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width / 2
    }
    
    // MARK: - ViewModelBindable
    
    var viewModel: UserProfileViewModel?
    public func bind(to viewModel: UserProfileViewModel) {
//        self.viewModel = viewModel
        self.loadViewIfNeeded()
        let disposeBag = DisposeBag()
        
        // in
        self.tableView.rx.modelSelected(Repository.self)
            .bind(to: viewModel.input.selectRepository)
            .disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView?.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        // out
        viewModel.output.profileImage
            .drive(self.userImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.output.profileImage
            .map({ $0.af_imageAspectScaled(toFit: CGSize(width: 30, height: 30)) })
            .map({ $0.af_imageRoundedIntoCircle() })
            .map({ $0.withRenderingMode(.alwaysOriginal) })
            .drive(onNext: { [weak self] (profileImage) in
                self?.navigationItem.backBarButtonItem = UIBarButtonItem(image: profileImage, style: .done, target: nil, action: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.isGettingProfileImage
            .drive(self.userImageView.rx.hasLoadingOverlay)
            .disposed(by: disposeBag)
        
        viewModel.output.username
            .drive(self.usernameLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.tableView.rx.items(viewModel.output.repositories.asObservable()) ({ (_, _, repository) -> UITableViewCell in
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            
            cell.textLabel?.text = repository.name
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = repository.description
            cell.detailTextLabel?.numberOfLines = 0
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            
            return cell
        }).disposed(by: disposeBag)
        
        Disposables.createStrongReferenceTo(viewModel).disposed(by: disposeBag)

        self.disposeBag = disposeBag
    }
    
    // MARK: - UITableView Data Source
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repositories.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.repositories.indices.contains(indexPath.row) else {
            return UITableViewCell()
        }
        let repositories = self.repositories[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = repositories.name
        cell.detailTextLabel?.text = repositories.description
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    // MARK: - UITableView Delegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard self.repositories.indices.contains(indexPath.row) else { return }
        
        self.selectRepositoryRelay.accept(self.repositories[indexPath.row])
    }

}
