//
//  Array+ElementAt.swift
//  AirQuality
//
//  Created by Richard Moult on 1/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import Foundation

public extension Array {

    func element(atIndex index: Int) -> Element? {
        guard index >= 0 else { return .none }
        guard endIndex > index else { return .none }

        return self[index]
    }
    
}
