//
//  SectionViewModel.swift
//  AirQuality
//
//  Created by Richard Moult on 1/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources


struct SectionItemModel: Decodable {
    let code: String
    let name: String
}

protocol SectionViewModel {
    var sections: BehaviorSubject<[SectionModel<String, SectionItemModel>]> { get }
    var showLoading: BehaviorRelay<Bool> { get }
    func loadFirstPage()
    func loadNextPage()
}
