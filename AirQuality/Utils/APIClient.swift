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

public class RequestObservable {

    private lazy var jsonDecoder = JSONDecoder()
    private var urlSession: URLSession

    public init(config:URLSessionConfiguration) {
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
        jsonDecoder.dateDecodingStrategy = .iso8601
    }

    //MARK: function for URLSession takes
    public func callAPI<ItemModel: Decodable>(request: URLRequest)
        -> Observable<ItemModel> {
            //MARK: creating our observable
            return Observable.create { observer in
                //MARK: create URLSession dataTask
                let task = self.urlSession.dataTask(with: request) { (data,
                    response, error) in
                    if let httpResponse = response as? HTTPURLResponse{
                        let statusCode = httpResponse.statusCode
                        do {
                            let _data = data ?? Data()
                            if (200...399).contains(statusCode) {
                                let objs = try self.jsonDecoder.decode(ItemModel.self, from:
                                    _data)
                                //MARK: observer onNext event
                                observer.onNext(objs)
                            }
                            else {
                                observer.onError(error!)
                            }
                        } catch {
                            //MARK: observer onNext event
                            observer.onError(error)
                        }
                    }
                    //MARK: observer onCompleted event
                    observer.onCompleted()
                }
                task.resume()
                //MARK: return our disposable
                return Disposables.create {
                    task.cancel()
                }
            }
    }
}


struct MeasurementsDataModel: Decodable {
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


class APIClient {

    static var shared = APIClient()
    lazy var requestObservable = RequestObservable(config: .default)

    func getMeasurements(escapedCityCode: String, pageNumber: Int, pageLimit: Int) throws -> Observable<MeasurementsDataModel> {
        var request = URLRequest(url:
            URL(string: "https://api.openaq.org/v1/measurements?city=" + escapedCityCode + "&page=\(pageNumber)&limit=\(pageLimit)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField:
            "Content-Type")
        return requestObservable.callAPI(request: request)
    }
}
