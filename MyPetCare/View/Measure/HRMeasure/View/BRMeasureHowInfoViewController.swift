//
//  BRMeasureHowInfoView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/20.
//

import Foundation
import UIKit
import RxSwift

class BRMeasureHowInfoViewController: UIViewController {
    
    let padding: CGFloat = 16 * Constants.heightRatio
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    let contentView = UIView().then {
        $0.backgroundColor = .white
        $0.addBorder(.black, 1)
        $0.addCornerRadius(20)
    }
    
    let measureInfoLabel = UILabel().then{
        $0.text = """
            [1회 호흡]\n
            허파에 공기가 들어왔다가 나가면서\n
            흉부가 한번 올라갔다 내려오는 것을 1회로 측정\n

            [휴식 호흡 측정]\n
            반려견이 편한자세로 앉아 있을때 측정\n

            [수면 호흡 측정시]\n
            잠든 지 15분 이후 / 뒤척임이 없을 때 측정\n

            [주의 사항]\n
            스트레스를 받는 상테나 \n
            30분이상 운동/산책 한 뒤에는 정상측정 불가\n
            """
        $0.textAlignment = .center
        $0.font = UIFont.dynamicFont(name: "Cafe24Syongsyong", size: 15)
        $0.numberOfLines = 0
        $0.minimumScaleFactor = 0.5
    }
    
    let dismissButton = UIButton().then {
        let image = UIImage(systemName: "xmark")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.black)
        $0.setImage(image, for: .normal)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        configureLayout()
        
        configureBindButtonAction()
    }

    
    // MARK: - Configure Layout
    private func configureLayout() {
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(padding*6)
            $0.leading.equalToSuperview().offset(padding*2)
            $0.trailing.equalToSuperview().inset(padding*2)
            $0.bottom.equalToSuperview().inset(padding*6)
        }
        
        [dismissButton, measureInfoLabel].forEach {
            contentView.addSubview($0)
        }
        
        dismissButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(padding)
            $0.trailing.equalToSuperview().inset(padding)
            $0.size.equalTo(50)
        }
        
        measureInfoLabel.snp.makeConstraints {
            $0.top.equalTo(dismissButton.snp.bottom).offset(-padding*2)
            $0.leading.equalToSuperview().offset(padding)
            $0.trailing.equalToSuperview().inset(padding)
            $0.bottom.equalToSuperview().offset(-padding)
        }
    }
    
    private func configureBindButtonAction() {
        
        dismissButton.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
    }
}
