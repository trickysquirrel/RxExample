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


class CountriesViewModel: SectionViewModelType, SectionViewModelTypeInputs, SectionViewModelTypeOutputs {

    var inputs: SectionViewModelTypeInputs { return self}
    var outputs: SectionViewModelTypeOutputs { return self}

    let sections: BehaviorSubject<[SectionModel<String, SectionItemModel>]> = BehaviorSubject(value: [])
    let showLoading = BehaviorRelay<Bool>(value: true)

    private let disposeBag = DisposeBag()


    func loadFirstPage() {

        showLoading.accept(true)

        let client = APIClient.shared
        do {
            try client.getCountries()
                .subscribe(
                    onNext: { [weak self] countries in
                        self?.updateCountries(countries.results)
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


    private func updateCountries(_ countries: [CountriesAPIModel.Country]) {

        let orderedCountriesWithNames = countries
            .filter { $0.name != nil }
            .map { SectionItemModel(code: $0.code, name: $0.name ?? "unknown") }
            .sorted { $0.name < $1.name }

        let groupedAlphabeticalCountries = Dictionary(grouping: orderedCountriesWithNames, by: { String($0.name.prefix(1)) })
        let sortedGroupedCountries = groupedAlphabeticalCountries.sorted { $0.key < $1.key }

        // [SectionModel<String, SectionItemModel>]
        let sectionModels = sortedGroupedCountries.map { SectionModel(model: $0.key, items: $0.value) }
        sections.onNext(sectionModels)
    }

}
