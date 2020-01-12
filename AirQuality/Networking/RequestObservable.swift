//
//  RequestObservable.swift
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

    public init(config: URLSessionConfiguration) {
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
        jsonDecoder.dateDecodingStrategy = .iso8601
    }

    // MARK: function for URLSession takes
    public func callAPI<ItemModel: Decodable>(request: URLRequest) -> Observable<ItemModel> {
            // MARK: creating our observable
            return Observable.create { observer in
                // MARK: create URLSession dataTask
                let task = self.urlSession.dataTask(with: request) { (data, response, error) in
                    if let httpResponse = response as? HTTPURLResponse {
                        let statusCode = httpResponse.statusCode
                        do {
                            let validData = data ?? Data()
                            if (200...399).contains(statusCode) {
                                let objs = try self.jsonDecoder.decode(ItemModel.self, from: validData)
                                // MARK: observer onNext event
                                observer.onNext(objs)
                            } else {
                                observer.onError(error!)
                            }
                        } catch {
                            // MARK: observer onNext event
                            observer.onError(error)
                        }
                    }
                    // MARK: observer onCompleted event
                    observer.onCompleted()
                }
                task.resume()
                // MARK: return our disposable
                return Disposables.create {
                    task.cancel()
                }
            }
    }
}
