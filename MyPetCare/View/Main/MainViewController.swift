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
//        .pngData()!
    
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
            $0.showsHorizontalScrollIndicator = false
            $0.register(MeasureServiceCell.self,
                         forCellWithReuseIdentifier: MeasureServiceCell.identifier)
        }
        
        Observable.just(MeasureServiceType.allCases)
            .bind(to: serviceCollectionView.rx.items(
                    cellIdentifier: MeasureServiceCell.identifier,
                    cellType: MeasureServiceCell.self)) { row, measureServiceType, cell in
                
                cell.titleLabel.text = measureServiceType.getTitle()
                cell.cellType = measureServiceType
                
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
                
                guard reactor?.currentState.petList.count ?? 0 > 1 else { return }
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
        
        self.rx.viewDidLoad
            .map{Reactor.Action.loadInitialData}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewDidLoad
            .subscribe(onNext: { [unowned self] _ in
                guard reactor.currentState.petList.count != 1 else { return }
                mainView.petProfileCollectionView
                    .selectItem(at: IndexPath(row: 0, section: 0),
                                animated: false,
                                scrollPosition: .centeredVertically)
            }).disposed(by: disposeBag)
        
        // 펫 선택 시 처리 사항
        reactor.state.map{$0.selectedPet}
            .do(onNext: { self.selectedPet = $0 ?? PetObject() })
            .observe(on: MainScheduler.instance)
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
            .observe(on: MainScheduler.asyncInstance)
            .compactMap{$0}
            .subscribe(onNext: { [unowned self] indexPath in
                
                //select를 통해 pet사진 테투리 체크표시 나타냄
                let view = mainView.petProfileCollectionView
                view.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
                
                if let cell = view.cellForItem(at: indexPath) as? PetProfileImageCell {
                    cell.isSelected = true
                }

            }).disposed(by: disposeBag)
        
        // 펫 CollectionView 리스트 생성
        reactor.state.map{$0.petList}
            .distinctUntilChanged()
            .do(onNext: {
                if $0.isEmpty {
                    self.mainView.configureSelectedPetData(pet: PetObject())
                }
            })
            .compactMap{$0}
            .bind(to: mainView.petProfileCollectionView.rx
                    .items(cellIdentifier: PetProfileImageCell.identifier,
                           cellType: PetProfileImageCell.self)) { row, petData , cell in
                
                if let data = petData.image {
                    cell.petProfileImageView.image = UIImage(data: data)
                } else {
                    cell.petProfileImageView.image = self.plusImageData
                }
                
                cell.cellIndex = row
                
            }.disposed(by: disposeBag)
        
//        reactor.state.map{$0.selectedLastedPetData}
//            .compactMap{$0}
//            .observeOn(MainScheduler.asyncInstance)
//            .subscribe(onNext: {
//
////                self.mainView.mainFrameTableView.reloadData()
//            }).disposed(by: disposeBag)
        
        // MARK: - Main Frame TableView Cell
        Observable.of(MainFrameMenuType.allCases)
            .bind(to: mainView.mainFrameTableView.rx.items) { [unowned self] _, row, menuType in
            
            let lastData = reactor.currentState.selectedLastedPetData
            
            switch menuType {
            case .measureSV:
                return UITableViewCell().then {
                    $0.selectionStyle = .none
                    $0.contentView.addSubview(serviceCollectionView)
                    $0.backgroundColor = Constants.mainColor
                    serviceCollectionView.snp.makeConstraints {
                        $0.top.leading.equalToSuperview()
                        $0.bottom.trailing.equalToSuperview().offset(-8)
                        $0.height.greaterThanOrEqualTo(60)
                    }
                }
                
            case .breathRateSV:
                return LastMeasureServiceCell(menuType).then {
                    $0.titleLabel.text = "최근\(menuType.rawValue)"
                    $0.customBackgroundView.backgroundColor = UIColor(rgb: 0xf1d4d4)
                    let resultBR = lastData == nil ? " - 회/분" : "\(lastData?.resultBR ?? 0)회/분"
                    $0.valeuLabel.text = "\(resultBR)"
                    $0.petStateLabel.isHidden = !(lastData?.measureType == MeasureServiceType.sleepBreathRate.getTitle())
                    $0.showMoreButton.rx.tap
                        .subscribe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: {
                            
                            guard let selectedPet = reactor.currentState.selectedPet else {
                                serviceNotAvailableAlert(title: "서비스 불가",
                                                         message: "펫이 등록되지 않아 상세 정보 보기가 불가능합니다.")
                                return
                            }
                            let measureDetailVC = MeasureDetailViewController(type: menuType)
                            measureDetailVC.reactor = MeasureViewReactor(selectedPat: selectedPet,
                                                                         provider: reactor.provider)
                            self.navigationController?.pushViewController(measureDetailVC, animated: true)
                            
                        }).disposed(by: disposeBag)
                }
                
            case .physicsSV:
                return LastMeasureServiceCell(menuType).then {
                    $0.titleLabel.text = "최근 \(menuType.rawValue)"
                    $0.customBackgroundView.backgroundColor = UIColor(rgb: 0xeffad3)
                    $0.valeuLabel.text = lastData == nil ? "- kg" : "\(lastData?.weight ?? 0)kg"
                    $0.showMoreButton.rx.tap
                        .subscribe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: {
                            
                            guard let selectedPet = reactor.currentState.selectedPet else {
                                serviceNotAvailableAlert(title: "서비스 불가",
                                                         message: "펫이 등록되지 않아 상세 정보 보기가 불가능합니다.")
                                return
                            }
                            let measureDetailVC = MeasureDetailViewController(type: menuType)
                            measureDetailVC.reactor = MeasureViewReactor(selectedPat: selectedPet,
                                                                         provider: reactor.provider)
                            self.navigationController?.pushViewController(measureDetailVC, animated: true)
                            
                        }).disposed(by: disposeBag)
                }
            }
        }.disposed(by: disposeBag)
        
        // MARK: - PetProfile CollectionView Cell & Pet Profile View
        // plusButton 처리
        mainView.petProfileCollectionView.rx.itemSelected
            .filter{$0.row == reactor.plusButtonIndex}
            .subscribe(onNext: { [unowned self] index in
                
                // 신규 펫 추가
                let vc = NewPetAddViewController(isEditMode: false)
                vc.reactor = PetAddViewReactor(isEditMode: false,
                                               petData: PetObject(),
                                               provider: reactor.provider)
                
                let naviC = UINavigationController(rootViewController: vc)
                naviC.modalPresentationStyle = .overFullScreen
                
                vc.rx.tapPetAddButton
                    .observe(on: MainScheduler.asyncInstance)
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
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext:{ [unowned self] in
                
                let vc = NewPetAddViewController(isEditMode: true)
                vc.reactor = PetAddViewReactor(isEditMode: true,
                                               petData: self.selectedPet,
                                               provider: reactor.provider)
                
                let naviC = UINavigationController(rootViewController: vc)
                naviC.modalPresentationStyle = .overFullScreen
                
                vc.rx.tapPetAddButton
                    .observe(on: MainScheduler.instance)
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
                        
                        if action.index == 1 { // 삭제 선택
                            reactor.action.onNext(.deletePet)
                            reactor.action.onNext(.loadInitialData)
                            mainView.setOriginalOffsetPetProfileView()
                        }
                        
                    }).disposed(by: disposeBag)
                
            }).disposed(by: disposeBag)
        
        // MARK: - MeasureSevice CollecionView
        
        // 측정 서비스 선택 시 처리 사항
        serviceCollectionView.rx.itemSelected
            .compactMap{self.serviceCollectionView.cellForItem(at: $0) as? MeasureServiceCell}
            .compactMap{$0.cellType}
            .subscribe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { owner, serviceType in
                
                guard reactor.currentState.petList.count > 1 else { // +버튼 때문에 1개 이상 일때
                    owner.serviceNotAvailableAlert(title: "서비스 불가",
                                                   message: "펫이 등록되어 있지 않습니다. 펫을 먼저 등록해주세요")
                    return
                }
                
                switch serviceType {
                
                case .breathRate:
                    let hrmeasureVC = BRMeasureViewController()
                    hrmeasureVC.reactor = MeasureViewReactor(selectedPat: self.selectedPet,
                                                               provider: reactor.provider)
                    // Save Button 선택시 tableView Label 재구성
                    hrmeasureVC.mainView.resultView.saveButton.rx.tap
                        .subscribe(onNext: {
                            let cellBRcount = IndexPath(row: 0, section: 0)
                            let heightWidthBRcount = IndexPath(row: 1, section: 0)
                            self.mainView.mainFrameTableView.reloadRows(
                                at: [cellBRcount, heightWidthBRcount],
                                with: .automatic)
                        }).disposed(by: owner.disposeBag)
                    
                    let naviC = UINavigationController(rootViewController: hrmeasureVC)
                    
                    naviC.modalPresentationStyle = .overFullScreen
                    self.present(naviC, animated: true, completion: nil)
                    
                case .sleepBreathRate, .weight:
                    let physicsMeasureVC = PhysicsMeasureViewController(type: serviceType)
                    physicsMeasureVC.reactor = MeasureViewReactor(
                                                    selectedPat: self.selectedPet,
                                                    provider: reactor.provider)
                    
                    let naviC = UINavigationController(rootViewController: physicsMeasureVC)
                    
                    naviC.modalPresentationStyle = .overFullScreen
                    self.present(naviC, animated: true, completion: nil)
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func serviceNotAvailableAlert(title: String, message: String) {
        let alertC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default) { _ in }
        alertC.addAction(okButton)
        self.present(alertC, animated: true, completion: nil)
    }
}
