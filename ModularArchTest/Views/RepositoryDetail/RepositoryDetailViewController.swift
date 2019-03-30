//
//  RepositoryDetailViewController.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 28/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepositoryDetailViewController: UIViewController, ViewModelBindable {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    // MARK: - Properties
    
    var disposeBag: DisposeBag?
    
    // MARK: - UIViewController Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        self.tableView.tableFooterView = UIView()
    }
    
    // MARK: - Bindings
    
    func bind(to viewModel: RepositoryDetailViewModel) {
        self.loadViewIfNeeded()
        let disposeBag = DisposeBag()
        defer { self.disposeBag = disposeBag }
        Disposables.createStrongReferenceTo(viewModel).disposed(by: disposeBag)
        
        // in
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView?.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)

        self.tableView.rx.modelSelected(Row.self)
            .filter({ $0 == .openOnGitHub })
            .ignoreValues()
            .bind(to: viewModel.input.openOnGitHub)
            .disposed(by: disposeBag)

        // out
        let rowsDriver = Driver<[Row]>.combineLatest(
            viewModel.output.repository,
            viewModel.output.totalIssuesCount,
            viewModel.output.canOpenOnGitHub,
            resultSelector: { (repository, totalIssuesCount, canOpenOnGitHub) -> [Row] in
                var rows = [Row]()
                if let description = repository.description { rows.append(.description(description)) }
                if let language = repository.language { rows.append(.language(language)) }
                if let createdAt = repository.createdAt { rows.append(.createdAt(createdAt)) }
                if let updatedAt = repository.updatedAt { rows.append(.lastUpdatedAt(updatedAt)) }
                if let starsCount = repository.stargazersCount { rows.append(.stars(starsCount)) }
                if let forksCount = repository.forksCount { rows.append(.forks(forksCount)) }
                
                if let openIssuesCount = repository.openIssuesCount, let totalIssuesCount = totalIssuesCount {
                    rows.append(.issuesCount(open: openIssuesCount, total: totalIssuesCount))
                } else if let openIssuesCount = repository.openIssuesCount {
                    rows.append(.openIssuesCount(openIssuesCount))
                }
                
                if canOpenOnGitHub { rows.append(.openOnGitHub) }
                
                return rows
            }
        )
        self.tableView.rx.items(rowsDriver.asObservable()) ({ (tableView, row, item) -> UITableViewCell in
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            
            cell.imageView?.image = item.image?.af_imageAspectScaled(toFit: CGSize(width: 25, height: 25))
            cell.textLabel?.text = item.title
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = item.description
            cell.detailTextLabel?.numberOfLines = 0
            
            return cell
        }).disposed(by: disposeBag)
        
        viewModel.output.repository
            .map({ $0.name })
            .drive(self.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.output.isGettingIssues
            .drive(self.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: -
    
    enum Row: Equatable {
        case description(String)
        case language(String)
        case createdAt(Date)
        case lastUpdatedAt(Date)
        case stars(Int)
        case forks(Int)
        case issuesCount(open: Int, total: Int)
        case openIssuesCount(Int)
        case totalIssuesCount(Int)
        case openOnGitHub

        var title: String? {
            switch self {
            case .description:      return "Description"
            case .language:         return "Language"
            case .createdAt:        return "Created At"
            case .lastUpdatedAt:    return "Last Updated At"
            case .stars:            return "Stars"
            case .forks:            return "Forks"
            case .issuesCount:      return "Issues"
            case .openIssuesCount:  return "Open Issues Count"
            case .totalIssuesCount: return "Total Issues Count"
            case .openOnGitHub:     return "Open on GitHub"
            }
        }
        
        var description: String? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            switch self {
            case .description(let description):             return description
            case .language(let language):                   return language
            case .createdAt(let createdAt):                 return dateFormatter.string(from: createdAt)
            case .lastUpdatedAt(let lastUpdatedAt):         return dateFormatter.string(from: lastUpdatedAt)
            case .stars(let stars):                         return "\(stars)"
            case .forks(let forks):                         return "\(forks)"
            case .issuesCount(let open, let total):         return "\(open) open / \(total) total"
            case .openIssuesCount(let openIssuesCount):     return "\(openIssuesCount)"
            case .totalIssuesCount(let totalIssuesCount):   return "\(totalIssuesCount)"
            case .openOnGitHub:                             return nil
            }
        }
        
        var image: UIImage? {
            switch self {
            case .description:      return R.image.git_file()
            case .language:         return R.image.git_code()
            case .createdAt:        return R.image.git_history()
            case .lastUpdatedAt:    return R.image.git_clock()
            case .stars:            return R.image.git_star()
            case .forks:            return R.image.git_branch()
            case .issuesCount:      return R.image.git_issue()
            case .openIssuesCount:  return R.image.git_issue()
            case .totalIssuesCount: return R.image.git_issue()
            case .openOnGitHub:     return R.image.github_octocat()
            }
        }
    }
    
}
