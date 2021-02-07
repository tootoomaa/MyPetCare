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
        
        reactor.state.map{$0.selectedPet}
            .observeOn(MainScheduler.instance)
            .do(onNext: {
                let isEmtpy = ($0 == nil)
                self.mainView.petProfileCollectionView.isHidden = isEmtpy
                self.mainView.petEmtpyImage.isHidden = !isEmtpy
                self.mainView.petEmptyLabel.isHidden = !isEmtpy
            })
            .compactMap{$0}
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] pet in
                
                guard pet.name != Pet.empty().name else {
                    
                    return
                }
                
                mainView.configurePetView(pet: pet)
                
            }).disposed(by: disposeBag)
        
        reactor.state.map{$0.petList}
            .compactMap{$0}
            .bind(to: mainView.petProfileCollectionView.rx
                    .items(cellIdentifier: PetProfileImageCell.identifier,
                           cellType: PetProfileImageCell.self)) { row, data , cell in
                
                if data.name == Pet.empty().name {
                    // pet 추가 버튼
                    let plusImage = UIImage(systemName: "plus.circle.fill")?
                                        .withRenderingMode(.alwaysOriginal)
                                        .withTintColor(.lightBlue)
                    cell.petProfileImageView.image = plusImage
                    cell.petProfileImageView.clipsToBounds = true
                    cell.petProfileImageView.backgroundColor = .white
                    
                } else {
                    
                    cell.petProfileImageView.image = UIImage(data: data.profileImage)
                    
                }
                cell.setNeedsLayout()
                
            }.disposed(by: disposeBag)
        
        mainView.petProfileCollectionView.rx.itemSelected
            .map{Reactor.Action.selectPet($0.item)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
}
