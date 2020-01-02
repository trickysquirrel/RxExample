//
//  CountriesTableViewController.swift
//  AirQuality
//
//  Created by Richard Moult on 31/12/19.
//  Copyright © 2019 RichardMoult. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SVProgressHUD


private let startLoadingOffset: CGFloat = 20.0
private func isNearTheBottomEdge(_ contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
    return contentOffset.y +
        tableView.frame.size.height +
        startLoadingOffset > tableView.contentSize.height
}


class SectionTableViewController: UITableViewController {

    private let cellId = "TitleTableCell"
    private let viewModel: SectionViewModel
    private let disposeBag = DisposeBag()
    private let cellActions: DetailsRouterActions?
    private let navigationTitle: String
    private var loadNextPageTrigger: Observable<Void>?

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("de init")
    }

    init(navigationTitle: String, viewModel: SectionViewModel, cellActions: DetailsRouterActions?) {
        self.viewModel = viewModel
        self.navigationTitle = navigationTitle
        self.cellActions = cellActions
        super.init(nibName: nil, bundle: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        title = navigationTitle
        configureTableViewForRxBinding()
        bindLoadingView(to: viewModel)
        bindTableView(to: viewModel)
        viewModel.loadFirstPage()
    }


    private func configureTableViewForRxBinding() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        loadNextPageTrigger = self.tableView.rx.contentOffset
            .flatMap { (offset) -> Observable<Void> in
                isNearTheBottomEdge(offset, self.tableView)
                    ? Observable.just(Void())
                    : Observable.empty()
            }
    }


    private func bindNextPageLoad() {
        loadNextPageTrigger?
            .asObservable()
            .take(1)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.loadNextPage()
            })
            .disposed(by: disposeBag)
    }


    private func bindLoadingView(to viewModel: SectionViewModel) {
        // switch to MD progress hub and add to view so hidden when dismissed and removes warnings
        viewModel.isLoading
            .observeOn(MainScheduler.instance)
            .bind(to: SVProgressHUD.rx.isAnimating)
            .disposed(by: disposeBag)
    }

    
    private func bindTableView(to viewModel: SectionViewModel) {

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SectionItemModel>>(
            configureCell: { [weak self] dataSource, table, indexPath, item in
                guard let self = self else { return UITableViewCell() }
                let cell = self.tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath)
                cell.textLabel?.text = item.name
                cell.textLabel?.numberOfLines = 0
                if self.cellActions == nil {
                    cell.selectionStyle = .none
                }
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels.element(atIndex: index)?.model ?? ""
            }
        )

        // bind data source for cell generation
        viewModel.sections
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // watch for when to load next page
        viewModel.sections
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                self?.bindNextPageLoad()
            })
            .disposed(by: disposeBag)

        // deselect row on selection
        tableView.rx.itemSelected
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)

        // perform cell action when selected
        tableView.rx.modelSelected(SectionItemModel.self)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] country in
                guard let self = self else { return }
                self.cellActions?.showDetails(from: self, name: country.name, code: country.code)
            })
            .disposed(by: disposeBag)
    }

}
