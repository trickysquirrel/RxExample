//
//  APIClient.swift
//  AirQuality
//
//  Created by Richard Moult on 3/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import RxSwift
import RxCocoa

// https://www.codementor.io/@mehobega/urlsession-web-api-calls-reactive-way-rxswift-rxcocoa-10kmc5h669

protocol API {
    func getCountries() -> Observable<CountriesAPIModel>
    func getCities(countryCode: String) -> Observable<CitiesAPIModel>
    func getMeasurements(escapedCityCode: String, pageNumber: Int, pageLimit: Int) -> Observable<MeasurementsAPIModel>
}

class APIClient: API {

    private let requestObservable: RequestObservable

    init(networkSession: NetworkSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.requestObservable = RequestObservable(networkSession: networkSession)
    }

    // todo: remove throw in exchange for returning observable error to reduce view model code
    func getCountries() -> Observable<CountriesAPIModel> {
        guard let url = URL(string: "https://api.openaq.org/v1/countries") else {
            return createErrorObserver()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField:
            "Content-Type")
        return requestObservable.callAPI(request: request)
    }

    func getCities(countryCode: String) -> Observable<CitiesAPIModel> {
        guard let url = URL(string: "https://api.openaq.org/v1/cities?country=" + countryCode) else {
            return createErrorObserver()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField:
            "Content-Type")
        return requestObservable.callAPI(request: request)
    }

    func getMeasurements(escapedCityCode: String, pageNumber: Int, pageLimit: Int) -> Observable<MeasurementsAPIModel> {
        guard let url = URL(string: "https://api.openaq.org/v1/measurements?city=" + escapedCityCode + "&page=\(pageNumber)&limit=\(pageLimit)") else {
            return createErrorObserver()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField:
            "Content-Type")
        return requestObservable.callAPI(request: request)
    }

    private func createErrorObserver<T>() -> Observable<T> {
        return Observable.create { observer in
            let userInfo = [NSLocalizedDescriptionKey: "Url error"] // better error required
            observer.onError(NSError(domain: "url error", code: 0, userInfo: userInfo))
            observer.onCompleted()
            return Disposables.create {}
        }
    }

}
