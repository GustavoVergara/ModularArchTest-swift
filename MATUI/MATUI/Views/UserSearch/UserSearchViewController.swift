//
//  UserSearchViewController.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MATKit

public class UserSearchViewController: UIViewController, ViewModelBindable {

    // MARK: - Outlets
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var searchActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var disposeBag: DisposeBag?
    
    // MARK: - Contructors
    
    public init() {
        super.init(nibName: R.nib.userSearchViewController.name, bundle: R.nib.userSearchViewController.bundle)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UIViewController Overrides
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Busca de Repositórios"
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.usernameTextField.becomeFirstResponder()
    }
    
    // MARK: - ViewModelBindable
    public func bind(to viewModel: UserSearchViewModel) {
        self.loadViewIfNeeded()
        
        let disposeBag = DisposeBag()
        

        NotificationCenter.default.rx.notification(UIApplication.keyboardDidShowNotification)
            .map({ $0.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect })
            .filterNil()
            .subscribe(onNext: { [weak self] keyboardFrame in
                self?.additionalSafeAreaInsets.bottom = keyboardFrame.height
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIApplication.keyboardDidHideNotification)
            .subscribe(onNext: { [weak self] _ in
                self?.additionalSafeAreaInsets.bottom = 0
            })
            .disposed(by: disposeBag)
        
        // in
        self.searchButton.rx.tap
            .withLatestFrom(self.usernameTextField.rx.text)
            .bind(to: viewModel.input.search)
            .disposed(by: disposeBag)
        
        self.usernameTextField.rx.controlEvent(.primaryActionTriggered)
            .withLatestFrom(self.usernameTextField.rx.text)
            .bind(to: viewModel.input.search)
            .disposed(by: disposeBag)
        
        // out
        viewModel.output.isSearching
            .drive(self.searchActivityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .emit(onNext: { [weak self] (error) in
                switch error {
                case .usernameIsEmpty:
                    self?.utils.presentAlert(title: "Nome de usuário não pode estar vazio.")
                case .usernameNotFound:
                    self?.utils.presentAlert(title: "Usuário não encontrado.")
                case .unhandledError:
                    self?.utils.presentAlert(title: "Erro inesperado.")
                case .userDoesNotHaveAnyRepository:
                    self?.utils.presentAlert(title: "Usuário não tem nenhum repositório.")
                }
            })
            .disposed(by: disposeBag)
        
        Disposables.createStrongReferenceTo(viewModel).disposed(by: disposeBag)
        
        self.disposeBag = disposeBag
    }

}
