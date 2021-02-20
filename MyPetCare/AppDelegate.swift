//
//  AppDelegate.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/03.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let provider = ServiceProvider()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        configureTestData()
        
        configureNavigation()
        
        let tabBarC = MyPetCustomNavigationController(provider: provider)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarC
        window?.makeKeyAndVisible()
        
        print(UIScreen.main.bounds.width)
        
        return true
    }
    
    private func configureTestData() {
        
        
        // delete all Pet List
//        let list = provider.dataBaseService.loadPetList().toArray()
//        provider.dataBaseService.delete(list)
        
    }
    
    private func configureNavigation() {
        let appearance = UINavigationBarAppearance(idiom: .phone)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.shadowColor = .clear
        appearance.backgroundColor = Constants.mainColor
        
        let navigationBarApear = UINavigationBar.appearance()
        navigationBarApear.compactAppearance = appearance
        navigationBarApear.standardAppearance = appearance
        navigationBarApear.scrollEdgeAppearance = appearance
    }
}

