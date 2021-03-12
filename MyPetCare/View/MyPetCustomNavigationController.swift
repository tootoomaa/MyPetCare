//
//  MyPetCustomNavigationController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

import Foundation
import UIKit
import SideMenu
import RxSwift

class MyPetCustomNavigationController: UITabBarController {
    
    private let disposeBag = DisposeBag()
    
    private let provider: ServiceProviderType
    
    private var sideMenuRootVC: SideMenuViewController!
    private lazy var sideMenuNav = SideMenuNavigationController(rootViewController: sideMenuRootVC)
    
    private let sideMenuButton = UIButton().then {
        let image = UIImage(systemName: "line.horizontal.3")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.black)
        $0.setImage(image, for: .normal)
        $0.imageView?.frame.size = CGSize(width: 30, height: 30)
    }
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
        
        configureSideMenu()
        
        let first = makeMainViewController("hare.fill")
        let second = makeStaticticsViewController("chart.bar.xaxis")
        
        self.viewControllers = [first, second]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SideMenu Configure
    private func configureSideMenu() {
        let reactor = SideMenuViewReactor(provider: provider)
        sideMenuRootVC = SideMenuViewController()
        sideMenuRootVC.reactor = reactor
        
        sideMenuButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
 
                let sideMenu = SideMenuManager.default.leftMenuNavigationController!
                owner.present(sideMenu, animated: true)
                
            }).disposed(by: disposeBag)
        
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        presentationStyle.backgroundColor = .black
        presentationStyle.menuStartAlpha = 1
        presentationStyle.onTopShadowOpacity = 10
        presentationStyle.presentingEndAlpha = CGFloat(0.5)
        presentationStyle.presentingScaleFactor = CGFloat(0.9)
        presentationStyle.menuOnTop = true
        
        _ = sideMenuNav.then {
            $0.dismissOnPresent = true
            $0.dismissOnPush = true
            $0.enableTapToDismissGesture = true
            $0.enableSwipeToDismissGesture = true
            $0.statusBarEndAlpha = 0
            $0.menuWidth = Constants.viewWidth*Constants.sideMenuWidthSizeRatio
            $0.presentationStyle = presentationStyle
        }
        
        SideMenuManager.default.leftMenuNavigationController = sideMenuNav
        SideMenuManager.default.leftMenuNavigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Make Navigation Controller
    private func makeMainViewController(_ imageName: String) -> UINavigationController {
        let reacotr = MainViewControllerReactor(provider: provider)
        let vc = MainViewController()
        vc.reactor = reacotr
        
        let image = makeNomalSelectedImage(imageName)
        let tabBar = UITabBarItem(title: nil, image: image.0, selectedImage: image.1)
        
        vc.tabBarItem = tabBar
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: sideMenuButton)
        
        let naviC = SideMenuNavigationController(rootViewController: vc)
        naviC.configureNavigation(Constants.mainColor, largeTitle: true)
        
        SideMenuManager.default.addPanGestureToPresent(toView: naviC.view)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: naviC.view)
        
        return naviC
    }
    
    private func makeStaticticsViewController(_ imageName: String) -> UINavigationController{
        let reactor = StatisticsViewReactor(provider: provider)
        let vc = StatisticsViewController()
        vc.reactor = reactor
        
        let image = makeNomalSelectedImage(imageName)
        let tabBar = UITabBarItem(title: nil, image: image.0, selectedImage: image.1)
        
        vc.tabBarItem = tabBar
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: sideMenuButton)
    
        let naviC = SideMenuNavigationController(rootViewController: vc)
        naviC.configureNavigation(.white, largeTitle: true)
        
        SideMenuManager.default.addPanGestureToPresent(toView: naviC.view)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: naviC.view)
        
        return naviC
    }
    
    
    func makeNomalSelectedImage(_ name: String) -> (UIImage, UIImage) {
        
        let image = UIImage(systemName: name)!.withRenderingMode(.alwaysOriginal)
        
        let nomal = image.withTintColor(.systemGray4)
        let selected = image.withTintColor(.black)
        
        return (nomal, selected)
    }
}
