
import Foundation
import UIKit

/// A common place to make all ViewController
/// By having all VCs generated in one place we can bring together all the common components required to build the VCs
/// A lot of those components can then be hidden from the AppRouter and only those properties that specialise need be injected

struct ViewControllerFactory {

    func makeCountriesViewController(appActions: CountriesRouterActions) -> UIViewController {
        let viewController = SectionTableViewController(
            navigationTitle: "Countries",
            viewModel: CountriesViewModel(),
            routerActions: appActions)
        return viewController
    }

    func makeDetailsViewController(countryCode: String, appActions: CountriesRouterActions) -> UIViewController {
        let viewController = SectionTableViewController(
            navigationTitle: "Cities",
            viewModel: CitiesViewModel(countryCode: countryCode),
            routerActions: appActions)
        return viewController
    }
}
