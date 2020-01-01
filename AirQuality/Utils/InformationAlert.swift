import UIKit

protocol InformationAlertProtocol {
    func displayAlert(title: String, message: String, presentingViewController: UIViewController?)
}


struct InformationAlert: InformationAlertProtocol {

    func displayAlert(title: String, message: String, presentingViewController: UIViewController?) {

        guard let presentingViewController = presentingViewController else { return }
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        presentingViewController.present(alertController, animated: true, completion: nil)
    }

}

