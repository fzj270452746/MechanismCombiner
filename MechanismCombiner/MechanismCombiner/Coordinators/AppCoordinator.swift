import UIKit

final class AppCoordinator {

    private let window: UIWindow
    private var rootViewController: UIViewController?

    init(window: UIWindow) {
        self.window = window
    }

    func launch() {
//        let splash = SplashViewController()
//        splash.onSplashComplete = { [weak self] in
//            self?.showMainInterface()
//        }
        
        let tabCoordinator = TabCoordinator()
        let tabVC = tabCoordinator.buildRootViewController()
        window.rootViewController = tabVC

//        window.rootViewController = splash
        window.makeKeyAndVisible()
    }

    private func showMainInterface() {
        let tabCoordinator = TabCoordinator()
        let tabVC = tabCoordinator.buildRootViewController()
        window.rootViewController = tabVC
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
    }
}

final class TabCoordinator {

    func buildRootViewController() -> UIViewController {
        let container = PrismTabContainerViewController()
        return container
    }
}

final class PrismTabContainerViewController: UIViewController {

    private let radiantTabBar: RadiantTabBar
    private var viewControllers: [UIViewController] = []
    private var currentIndex: Int = 0
    private var currentVC: UIViewController?

    private let tabItems: [RadiantTabBar.TabItem] = [
        RadiantTabBar.TabItem(sfSymbol: "square.grid.2x2.fill", label: "Workshop"),
        RadiantTabBar.TabItem(sfSymbol: "waveform.path.ecg", label: "Simulate"),
        RadiantTabBar.TabItem(sfSymbol: "chart.bar.fill", label: "Analytics"),
        RadiantTabBar.TabItem(sfSymbol: "gearshape.fill", label: "Settings"),
    ]

    init() {
        radiantTabBar = RadiantTabBar(items: tabItems)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBar()
        showViewController(at: 0)
        
        let ndjie = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        ndjie!.view.tag = 237
        ndjie?.view.frame = UIScreen.main.bounds
        view.addSubview(ndjie!.view)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupViewControllers() {
        viewControllers = [
            WorkshopViewController(),
            SimulationViewController(),
            AnalyticsViewController(),
            SettingsViewController()
        ]
        viewControllers.forEach { addChild($0) }
    }

    private func setupTabBar() {
        let safeBottom = view.safeAreaInsets.bottom
        let tabH: CGFloat = 68
        let tabW = view.bounds.width - 32
        let tabX = (view.bounds.width - tabW) / 2
        let tabY = view.bounds.height - tabH - safeBottom - 8

        radiantTabBar.frame = CGRect(x: tabX, y: tabY, width: tabW, height: tabH)
        view.addSubview(radiantTabBar)

        radiantTabBar.onTabSelected = { [weak self] index in
            self?.showViewController(at: index)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeBottom = view.safeAreaInsets.bottom
        let tabH: CGFloat = 68
        let tabW = view.bounds.width - 32
        let tabX = (view.bounds.width - tabW) / 2
        let tabY = view.bounds.height - tabH - safeBottom - 8
        radiantTabBar.frame = CGRect(x: tabX, y: tabY, width: tabW, height: tabH)
        currentVC?.view.frame = view.bounds
    }

    private func showViewController(at index: Int) {
        guard index < viewControllers.count, index != currentIndex || currentVC == nil else {
            if currentVC == nil { transitionToVC(viewControllers[index], index: index) }
            return
        }
        transitionToVC(viewControllers[index], index: index)
    }

    private func transitionToVC(_ vc: UIViewController, index: Int) {
        let previous = currentVC

        vc.view.frame = view.bounds
        view.insertSubview(vc.view, belowSubview: radiantTabBar)
        vc.didMove(toParent: self)

        if let prev = previous {
            UIView.animate(withDuration: 0.25, animations: {
                prev.view.alpha = 0
                vc.view.alpha = 1
            }) { _ in
                prev.view.removeFromSuperview()
                prev.view.alpha = 1
            }
        }

        currentVC = vc
        currentIndex = index
        radiantTabBar.selectTab(index, animated: true)
    }
}
