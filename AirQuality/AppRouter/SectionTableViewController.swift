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

class SectionTableViewController: UITableViewController {

    private let viewModel: SectionViewModel
    private let disposeBag = DisposeBag()
    private let routerActions: DetailsRouterActions
    private let navigationTitle: String

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("de init")
    }

    init(navigationTitle: String, viewModel: SectionViewModel, routerActions: DetailsRouterActions) {
        self.viewModel = viewModel
        self.navigationTitle = navigationTitle
        self.routerActions = routerActions
        super.init(nibName: nil, bundle: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        title = navigationTitle
        configureTableViewForRxBinding()
        bindLoadingView(to: viewModel)
        bindTableView(to: viewModel)
        viewModel.loadData()
    }


    private func configureTableViewForRxBinding() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TitleTableCell")
    }


    private func bindLoadingView(to viewModel: SectionViewModel) {
        // switch to MD progress hub and add to view so hidden when dismissed and removes warnings
        viewModel.isLoading
            .bind(to: SVProgressHUD.rx.isAnimating)
            .disposed(by: disposeBag)
    }

    
    private func bindTableView(to viewModel: SectionViewModel) {

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SectionItemModel>>(
            configureCell: { [weak self] dataSource, table, indexPath, item in
                guard let self = self else { return UITableViewCell() }
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "TitleTableCell", for: indexPath)
                cell.textLabel?.text = item.name
                cell.textLabel?.numberOfLines = 0
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels.element(atIndex: index)?.model ?? ""
            }
        )

        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(SectionItemModel.self)
            .subscribe(onNext: { [weak self] country in
                guard let self = self else { return }
                self.routerActions.showDetails(from: self, name: country.name, code: country.code)
            })
            .disposed(by: disposeBag)
    }

}
