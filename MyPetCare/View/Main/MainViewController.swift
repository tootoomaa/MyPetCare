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
import RxGesture

enum MainServiceType: String, CaseIterable {
    case pelseCheck = "심박수 측정"
    case hospital = "병원 찾기"
}

class MainViewController: UIViewController, ReactorKit.View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var tableViewDispose: Disposable?
    
    let mainView = MainView()
    
    var selectedPet: PetObject?
    
    var serviceMuneList: [MainServiceType] = [.pelseCheck, .hospital, .pelseCheck, .hospital, .pelseCheck, .hospital]
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureServiceCollecionViewBind()
        
        configurePanGuesture()
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
    
    private func configurePanGuesture() {
        
        let centerX = Constants.viewWeigth/2
        
        let dragGuesture = UIPanGestureRecognizer(target: nil, action: nil)
        mainView.petProfileView.addGestureRecognizer(dragGuesture)
        dragGuesture.rx.event
            .throttle(.milliseconds(600), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext:{ [unowned self] in
                
                let view = mainView.petProfileView
                
                let velocity = $0.velocity(in: view)
                
                if abs(velocity.x) > abs(velocity.y) {
                    if velocity.x < 0 && view.center.x == centerX {         // left
                        UIView.animate(withDuration: 0.5) {
                            view.center.x -= 100
                        }
                    } else if velocity.x > 0 && view.center.x < centerX {   // right
                        UIView.animate(withDuration: 0.5) {
                            view.center.x += 100
                        }
                    }
                }
                
                view.layoutIfNeeded()

            }).disposed(by: disposeBag)   
    }
    
    // MARK: - Reactor Bind
    func bind(reactor: MainViewControllerReactor) {
        
        self.rx.viewDidLoad
            .map{Reactor.Action.loadInitialData}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewDidLoad
            .subscribe(onNext: { [unowned self] _ in
                guard reactor.currentState.selectedPet?.uuid
                        != Constants.mainViewPetPlusButtonUUID else { return }
                mainView.petProfileCollectionView
                    .selectItem(at: IndexPath(row: 0, section: 0),
                                animated: false,
                                scrollPosition: .centeredVertically)
            }).disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedPet}
            .observeOn(MainScheduler.instance)
            .do(onNext: { // pet 리스트가 없는 경우 Empty View 표시
                self.mainView.configureEmptyViewComponentsByPetList($0 == nil)
            }) // 상태에 따른 UI 변화
            .compactMap{$0}
            .distinctUntilChanged()
            .filter{$0.uuid != Constants.mainViewPetPlusButtonUUID} // Plus Button 처리
            .subscribe(onNext: { [unowned self] pet in
                
                mainView.configurePetView(pet: pet)
                mainView.petProfileView.layoutIfNeeded()
                
            }).disposed(by: disposeBag)
        
        // 펫 CollectionView 리스트 생성
        reactor.state.map{$0.petList}
//            .distinctUntilChanged()
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
                    cell.selectMarkImage.removeFromSuperview()
                } else {
                    cell.petProfileImageView.image = UIImage(data: petData.image ?? Data())
                    cell.cellIndex = row
                }
                
            }.disposed(by: disposeBag)
        
        // Pet 선택 시 처리 사항
        mainView.petProfileCollectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                
                guard let selectedPet = reactor.currentState.petList?[indexPath.row],
                      selectedPet.uuid != Constants.mainViewPetPlusButtonUUID else {
                    // 신규 펫 추가
                    let vc = NewPetAddViewController()
                    vc.reactor = PetAddViewReactor(isEditMode: false,
                                                   petData: PetObject(),
                                                   provider: reactor.provider)
                    
                    let naviC = UINavigationController(rootViewController: vc)
                    naviC.modalPresentationStyle = .overFullScreen
                    
                    vc.rx.tapPetAddButton
                        .observeOn(MainScheduler.asyncInstance)
                        .map{Reactor.Action.loadInitialData}
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                    
                    self.present(naviC, animated: true, completion: {
                        // Pet 추가 버튼 선택 후 화면에 재 진입했을 때 이전에 선택한 펫이 보이도록
                        let index = reactor.currentState.selectedIndexPath
                        guard let pet = reactor.currentState.petList?[index.row],
                              pet.name != Constants.mainViewPetPlusButtonUUID else { return }
                        reactor.action.onNext(.selectPet(index.row))
                        reactor.action.onNext(.selectedIndex(index))
                    })
                    return
                }
                
                reactor.action.onNext(.selectPet(indexPath.row))
                reactor.action.onNext(.selectedIndex(indexPath))    // 선택한 indexPath 저장 (Check Mark 표시용)
                
            }).disposed(by: disposeBag)
        
        mainView.editButton.rx.tap
            .subscribe(onNext:{ [unowned self] in
                
                guard let selectedPet = reactor.currentState.selectedPet else { return }
                
                let vc = NewPetAddViewController()
                vc.reactor = PetAddViewReactor(isEditMode: true,
                                               petData: selectedPet,
                                               provider: reactor.provider)
                
                let naviC = UINavigationController(rootViewController: vc)
                naviC.modalPresentationStyle = .overFullScreen
                
                vc.rx.tapPetAddButton
                    .map{Reactor.Action.loadInitialData}
                    .bind(to: reactor.action)
                    .disposed(by: self.disposeBag)
                
                self.present(naviC, animated: true, completion: {
                    // 화면 원상 복귀
                    UIView.animate(withDuration: 0.5) {
                        self.mainView.petProfileView.center.x += 100
                    }
                    self.mainView.petProfileView.layoutIfNeeded()
                })
                
            }).disposed(by: disposeBag)
        
    }
}
