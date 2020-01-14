//
//  CitiesViewModel.swift
//  AirQuality
//
//  Created by Richard Moult on 1/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class CitiesViewModel: SectionViewModelType, SectionViewModelTypeInputs {

    var inputs: SectionViewModelTypeInputs { return self }
    var outputs: SectionViewModelOutput

    private let countryCode: String
    private let disposeBag = DisposeBag()
    private let apiClient: API
    private let ignoreName = "N/A"

    init(countryCode: String, apiClient: API = APIClient()) {
        self.countryCode = countryCode
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
            .getCities(countryCode: countryCode)
            .subscribe(
                onNext: { [weak self] cities in
                    guard let self = self else { return }
                    let sections = self.createCities(cities.results)
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

    private func createCities(_ countries: [CitiesAPIModel.Result]) -> [SectionModel<String, SectionItemModel>] {

        let orderedCitiesWithNames = countries
            .filter { $0.name != ignoreName }
            .map { SectionItemModel(code: $0.name, name: $0.city) }
            .sorted { $0.name < $1.name }

        let groupedAlphabeticalCities = Dictionary(grouping: orderedCitiesWithNames, by: { String($0.name.prefix(1)) })
        let sortedGroupedCities = groupedAlphabeticalCities.sorted { $0.key < $1.key }

        // [SectionModel<String, SectionItemModel>]
        return sortedGroupedCities.map { SectionModel(model: $0.key, items: $0.value) }
    }

}
