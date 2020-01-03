## RxSwift/RxCocoa with MVVM

Exploring the world of RxSwift using MVVM (how simple can we make the code?).

![Demo](https://github.com/trickysquirrel/RxExample/blob/master/rxexmple.2020-01-03%2021_47_48.gif)

#### AppNavigator

Each ViewController in this example app uses a table.  Rather than creating a seperate ViewControllers for each view this example reuses `SectionTableViewController` for each ViewController with different ViewModels depending on the needs to the view.

This works by having a seperate location to create each ViewController , in this case the `ViewControllerFactory`.  This factory injects the different ViewModels depending on what information we want to display.  

As we only have one VC but require the cell selections to navigate to different VC, we also need to seperate out the navigating of those VCs, in this case we use `AppNavigator`.

Together this allows reuse of the table view controller to show differnent information


### Todo

Work on error handing
Show errors and retry

