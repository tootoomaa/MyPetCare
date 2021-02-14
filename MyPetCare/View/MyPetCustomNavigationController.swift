//
//  MyPetCustomNavigationController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

import Foundation
import UIKit

class MyPetCustomNavigationController: UITabBarController {
    
    private let provider: ServiceProviderType
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
        
        let first = makeMainViewController("hare.fill")
        let second = makeStaticticsViewController("chart.bar.xaxis")
        
        self.viewControllers = [first, second]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeMainViewController(_ imageName: String) -> UINavigationController {
        let reacotr = MainViewControllerReactor(provider: provider)
        let vc = NewMainViewController()
        vc.reactor = reacotr
        
        let image = makeNomalSelectedImage(imageName)
        let tabBar = UITabBarItem(title: nil, image: image.0, selectedImage: image.1)
        
        vc.tabBarItem = tabBar
        
        return UINavigationController(rootViewController: vc)
    }
    
    private func makeStaticticsViewController(_ imageName: String) -> UINavigationController{
        let vc = StatisticsViewController()
        
        let image = makeNomalSelectedImage(imageName)
        let tabBar = UITabBarItem(title: nil, image: image.0, selectedImage: image.1)
        
        vc.tabBarItem = tabBar
        
        return UINavigationController(rootViewController: vc)
    }
    
    
    func makeNomalSelectedImage(_ name: String) -> (UIImage, UIImage) {
        
        let image = UIImage(systemName: name)!.withRenderingMode(.alwaysOriginal)
        
        let nomal = image.withTintColor(.systemGray4)
        let selected = image.withTintColor(.black)
        
        return (nomal, selected)
    }
}
