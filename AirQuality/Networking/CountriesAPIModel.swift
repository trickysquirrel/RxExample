//
//  CountriesDataModel.swift
//  AirQuality
//
//  Created by Richard Moult on 3/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import Foundation

struct CountriesAPIModel: Decodable {
    let meta: Meta
    let results: [Country]

    struct Meta: Decodable {
        let name, license: String
        let website: String
        let page, limit, found: Int
    }

    struct Country: Decodable {
        let code: String
        let count, locations, cities: Int
        let name: String?
    }
}
