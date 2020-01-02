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

private struct CountriesDataModel: Decodable {
    let meta: Meta
    let results: [Country]

    struct Meta: Decodable {
        let name, license: String
        let website: String
        let page, limit, found: Int
    }

    struct Country: Decodable {
        let code: String
        let count, locations, cities: Int
        let name: String?
    }
}


class CountriesViewModel: SectionViewModel {

    let sections: BehaviorSubject<[SectionModel<String, SectionItemModel>]> = BehaviorSubject(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
    private let url = URL(string: "https://api.openaq.org/v1/countries")!


    func loadFirstPage() {

        isLoading.accept(true)

        URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            // handle status code network errors here
            guard let data = data else { return }
            do {
                let countriesModel = try JSONDecoder().decode(CountriesDataModel.self, from: data)
                self?.updateCountries(countriesModel.results)
                self?.isLoading.accept(false)
            } catch let error {
                // handle data errors here
                self?.isLoading.accept(false)
                print("Error:", error.localizedDescription)
            }
        }.resume()
    }

    
    func loadNextPage() {}


    private func updateCountries(_ countries: [CountriesDataModel.Country]) {

        let orderedCountriesWithNames = countries
            .filter { $0.name != nil }
            .map { SectionItemModel(code: $0.code, name: $0.name ?? "unknown") }
            .sorted { $0.name < $1.name }

        let groupedAlphabeticalCountries = Dictionary(grouping: orderedCountriesWithNames, by: { String($0.name.prefix(1)) })
        let sortedGroupedCountries = groupedAlphabeticalCountries.sorted { $0.key < $1.key }

        var sectionModels: [SectionModel<String, SectionItemModel>] = []

        for group in sortedGroupedCountries {
            sectionModels.append(SectionModel(model: group.key, items: group.value)) // groupkey
        }

        sections.onNext(sectionModels)
    }

}
