//
//  MeasurementsViewModel.swift
//  AirQuality
//
//  Created by Richard Moult on 2/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

private let parameters: [String: String] = [
    "bc": "Black Carbon",
    "co": "Carbon Monoxide",
    "no2": "Nitrogen Dioxide",
    "o3": "Ozone",
    "pm10": "Particulate matter less than 10 micrometers in diameter",
    "pm25": "Particulate matter less than 2.5 micrometers in diameter",
    "so2": "Sulfur Dioxide"
]

private struct MeasurementsDataModel: Decodable {
    let meta: Meta
    let results: [Result]

    struct Meta: Decodable {
        let name, license: String
        let website: String
        let page, limit, found: Int
    }

    struct Result: Decodable {
        let date: DateClass
        let parameter: String
        let location: String
        let value: Double
        let unit: String
    }

    struct DateClass: Decodable {
        let utc: String
        let local: Date
    }
}

class MeasurementsViewModel: SectionViewModel {

    let sections: BehaviorSubject<[SectionModel<String, SectionItemModel>]> = BehaviorSubject(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    private var metaData: MeasurementsDataModel.Meta?
    private let dateFormatter = DateFormatter()
    private var previousLoadedModels: [SectionItemModel] = []
    private let escapedCityCode: String
    private let pageLimit: Int = 100


    init(cityCode: String) {
        escapedCityCode = cityCode.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted) ?? "" // handle this error better
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .medium
    }

    func loadFirstPage() {
        loadNextPage()
    }

    private func nextPageNumber() -> Int? {
        let page = (metaData?.page ?? 0) + 1 // api first page = 1
        let numberOfPages = (metaData?.found ?? 1) / pageLimit
        let validNumberOfPages = max(numberOfPages, 1)
        if page <= validNumberOfPages {
            return page
        }
        return nil
    }

    func loadNextPage() {

        guard isLoading.value == false,
            let pageNumber = nextPageNumber()
            else { return }  // do nothing

        guard let url = URL(string: "https://api.openaq.org/v1/measurements?city=" + escapedCityCode + "&page=\(pageNumber)&limit=\(pageLimit)") else {
            // show error
            return
        }

        print(">>> isloading page url \(url.absoluteString)")
        isLoading.accept(true)

        URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            // handle status code network errors here
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let citiesModel = try decoder.decode(MeasurementsDataModel.self, from: data)
                self?.metaData = citiesModel.meta
                self?.appendLocations(citiesModel.results)
                self?.isLoading.accept(false)
            } catch let error {
                // handle data errors here
                self?.isLoading.accept(false)
                print("Error:", error.localizedDescription)
            }
        }.resume()

    }
    

    private func appendLocations(_ countries: [MeasurementsDataModel.Result]) {

        let orderedCountriesWithNames = countries
            .map { SectionItemModel(code: "", name: "location: \($0.location)\nvalue: \($0.value)\($0.unit) \n\(parameters[$0.parameter] ?? "unknown")\n\(dateFormatter.string(from: $0.date.local))") }

        previousLoadedModels += orderedCountriesWithNames

        var sectionModels: [SectionModel<String, SectionItemModel>] = []
        sectionModels.append(SectionModel(model: "", items: previousLoadedModels))
        sections.onNext(sectionModels)
    }

}
