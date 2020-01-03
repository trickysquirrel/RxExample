//
//  APIClient.swift
//  AirQuality
//
//  Created by Richard Moult on 3/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import RxSwift
import RxCocoa


class APIClient {

    static var shared = APIClient()
    lazy var requestObservable = RequestObservable(config: .default)

    func getCountries() throws -> Observable<CountriesAPIModel> {
        var request = URLRequest(url: URL(string: "https://api.openaq.org/v1/countries")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField:
            "Content-Type")
        return requestObservable.callAPI(request: request)
    }

    func getCities(countryCode: String) throws -> Observable<CitiesAPIModel> {
        var request = URLRequest(url: URL(string: "https://api.openaq.org/v1/cities?country=" + countryCode)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField:
            "Content-Type")
        return requestObservable.callAPI(request: request)
    }

    func getMeasurements(escapedCityCode: String, pageNumber: Int, pageLimit: Int) throws -> Observable<MeasurementsAPIModel> {
        var request = URLRequest(url:
            URL(string: "https://api.openaq.org/v1/measurements?city=" + escapedCityCode + "&page=\(pageNumber)&limit=\(pageLimit)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField:
            "Content-Type")
        return requestObservable.callAPI(request: request)
    }
}