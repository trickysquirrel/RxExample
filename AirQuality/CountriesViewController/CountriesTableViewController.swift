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

class CountriesTableViewController: UITableViewController {

    private let viewModel: CountriesViewModel
    private let disposeBag = DisposeBag()
    private let routerActions: CountriesRouterActions

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(routerActions: CountriesRouterActions) {
        self.viewModel = CountriesViewModel()
        self.routerActions = routerActions
        super.init(nibName: nil, bundle: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Countries"
        configureTableViewForRxBinding()
        bindLoadingView(to: viewModel)
        bindTableView(to: viewModel)
        viewModel.retrieveCountries()
    }


    private func configureTableViewForRxBinding() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CountriesCell")
    }


    private func bindLoadingView(to viewModel: CountriesViewModel) {
        viewModel.isLoading
            .bind(to: SVProgressHUD.rx.isAnimating)
            .disposed(by: disposeBag)
    }

    
    private func bindTableView(to viewModel: CountriesViewModel) {

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, CountryModel>>(
            configureCell: { dataSource, table, indexPath, item in
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "CountriesCell", for: indexPath)
                cell.textLabel?.text = item.name
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

        tableView.rx.modelSelected(CountryModel.self)
            .subscribe(onNext: { [weak self] country in
                guard let self = self else { return }
                self.routerActions.showCountryDetails(from: self, countryName: country.name)
            })
            .disposed(by: disposeBag)
    }

}
