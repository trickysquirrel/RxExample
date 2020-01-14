//
//  CountriesViewModelTests.swift
//  AirQualityTests
//
//  Created by Richard Moult on 13/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxDataSources
import Nimble
@testable import AirQuality

class CountriesViewModelTests: XCTestCase {

    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
    }

    override func tearDown() {
        self.scheduler = nil
        self.disposeBag = nil
    }

    func test_receives_showLoading_on_call_to_loadFirstPage_then_again_once_network_call_complete() {
        let viewModel = CountriesViewModel(apiClient: FakeAPIClient())

        let loadingCollector = RxCollector<Bool>()
            .collect(from: viewModel.outputs.showLoadingRelay.asObservable())
        
        viewModel.inputs.loadFirstPage()

        expect(loadingCollector.toArray).toEventually(equal([true, false]))
    }

    // Need to change the tests so FakeAPIClient can return multiple responses so we can test loading at the same time as errors

    func test_apiClient_error_receives_errorString() {

        let viewModel = CountriesViewModel(apiClient: FakeAPIClient(error: NSError(domain: "d", code: 0, userInfo: nil)))

         let errorCollector = RxCollector<String>()
            .collect(from: viewModel.outputs.errorRelay.asObservable())

      //  let loadingCollector = RxCollector<Bool>()
       //     .collect(from: viewModel.outputs.showLoadingRelay.asObservable())

        viewModel.inputs.loadFirstPage()

       // expect(loadingCollector.toArray).toEventually(equal([true, false]))
        expect(errorCollector.toArray).toEventually(equal(["The operation couldn’t be completed. (d error 0.)"]))
    }

    func test_apiClient_success_receives_correct_sections_and_loading_states() {

        let countriesAPIModel = CountriesAPIModel(
            meta: CountriesAPIModel.Meta(name: "", license: "", website: "", page: 0, limit: 0, found: 1),
            results: [
                CountriesAPIModel.Country(code: "BE", count: 1, locations: 1, cities: 1, name: "Belgium"),
                CountriesAPIModel.Country(code: "AU", count: 1, locations: 1, cities: 1, name: "Australia"),
                CountriesAPIModel.Country(code: "AF", count: 1, locations: 1, cities: 1, name: "Afganistan")
            ]
        )

        let viewModel = CountriesViewModel(apiClient: FakeAPIClient(countriesAPIModel: countriesAPIModel))

        let sectionsCollector = RxCollector<[SectionModel<String, SectionItemModel>]>()
            .collect(from: viewModel.outputs.sectionsRelay.asObservable())

        let loadingCollector = RxCollector<Bool>()
            .collect(from: viewModel.outputs.showLoadingRelay.asObservable())

        viewModel.inputs.loadFirstPage()

        let expectedSections = [SectionModel(model: "A", items: [SectionItemModel(code: "AF", name: "Afganistan"),
                                                                 SectionItemModel(code: "AU", name: "Australia")]),
                                SectionModel(model: "B", items: [SectionItemModel(code: "BE", name: "Belgium")])]

        expect(loadingCollector.toArray).toEventually(equal([true, false]))
        expect(sectionsCollector.toArray).toEventually(equal([[], expectedSections]))
    }
}