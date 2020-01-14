//
//  TestUtils.swift
//  AirQualityTests
//
//  Created by Richard Moult on 14/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import Foundation
import RxSwift
@testable import AirQuality

// https://medium.com/@kenmarin_23370/rxswift-testing-variables-publishersubject-observable-with-convenience-7a6644b1b0f8

class RxCollector<T> {
    var deadBodies: DisposeBag = DisposeBag()
    var toArray: [T] = [T]()
    func collect(from observable: Observable<T>) -> RxCollector {
        observable.asObservable()
            .subscribe(onNext: { (newZombie) in
                self.toArray.append(newZombie)
            })
            .disposed(by: deadBodies)
       return self
    }
}

struct FakeAPIClient: API {

    private static let defaultCountriesAPIModel = CountriesAPIModel(
        meta: CountriesAPIModel.Meta(name: "", license: "", website: "", page: 0, limit: 0, found: 1),
        results: [CountriesAPIModel.Country(code: "", count: 1, locations: 1, cities: 1, name: "")]
    )

    private static let defaultFakeCitiesAPIModel = CitiesAPIModel(
        meta: CitiesAPIModel.Meta(name: "", license: "", website: "", page: 0, limit: 0, found: 1),
        results: [CitiesAPIModel.Result(name: "", city: "", count: 1, locations: 1)]
    )

    private static let fakeMeasurementsAPIModel = MeasurementsAPIModel(
        meta: MeasurementsAPIModel.Meta(name: "", license: "", website: "", page: 0, limit: 0, found: 0),
        results: [
            MeasurementsAPIModel.Result(date: MeasurementsAPIModel.DateClass(utc: "", local: Date()),
                                        parameter: "",
                                        location: "",
                                        value: 0.0,
                                        unit: "")
        ]
    )

    private var fakeCountriesAPIModel: CountriesAPIModel
    private var fakeCitiesAPIModel: CitiesAPIModel
    private var fakeMeasurementsAPIModel: MeasurementsAPIModel
    private var error: NSError?

    init(countriesAPIModel: CountriesAPIModel = FakeAPIClient.defaultCountriesAPIModel,
         citiesAPIModel: CitiesAPIModel = FakeAPIClient.defaultFakeCitiesAPIModel,
         measurementsAPIModel: MeasurementsAPIModel = FakeAPIClient.fakeMeasurementsAPIModel,
         error: NSError? = nil) {
        self.fakeCountriesAPIModel = countriesAPIModel
        self.fakeCitiesAPIModel = citiesAPIModel
        self.fakeMeasurementsAPIModel = measurementsAPIModel
        self.error = error
    }

    func getCountries() -> Observable<CountriesAPIModel> {
        // need to find a better way to do this as this complete is called too late RxTest time?
        if let error = error {
            return Observable.create { observer in
                observer.onError(error)
                observer.onCompleted()
                return Disposables.create {}
            }
        }
        return Observable.just(self.fakeCountriesAPIModel)
    }

    func getCities(countryCode: String) -> Observable<CitiesAPIModel> {
        return Observable.just(self.fakeCitiesAPIModel)
    }

    func getMeasurements(escapedCityCode: String, pageNumber: Int, pageLimit: Int) -> Observable<MeasurementsAPIModel> {
        return Observable.just(self.fakeMeasurementsAPIModel)
    }
}

//extension CountriesViewModelTests {
//    private func givenSessionDoubleWithNetworkError(error: NSError = NSError(domain: "", code: 0, userInfo: nil)) -> DummyURLSession {
//        let session = DummyURLSession()
//        session.data = nil
//        let url = URL(string: "http://dummyURLSession")!
//        session.response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: .none, headerFields: .none)
//        session.error = NSError(domain: "errorDomain", code: 100, userInfo: nil)
//        return session
//    }
//}
//
//class DummyURLSession: NetworkSession {
//    var data: Data?
//    var response: URLResponse?
//    var error: Error?
//
//    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
//        completionHandler(data, response, error)
//        return task
//    }
//}
