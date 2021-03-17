//
//  SideMenuViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/03/12.
//

import Foundation
import UIKit
import ReactorKit
import RxSwift
import CloudKit

class SideMenuViewController: UIViewController, View {
    
    // MARK: - Properteis
    var disposeBag: DisposeBag = DisposeBag()
    var sideMenus: [SideMenus] = []
    
    let mainView = SideMenuView()
    
    // MARK: - Init
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    private func configureTableView() {
        
        mainView.sideMenuTableView.register(SideMenuTableViewCell.self,
                                            forCellReuseIdentifier: SideMenuTableViewCell.identifier)
        
    }
    
    func bind(reactor: SideMenuViewReactor) {
        
        self.sideMenus = reactor.currentState.sideMenuList
        
        // 사이드 메뉴 생성
        reactor.state.map{$0.sideMenuList}
            .bind(to: mainView.sideMenuTableView.rx.items(cellIdentifier: SideMenuTableViewCell.identifier,
                                                          cellType: SideMenuTableViewCell.self)) { row, menu, cell in
                
                cell.configureCell(menu)
                
            }.disposed(by: disposeBag)
        
        // 사이드 메뉴 선택 처리
        mainView.sideMenuTableView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { owner, indexPath in
                
                let menu = self.sideMenus[indexPath.row]
                
                switch menu {
                
                case .backup:
                    owner.uploadDatabaseToCloudDrive()
                    break
                case .license:
                    break
                case .mailContact:
                    break
                case .restore:
                    break
                }
                
            }).disposed(by: disposeBag)
        
    }
    
}

extension SideMenuViewController {
    
    struct DocumentsDirectory {
        static let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last
        static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents", isDirectory: true)
    }
    
    private func isCloudEnabled() -> Bool {
        if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
        else { return false }
    }
    
    private func checkForExistingDir() -> Bool {
        if DocumentsDirectory.localDocumentsURL != nil { return true}
        else { return false}
    }
    
    func uploadDatabaseToCloudDrive() {
        
        guard let iCloutDocumentURL = DocumentsDirectory.iCloudDocumentsURL,
              let localDocumentsURL = DocumentsDirectory.localDocumentsURL else {
            print("iCloudSetupNotAvailable")
            return
        }
        
        let myContainter = CKContainer.default()
        let publicDatabase = myContainter.publicCloudDatabase
        
        let fileManager = FileManager.default
        
        let datePadding = TimeUtil().getString(Date(), .foriCloudSave)
        let iCloudDocumentToCheckURL = iCloutDocumentURL.appendingPathComponent("\(datePadding)_MyPetCareData.realm", isDirectory: false)
        let realmArchiveURL = iCloudDocumentToCheckURL//containerURL?.appendingPathComponent("MyArchivedRealm.realm")
        
        if(fileManager.fileExists(atPath: realmArchiveURL.path )) {
            do {
                try fileManager.removeItem(at: realmArchiveURL)
                print("REPLACE")
                try self.reactor?.provider.dataBaseService.realm.writeCopy(toFile: realmArchiveURL)
            } catch {
                print("ERR")
            }
        }
        else {
            print("Need to store ")
            try! self.reactor?.provider.dataBaseService.realm.writeCopy(toFile: realmArchiveURL)
        }
    }
    
    private func backup() {
        
        
        
    }
    
}
