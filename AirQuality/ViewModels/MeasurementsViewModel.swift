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


class MeasurementsViewModel: SectionViewModelType, SectionViewModelTypeInputs, SectionViewModelTypeOutputs {

    var inputs: SectionViewModelTypeInputs { return self}
    var outputs: SectionViewModelTypeOutputs { return self}

    let sections: BehaviorSubject<[SectionModel<String, SectionItemModel>]> = BehaviorSubject(value: [])
    let showLoading = BehaviorRelay<Bool>(value: false)
    private var isLoading: Bool = false
    private var metaData: MeasurementsAPIModel.Meta?
    private var previousLoadedModels: [SectionItemModel] = []

    private let dateFormatter = DateFormatter()
    private let escapedCityCode: String
    private let pageLimit: Int = 100
    private let disposeBag = DisposeBag()


    init(cityCode: String) {
        // todo does not handle this correctly with all cities yet, need to check API as to why
        escapedCityCode = cityCode.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted) ?? "" // handle this error better
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .medium
    }

    func loadFirstPage() {
        loadNextPage()
    }

    func loadNextPage() {

        guard isLoading == false,
            let pageNumber = nextPageNumber()
            else { return }  // do nothing

        setLoading(pageNumber: pageNumber, loading: true)

        let client = APIClient.shared
        do {
            try client.getMeasurements(escapedCityCode: escapedCityCode, pageNumber: pageNumber, pageLimit: pageLimit)
                .subscribe(
                    onNext: { [weak self] measurements in
                        self?.metaData = measurements.meta
                        self?.appendLocations(measurements.results)
                    },
                    onError: { error in
                        // handle data/network errors here
                        print(error.localizedDescription)
                    },
                    onCompleted: { [weak self] in
                        self?.setLoading(pageNumber: pageNumber, loading: false)
                    })
                    .disposed(by: disposeBag)
        }
        catch {
            self.setLoading(pageNumber: pageNumber, loading: false)
            // handle error, e.g could not create url
        }
    }


    private func setLoading(pageNumber: Int, loading: Bool) {
        isLoading = loading
        if pageNumber == 1 {
            showLoading.accept(loading)
        }
    }
    

    private func appendLocations(_ countries: [MeasurementsAPIModel.Result]) {

        let orderedCountriesWithNames = countries
            .map { SectionItemModel(code: "", name: "location: \($0.location)\nvalue: \($0.value)\($0.unit) \n\(parameters[$0.parameter] ?? "unknown")\n\(dateFormatter.string(from: $0.date.local))") }

        previousLoadedModels += orderedCountriesWithNames

        var sectionModels: [SectionModel<String, SectionItemModel>] = []
        sectionModels.append(SectionModel(model: "", items: previousLoadedModels))
        sections.onNext(sectionModels)
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

}
