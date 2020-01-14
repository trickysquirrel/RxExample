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

struct SectionItemModel: Decodable, Equatable {
    let code: String
    let name: String
}

protocol SectionViewModelType {
    var inputs: SectionViewModelTypeInputs { get  }
    var outputs: SectionViewModelOutput { get }
}

protocol SectionViewModelTypeInputs {
    func loadFirstPage()
    func loadNextPage()
}

struct SectionViewModelOutput {
    let sectionsRelay: BehaviorRelay<[SectionModel<String, SectionItemModel>]>
    let showLoadingRelay: PublishRelay<Bool>
    let errorRelay: PublishRelay<String>
}
