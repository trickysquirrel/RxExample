//
//  NetworkSession.swift
//  AirQuality
//
//  Created by Richard Moult on 13/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import Foundation

public protocol NetworkSession {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: NetworkSession {}
