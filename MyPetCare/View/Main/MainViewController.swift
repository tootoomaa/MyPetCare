//
//  MainViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/03.
//

import Foundation
import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import Then
import SnapKit
import RealmSwift
import RxRealm

enum MainServiceType: String, CaseIterable {
    case pelseCheck = "심박수 측정"
    case hospital = "병원 찾기"
}

class MainViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var tableViewDispose: Disposable?
    
    let mainView = MainView()
    
    var serviceMuneList: [MainServiceType] = [.pelseCheck, .hospital, .pelseCheck, .hospital, .pelseCheck, .hospital]
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureServiceCollecionViewBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func configureServiceCollecionViewBind() {

        Observable.just(serviceMuneList)
            .bind(to: mainView.serviceColectionView.rx.items(cellIdentifier: ServiceCell.identifier,
                                                             cellType: ServiceCell.self))
            { [unowned self] row, item, cell in
                
                let serviceType = serviceMuneList[row]
                var image = UIImage()
                
                switch serviceType {
                case .hospital:
                    image = UIImage(systemName: "cross.case.fill") ?? UIImage()
                case .pelseCheck:
                    image = UIImage(systemName: "heart.circle") ?? UIImage()
                }
                
                cell.imageView.image = image
                cell.titleLabel.text = serviceType.rawValue
                
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Reactor Bind
    func bind(reactor: MainViewControllerReactor) {
        
        self.rx.viewDidLoad
            .map{Reactor.Action.loadInitialData}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedPet}
            .observeOn(MainScheduler.instance)
            .do(onNext: { // pet 리스트가 없는 경우 Empty View 표시
                self.mainView.configureEmptyViewComponentsByPetList($0 == nil)
            }) // 상태에 따른 UI 변화
            .compactMap{$0}
            .filter{$0.uuid != Constants.mainViewPetPlusButtonUUID} // Plus Button 처리
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] pet in
                mainView.configurePetView(pet: pet)
            }).disposed(by: disposeBag)
        
        // 펫 CollectionView 리스트 생성
        reactor.state.map{$0.petList}
            .distinctUntilChanged()
            .compactMap{$0}
            .bind(to: mainView.petProfileCollectionView.rx
                    .items(cellIdentifier: PetProfileImageCell.identifier,
                           cellType: PetProfileImageCell.self)) { row, petData , cell in
                
                if petData.uuid == Constants.mainViewPetPlusButtonUUID {
                    // pet 추가 버튼
                    let plusImage = UIImage(systemName: "plus.circle.fill")?
                                        .withRenderingMode(.alwaysOriginal)
                                        .withTintColor(.deepGreen)
                    cell.petProfileImageView.image = plusImage
                    cell.petProfileImageView.clipsToBounds = true
                    
                } else {
                    cell.petProfileImageView.image = UIImage(data: petData.image ?? Data())
                }
                
                cell.isSelected = reactor.currentState.selectedIndexPath?.row == row
                
            }.disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedIndexPath}
            .compactMap{$0}
            .compactMap{self.mainView.petProfileCollectionView.cellForItem(at: $0) as? PetProfileImageCell}
            .subscribe(onNext: {
                $0.isSelected = true
            }).disposed(by: disposeBag)
        
        // Pet 선택 시 처리 사항
        mainView.petProfileCollectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
              
                let selectedPet = reactor.currentState.petList?[indexPath.row]
                
                guard selectedPet?.uuid != Constants.mainViewPetPlusButtonUUID else {
//                    let vc = PetAddViewController(false)
                    let vc = NewPetAddViewController()
                    vc.reactor = PetAddViewReactor(provider: reactor.provider)
                    
                    let naviC = UINavigationController(rootViewController: vc)
                    naviC.modalPresentationStyle = .overFullScreen
                    
                    vc.rx.tapPetAddButton
                        .map{Reactor.Action.loadInitialData}
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                    
                    self.present(naviC, animated: true, completion: nil)
                    return
                }
                
                reactor.action.onNext(.selectPet(indexPath.row))    // 선택한 Pet 저장
                reactor.action.onNext(.selectedIndex(indexPath))                    // 선택한 indexPath 저장 (Check Mark 표시용)
                
            }).disposed(by: disposeBag)
        
        mainView.editButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                
                mainView.petProfileCollectionView.isEditing = true
                
                
            }).disposed(by: disposeBag)
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        mainView.petProfileCollectionView.isEditing = editing
    }
}

extension MainViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
    print(#function)
    mainView.petProfileCollectionView.isEditing = true
  }
}
