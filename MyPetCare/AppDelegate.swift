//
//  AppDelegate.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/03.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        configureNavigation()
        
        let provider = ServiceProvider()
        let tabBarC = MyPetCustomNavigationController(provider: provider)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarC
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func configureNavigation() {
        let appearance = UINavigationBarAppearance(idiom: .phone)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white
        
        let navigationBarApear = UINavigationBar.appearance()
        navigationBarApear.compactAppearance = appearance
        navigationBarApear.standardAppearance = appearance
        navigationBarApear.scrollEdgeAppearance = appearance
    }
}

