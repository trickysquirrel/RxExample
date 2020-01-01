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
    let isLoading = BehaviorRelay<Bool>(value: true)
    private let url: URL?
    private let dateFormatter = DateFormatter()


    init(cityCode: String) {
        let escapedCityCode = cityCode.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted) ?? "" // handle this error better
        let urlString = "https://api.openaq.org/v1/measurements?city=" + escapedCityCode
        print(urlString)
        self.url = URL(string: urlString)
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .medium
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
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let citiesModel = try decoder.decode(MeasurementsDataModel.self, from: data)
                self?.updateLocations(citiesModel.results)
                self?.isLoading.accept(false)
                print(citiesModel)
            } catch let error {
                // handle data errors here
                self?.isLoading.accept(false)
                print("Error:", error.localizedDescription)
            }
        }.resume()
    }


    private func updateLocations(_ countries: [MeasurementsDataModel.Result]) {

        let orderedCountriesWithNames = countries
            .map { SectionItemModel(code: "", name: "location: \($0.location)\nvalue: \($0.value)\($0.unit) \ndate: \(dateFormatter.string(from: $0.date.local)) \n\(parameters[$0.parameter] ?? "unknown")") }

        var sectionModels: [SectionModel<String, SectionItemModel>] = []

        sectionModels.append(SectionModel(model: "", items: orderedCountriesWithNames))


        sections.onNext(sectionModels)
    }

}
