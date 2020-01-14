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

class MeasurementsViewModel: SectionViewModelType, SectionViewModelTypeInputs {

    var inputs: SectionViewModelTypeInputs { return self }
    var outputs: SectionViewModelOutput

    private var isLoading: Bool = false
    private var metaData: MeasurementsAPIModel.Meta?
    private var previousLoadedModels: [SectionItemModel] = []

    private let dateFormatter = DateFormatter()
    private let escapedCityCode: String
    private let pageLimit: Int = 100
    private let disposeBag = DisposeBag()
    private let apiClient: API

    init(cityCode: String, apiClient: API = APIClient()) {
        // todo does not handle this correctly with all cities yet, need to check API as to why
        // handle this error better
        escapedCityCode = cityCode.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted) ?? ""
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .medium
        self.apiClient = apiClient
        self.outputs = SectionViewModelOutput(
            sectionsRelay: BehaviorRelay<[SectionModel<String, SectionItemModel>]>(value: []),
            showLoadingRelay: PublishRelay<Bool>(),
            errorRelay: PublishRelay<String>()
        )
    }

    func loadFirstPage() {
        loadNextPage()
    }

    func loadNextPage() {

        guard isLoading == false,
            let pageNumber = nextPageNumber()
            else { return }  // do nothing

        setLoading(pageNumber: pageNumber, loading: true)

        apiClient
            .getMeasurements(escapedCityCode: escapedCityCode, pageNumber: pageNumber, pageLimit: pageLimit)
            .subscribe(
                onNext: { [weak self] measurements in
                    self?.metaData = measurements.meta
                    self?.appendLocations(measurements.results)
                },
                onError: { [weak self] error in
                    self?.outputs.errorRelay.accept(error.localizedDescription)
                },
                onCompleted: { [weak self] in
                    self?.setLoading(pageNumber: pageNumber, loading: false)
                }
            )
            .disposed(by: disposeBag)
    }

    private func setLoading(pageNumber: Int, loading: Bool) {
        isLoading = loading
        if pageNumber == 1 {
            outputs.showLoadingRelay.accept(loading)
        }
    }

    private func appendLocations(_ countries: [MeasurementsAPIModel.Result]) {

        let orderedCountriesWithNames = countries
            .map { SectionItemModel(code: "", name: "location: \($0.location)\nvalue: \($0.value)\($0.unit) \n\(parameters[$0.parameter] ?? "unknown")\n\(dateFormatter.string(from: $0.date.local))") }

        previousLoadedModels += orderedCountriesWithNames

        let sectionModels = [SectionModel(model: "", items: previousLoadedModels)]
        outputs.sectionsRelay.accept(sectionModels)
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
