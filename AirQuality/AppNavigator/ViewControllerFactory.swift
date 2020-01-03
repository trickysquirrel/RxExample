
import Foundation
import UIKit

/// A common place to make all ViewController
/// By having all VCs generated in one place we can bring together all the common components required to build the VCs
/// A lot of those components can then be hidden from the Navigator and only those properties that specialise need be injected

struct ViewControllerFactory {

    func makeCountriesViewController(appActions: DetailsNavigator) -> UIViewController {
        let viewController = SectionTableViewController(
            navigationTitle: "Countries",
            viewModel: CountriesViewModel(),
            cellActions: appActions)
        return viewController
    }

    func makeCitiesViewController(countryCode: String, appActions: DetailsNavigator) -> UIViewController {
        let viewController = SectionTableViewController(
            navigationTitle: "Cities",
            viewModel: CitiesViewModel(countryCode: countryCode),
            cellActions: appActions)
        return viewController
    }

    func makeMeasurementsViewController(cityName: String, code: String) -> UIViewController {
        let viewController = SectionTableViewController(
            navigationTitle: cityName,
            viewModel: MeasurementsViewModel(cityCode: code),
            cellActions: nil)
        return viewController
    }
}
