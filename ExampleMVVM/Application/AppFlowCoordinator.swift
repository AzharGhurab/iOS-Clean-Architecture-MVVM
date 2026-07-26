import UIKit

final class AppFlowCoordinator {
    
    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    private var authFlow: AuthFlowCoordinator?
    init(
        navigationController: UINavigationController,
        appDIContainer: AppDIContainer
    ) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        let tabBarController = UITabBarController()
        setupTabBarAppearance(tabBarController.tabBar)
        
        let moviesSceneDIContainer = appDIContainer.makeMoviesSceneDIContainer()
        
        let homeNavigationController = UINavigationController()
        homeNavigationController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "house"),
                selectedImage: UIImage(named: "house")
        )
        let homeFlow = moviesSceneDIContainer.makeMoviesHomeFlowCoordinator(
            navigationController: homeNavigationController
        )
        homeFlow.start()
        let searchNavigationController = UINavigationController()
        searchNavigationController.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(named: "magnifyingglass"),
            selectedImage: UIImage(named: "magnifyingglass")
        )
        let flow = moviesSceneDIContainer.makeMoviesSearchFlowCoordinator(
            navigationController: searchNavigationController
        )
        flow.start()
        let profileNavigationController = UINavigationController(rootViewController: ProfileViewController())
        authFlow = moviesSceneDIContainer.makeAuthFlowCoordinator(
            navigationController: profileNavigationController
        )
        authFlow?.start()
        profileNavigationController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(named: "person"),
                selectedImage: UIImage(named: "person")
        )
        
        tabBarController.viewControllers = [
            homeNavigationController,
            searchNavigationController,
            profileNavigationController
        ]
        
        navigationController.setViewControllers([tabBarController], animated: false)
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
}
    // MARK: - Tab Bar Appearance
    private extension AppFlowCoordinator {
        
        func setupTabBarAppearance(_ tabBar: UITabBar) {
            tabBar.tintColor = .systemBlue
            tabBar.unselectedItemTintColor = .darkGray
            tabBar.isTranslucent = false
            
            tabBar.itemPositioning = .fill
            tabBar.itemSpacing = 0
            
        }
    }
