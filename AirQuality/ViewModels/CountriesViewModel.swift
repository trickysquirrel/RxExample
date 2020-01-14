//
//  CountriesViewModel.swift
//  AirQuality
//
//  Created by Richard Moult on 31/12/19.
//  Copyright © 2019 RichardMoult. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class CountriesViewModel: SectionViewModelType, SectionViewModelTypeInputs {

    var inputs: SectionViewModelTypeInputs { return self }
    var outputs: SectionViewModelOutput

    private let disposeBag = DisposeBag()
    private let apiClient: API

    //private let isLoading = PublishSubject<Bool>()

    init(apiClient: API = APIClient()) {
        self.apiClient = apiClient
        self.outputs = SectionViewModelOutput(
            sectionsRelay: BehaviorRelay<[SectionModel<String, SectionItemModel>]>(value: []),
            showLoadingRelay: PublishRelay<Bool>(),
            errorRelay: PublishRelay<String>()
        )
    }

    func loadFirstPage() {

        self.outputs.showLoadingRelay.accept(true)

        apiClient
            .getCountries()
            .subscribe(
                onNext: { [weak self] countries in
                    guard let self = self else { return }
                    let sections = self.createCountries(countries.results)
                    self.outputs.sectionsRelay.accept(sections)
                },
                onError: { [weak self] error in
                    self?.outputs.errorRelay.accept(error.localizedDescription)
                    self?.outputs.showLoadingRelay.accept(false)
                },
                onCompleted: { [weak self] in
                    self?.outputs.showLoadingRelay.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }

    // does nothing for this object
    func loadNextPage() {}

    private func createCountries(_ countries: [CountriesAPIModel.Country]) -> [SectionModel<String, SectionItemModel>] {

        let orderedCountriesWithNames = countries
            .filter { $0.name != nil }
            .map { SectionItemModel(code: $0.code, name: $0.name ?? "unknown") }
            .sorted { $0.name < $1.name }

        let groupedAlphabeticalCountries = Dictionary(grouping: orderedCountriesWithNames, by: { String($0.name.prefix(1)) })
        let sortedGroupedCountries = groupedAlphabeticalCountries.sorted { $0.key < $1.key }

        return sortedGroupedCountries.map { SectionModel(model: $0.key, items: $0.value) }
    }

}
