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


class CitiesViewModel: SectionViewModelType, SectionViewModelTypeInputs, SectionViewModelTypeOutputs {

    var inputs: SectionViewModelTypeInputs { return self}
    var outputs: SectionViewModelTypeOutputs { return self}

    let sections: BehaviorSubject<[SectionModel<String, SectionItemModel>]> = BehaviorSubject(value: [])
    let showLoading = BehaviorRelay<Bool>(value: true)

    private let countryCode: String
    private let disposeBag = DisposeBag()
    private let ignoreName = "N/A"

    init(countryCode: String) {
        self.countryCode = countryCode
    }

    func loadFirstPage() {

        let client = APIClient.shared
        do {
            try client.getCities(countryCode: countryCode)
                .subscribe(
                    onNext: { [weak self] cities in
                        self?.updateCities(cities.results)
                    },
                    onError: { error in
                        // handle data/network errors here
                        print(error.localizedDescription)
                    },
                    onCompleted: { [weak self] in
                        self?.showLoading.accept(false)
                    }
                )
                .disposed(by: disposeBag)
        }
        catch {
            self.showLoading.accept(false)
            // handle error, e.g could not create url
        }
    }

    // does nothing for this object
    func loadNextPage() {}


    private func updateCities(_ countries: [CitiesAPIModel.Result]) {

        let orderedCitiesWithNames = countries
            .filter { $0.name != ignoreName }
            .map { SectionItemModel(code: $0.name, name: $0.city) }
            .sorted { $0.name < $1.name }

        let groupedAlphabeticalCities = Dictionary(grouping: orderedCitiesWithNames, by: { String($0.name.prefix(1)) })
        let sortedGroupedCities = groupedAlphabeticalCities.sorted { $0.key < $1.key }

        // [SectionModel<String, SectionItemModel>]
        let sectionModels = sortedGroupedCities.map { SectionModel(model: $0.key, items: $0.value) }
        sections.onNext(sectionModels)
    }

}
