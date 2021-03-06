//
//  MeasurementsDataModel.swift
//  AirQuality
//
//  Created by Richard Moult on 3/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import Foundation

struct MeasurementsAPIModel: Decodable {
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
