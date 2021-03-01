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
        
        return true
    }
    
    private func configureTestData() {
        
        
        // delete all Pet List
//        let list = provider.dataBaseService.loadPetList().toArray()
//        provider.dataBaseService.delete(list)
//        let day = 60*60*24
//        let value1 = BRObject().then {
//            $0.id = UUID().uuidString
//            $0.petId = "08CAD4B0-25B2-4387-8E61-DC7D9B3E7F31"
//            $0.createDate = Date().addingTimeInterval(TimeInterval(-day))
//            $0.originalBR = 1
//            $0.resultBR = 6
//            $0.userSettingTime = 10
//        }
//        
//        let value2 = BRObject().then {
//            $0.id = UUID().uuidString
//            $0.petId = "08CAD4B0-25B2-4387-8E61-DC7D9B3E7F31"
//            $0.createDate = Date().addingTimeInterval(TimeInterval(-day*2))
//            $0.originalBR = 3
//            $0.resultBR = 18
//            $0.userSettingTime = 10
//        }
//        
//        let value3 = BRObject().then {
//            $0.id = UUID().uuidString
//            $0.petId = "08CAD4B0-25B2-4387-8E61-DC7D9B3E7F31"
//            $0.createDate = Date().addingTimeInterval(TimeInterval(-day*3))
//            $0.originalBR = 20
//            $0.resultBR = 20
//            $0.userSettingTime = 60
//        }
//        
//        let value4 = BRObject().then {
//            $0.id = UUID().uuidString
//            $0.petId = "08CAD4B0-25B2-4387-8E61-DC7D9B3E7F31"
//            $0.createDate = Date().addingTimeInterval(TimeInterval(-day*4))
//            $0.originalBR = 2
//            $0.resultBR = 4
//            $0.userSettingTime = 30
//        }
//        
//        provider.dataBaseService.set([value1, value2, value3, value4])
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

