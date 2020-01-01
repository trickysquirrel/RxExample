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

private struct CitiesDataModel: Decodable {
    let meta: Meta
    let results: [Result]

    struct Meta: Decodable {
        let name, license: String
        let website: String
        let page, limit, found: Int
    }

    struct Result: Decodable {
        let name, city: String
        let count, locations: Int
    }
}

class CitiesViewModel: SectionViewModel {

    let sections: BehaviorSubject<[SectionModel<String, SectionItemModel>]> = BehaviorSubject(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
    private let url: URL?
    private let ignoreName = "N/A"

    init(countryCode: String) {
        let urlString = "https://api.openaq.org/v1/cities?country=" + countryCode
        self.url = URL(string: urlString)
    }

    func loadData() {

        guard let url = url else {
            // show error
            return
        }

        isLoading.accept(true)

        URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            // handle status code network errors here
            guard let data = data else { return }
            do {
                let citiesModel = try JSONDecoder().decode(CitiesDataModel.self, from: data)
                self?.updateCities(citiesModel.results)
                self?.isLoading.accept(false)
            } catch let error {
                // handle data errors here
                self?.isLoading.accept(false)
                print("Error:", error.localizedDescription)
            }
        }.resume()
    }


    private func updateCities(_ countries: [CitiesDataModel.Result]) {

        let orderedCountriesWithNames = countries
            .filter { $0.name != ignoreName }
            .map { SectionItemModel(code: $0.name, name: $0.city) }
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
