import UIKit
import DJSemiModalViewController

/// For RouterActions perfer to use Values rather than Classes to keep a stricter control dependancy and side effects

protocol CountriesRouterActions: class {
    func showCountryDetails(from viewController: UIViewController, countryName: String)
}


/// Simple AppRouter that controls navigation throughout the app
/// Encourages a greater seperation of concerns between ViewController (VC) and navigation.
/// This way we can focus ViewController on just the logic they need to perform their job
/// Also having this seperation allows us to easily manipulated the flow of the app for A/B testing without VCs needing to know

class AppRouter {

    private let window: UIWindow
    private let navigationController: UINavigationController
    private let viewControllerFactory: ViewControllerFactory
    private let informationAlert: InformationAlertProtocol

    // Large scale application that push and pop whilst animating can suffer random failures when used alot in unit tests as the system can get confused,
    // by removing the animation we make the test simpler by not needing an expectation and more robust as timing is not involded which
    // causes the majority of flaky tests of these kind, so injecting the animation value here so tests can set to false
    private let animateTransitions: Bool


    init(window: UIWindow,
         navigationController: UINavigationController,
         viewControllerFactory: ViewControllerFactory,
         informationAlert: InformationAlertProtocol,
         animateTransitions: Bool) {
        self.window = window
        self.viewControllerFactory = viewControllerFactory
        self.navigationController = navigationController
        self.informationAlert = informationAlert
        self.animateTransitions = animateTransitions
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }


    func start() {
        let viewController = viewControllerFactory.makeCountriesViewController(appActions: self)
        navigationController(navigationController, pushOnViewController: viewController, animated: false)
    }


    private func navigationController(_ navigationController: UINavigationController, pushOnViewController viewController:UIViewController, animated: Bool) {
        navigationController.pushViewController(viewController, animated: animateTransitions)
    }
}


extension AppRouter: CountriesRouterActions {

    func showCountryDetails(from viewController: UIViewController, countryName: String) {
        viewController.view.alpha = 0.5
        let controller = DJSemiModalViewController()
        controller.title = countryName
        let label = UILabel()
        label.text = "An example label"
        label.textAlignment = .center
        controller.addArrangedSubview(view: label)
        controller.presentOn(presentingViewController: viewController, animated: true, onDismiss: {
            viewController.view.alpha = 1.0
        })
    }
}
