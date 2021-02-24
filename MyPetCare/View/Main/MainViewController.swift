//
//  NewMainViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/14.
//

import Foundation
import UIKit
import ReactorKit
import RxUIAlert

class MainViewController: UIViewController, View {
    
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    var selectedPet = PetObject()
    
    let plusImageData = UIImage(systemName: "plus.circle.fill")?
        .withRenderingMode(.alwaysOriginal)
        .withTintColor(.deepGreen)
        .pngData()!
    
    let mainView = MainView(frame: CGRect(x: 0, y: 0,
                                          width: Constants.viewWidth,
                                          height: Constants.viewHeigth))
    
    let servicelayout = ServiceCollecionViewFlowLayout()
    var serviceCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // MARK: - Life cycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        mainView.mainFrameTableView.dataSource = self
        
        configureServiceCollectionView()
        
        configurePanGuesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func configureServiceCollectionView() {
        _ = serviceCollectionView.then {
            $0.delegate = servicelayout
            $0.backgroundColor = .none
            $0.register(ServiceCell.self,
                         forCellWithReuseIdentifier: ServiceCell.identifier)
        }
        
        Observable.just(["호흡수\n측정","체중, 키\n측정"])
            .bind(to: serviceCollectionView.rx.items(cellIdentifier: ServiceCell.identifier,
                                                     cellType: ServiceCell.self)) { row, data, cell in
                
                cell.titleLabel.text = data
                
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Animation Bind
    private func configurePanGuesture() {
        
        let dragGuesture = UIPanGestureRecognizer(target: nil, action: nil)
        mainView.petProfileView.dashBoardView.addGestureRecognizer(dragGuesture)
        dragGuesture.rx.event
            .throttle(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext:{ [unowned self] in
                
                let centerX = mainView.petProfileView.center.x      // PetProfileView의 기준
                
                guard reactor?.currentState.petList?.count ?? 0 > 1 else { return }
                let view = mainView.petProfileView.dashBoardView
                let velocity = $0.velocity(in: view)
                
                if velocity.x < 0 && view.center.x == centerX {         // left
                    UIView.animate(withDuration: 0.5) {
                        view.center.x -= 100
                    }
                } else if velocity.x > 0 && view.center.x < centerX {   // right
                    UIView.animate(withDuration: 0.5) {
                        view.center.x += 100
                    }
                }
                view.layoutIfNeeded()
                
            }).disposed(by: disposeBag)

        mainView.mainFrameTableView.rx.didScroll
            .subscribe(onNext: { [unowned self] in
                mainView.mainFrameTableViewAnimationByScroll()
            }).disposed(by: disposeBag)

    }
    
    // MARK: - Reactor Binding
    func bind(reactor: MainViewControllerReactor) {
        // Main Frame Table View
        Observable.of(MainFrameMenuType.allCases)
            .bind(to: mainView.mainFrameTableView.rx.items) { [unowned self] _, row, menuType in
            
            let lastData = reactor.currentState.selectedLastedPetData
            
            switch menuType {
            case .measureServices:
                return UITableViewCell().then {
                    $0.selectionStyle = .none
                    $0.contentView.addSubview(serviceCollectionView)
                    $0.backgroundColor = Constants.mainColor
                    serviceCollectionView.snp.makeConstraints {
                        $0.top.leading.equalToSuperview()
                        $0.bottom.trailing.equalToSuperview().offset(-8)
                        $0.height.greaterThanOrEqualTo(60*Constants.widthRatio)
                    }
                }
                
            case .breathRate:
                return LastMeasureServiceCell(menuType).then {
                    $0.titleLabel.text = "최근 호흡수"
                    $0.customBackgroundView.backgroundColor = UIColor(rgb: 0xf1d4d4)
                    let resultBR = lastData == nil ? " - /분" : "\(lastData?.resultBR ?? 0)/분"
                    $0.valeuLabel.text = "\(resultBR)" }
                
            case .physics:
                return LastMeasureServiceCell(menuType).then {
                    $0.titleLabel.text = "최근 체중/키"
                    $0.customBackgroundView.backgroundColor = UIColor(rgb: 0xeffad3)
                    let height = lastData == nil ? "- cm" : "\(lastData?.height ?? 0)"
                    let weight = lastData == nil ? "- kg" : "\(lastData?.weight ?? 0)"
                    $0.valeuLabel.text = "\(weight), \(height)" }
            }
        }.disposed(by: disposeBag)
        
        self.rx.viewDidLoad
            .map{Reactor.Action.loadInitialData}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewDidLoad
            .subscribe(onNext: { [unowned self] _ in
                guard reactor.currentState.petList?.count != 1 else { return }
                mainView.petProfileCollectionView
                    .selectItem(at: IndexPath(row: 0, section: 0),
                                animated: false,
                                scrollPosition: .centeredVertically)
            }).disposed(by: disposeBag)
        
        // 펫 선택 시 처리 사항
        reactor.state.map{$0.selectedPet}
            .do(onNext: { self.selectedPet = $0 ?? PetObject() })
            .observeOn(MainScheduler.instance)
            .do(onNext: { // pet 리스트가 없는 경우 Empty View 표시
                self.mainView.petProfileView.configureEmptyViewComponentsByPetList($0 == nil)
            }) // 상태에 따른 UI 변화
            .compactMap{$0}
            .filter{$0.id != Constants.mainViewPetPlusButtonUUID} // Plus Button 처리
            .subscribe(onNext: { [unowned self] pet in

                mainView.configureSelectedPetData(pet: pet)
                mainView.petProfileView.configurePetView(pet: pet)
                mainView.mainFrameTableView.reloadData()

            }).disposed(by: disposeBag)
        
        // Pet Profile 선택시 변경 사항
        reactor.state.map{$0.selectedIndexPath}
            .filter{$0.row != reactor.plusButtonIndex}
            .observeOn(MainScheduler.asyncInstance)
            .compactMap{$0}
            .subscribe(onNext: { [unowned self] indexPath in
                
                let view = mainView.petProfileCollectionView
                view.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
                
                if let cell = view.cellForItem(at: indexPath) as? PetProfileImageCell {
                    cell.isSelected = true
                }

            }).disposed(by: disposeBag)
        
        // 펫 CollectionView 리스트 생성
        reactor.state.map{$0.petList}
            .distinctUntilChanged()
            .compactMap{$0}
            .bind(to: mainView.petProfileCollectionView.rx
                    .items(cellIdentifier: PetProfileImageCell.identifier,
                           cellType: PetProfileImageCell.self)) { row, petData , cell in
                
                let image = UIImage(data: (petData.image ?? self.plusImageData)!)
                
                cell.petProfileImageView.image = image
                cell.cellIndex = row
                
            }.disposed(by: disposeBag)
        
//        reactor.state.map{$0.selectedLastedPetData}
//            .compactMap{$0}
//            .observeOn(MainScheduler.asyncInstance)
//            .subscribe(onNext: {
//
////                self.mainView.mainFrameTableView.reloadData()
//            }).disposed(by: disposeBag)
        
        // plusButton 처리
        mainView.petProfileCollectionView.rx.itemSelected
            .filter{$0.row == reactor.plusButtonIndex}
            .subscribe(onNext: { [unowned self] index in
                
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
                    reactor.action.onNext(.setPetProfileIndex)
                    mainView.setOriginalOffsetPetProfileView()
                })
                
            }).disposed(by: disposeBag)
        
        //펫 CollectionView 선택 처리
        mainView.petProfileCollectionView.rx.itemSelected
            .filter{$0.row != reactor.plusButtonIndex}
            .map{Reactor.Action.selectedIndexPath($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 펫 수정 버튼
        mainView.petProfileView.editButton.rx.tap
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext:{ [unowned self] in
                
                let vc = NewPetAddViewController()
                vc.reactor = PetAddViewReactor(isEditMode: true,
                                               petData: self.selectedPet,
                                               provider: reactor.provider)
                
                let naviC = UINavigationController(rootViewController: vc)
                naviC.modalPresentationStyle = .overFullScreen
                
                vc.rx.tapPetAddButton
                    .observeOn(MainScheduler.instance)
                    .map{Reactor.Action.loadInitialData}
                    .bind(to: reactor.action)
                    .disposed(by: self.disposeBag)
                
                self.present(naviC, animated: true, completion: {
                    mainView.setOriginalOffsetPetProfileView()
                })
                
            }).disposed(by: disposeBag)
        
        // 삭제 버튼 처리
        mainView.petProfileView.deleteButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                
                let cancel = AlertAction(title: "취소", type: 0, style: .cancel)
                let delete = AlertAction(title: "삭제", type: 1, style: .destructive)
                
                rx.alert(title: "삭제",
                         message: "삭제하시겠습니까?",
                         actions: [cancel, delete],
                         preferredStyle: .alert,
                         vc: .none)
                    .subscribe(onNext: { action in
                        
                        if action.index == 1 {
                            reactor.action.onNext(.deletePet)
                            reactor.action.onNext(.loadInitialData)
                            mainView.setOriginalOffsetPetProfileView()
                        }
                        
                    }).disposed(by: disposeBag)
                
            }).disposed(by: disposeBag)
        
        // 서비스 선택시 처리
        serviceCollectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                
                guard let selectedPet = reactor.currentState.selectedPet else { return }
                if indexPath.row == 0 {
                    
                    let hrmeasureVC = BRMeasureViewController()
                    hrmeasureVC.reactor = BRMeasureViewReactor(selectedPat: self.selectedPet,
                                                               provider: reactor.provider)
                    // Save Button 선택시 tableView Label 재구성
                    hrmeasureVC.mainView.resultView.saveButton.rx.tap
                        .subscribe(onNext: {
                            let cellBRcount = IndexPath(row: 0, section: 0)
                            let heightWidthBRcount = IndexPath(row: 1, section: 0)
                            self.mainView.mainFrameTableView.reloadRows(
                                at: [cellBRcount, heightWidthBRcount],
                                with: .automatic)
                        }).disposed(by: disposeBag)
                    
                    let naviC = UINavigationController(rootViewController: hrmeasureVC)
                    
                    naviC.modalPresentationStyle = .overFullScreen
                    self.present(naviC, animated: true, completion: nil)
                    
                } else if indexPath.row == 1 {
                    
                    let physicsMeasureVC = PhysicsMeasureViewController()
                    physicsMeasureVC.reactor = BRMeasureViewReactor(
                                                    selectedPat: self.selectedPet,
                                                    provider: reactor.provider)
                    // Save Button 선택시 tableView Label 재구성
//                    physicsMeasureVC.mainView.resultView.saveButton.rx.tap
//                        .subscribe(onNext: {
//                            let cellBRcount = IndexPath(row: 0, section: 0)
//                            let heightWidthBRcount = IndexPath(row: 1, section: 0)
//                            self.mainView.mainFrameTableView.reloadRows(
//                                at: [cellBRcount, heightWidthBRcount],
//                                with: .automatic)
//                        }).disposed(by: disposeBag)
                    
                    let naviC = UINavigationController(rootViewController: physicsMeasureVC)
                    
                    naviC.modalPresentationStyle = .overFullScreen
                    self.present(naviC, animated: true, completion: nil)
                }
                
            }).disposed(by: disposeBag)
    }
}
