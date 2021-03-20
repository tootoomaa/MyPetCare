//
//  StatisticView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/21.
//

import Foundation
import UIKit

class StatisticView: UIView {
    
    var padding: CGFloat = 8
    var segmentHeight: CGFloat = 30
    
    // MARK: - Properties
    
    lazy var chartViewFrame = CGRect(
        x: 0, y: 0,
        width: Constants.viewWidth-padding*2,
        height: (Constants.viewWidth-padding*2)/3*2+segmentHeight
    )
    
    lazy var statisticChartView = StatisticChartView(
        frame: chartViewFrame,
        segmentHeight: segmentHeight
    )
    
    lazy var mainFrameTable = UITableView().then {
        $0.tableHeaderView = statisticChartView
        $0.separatorStyle = .none
        $0.backgroundColor = .white
    }
    
    let filterOptionTableView = UITableView().then {
        $0.estimatedRowHeight = 50
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
        $0.register(UITableViewCell.self,
                    forCellReuseIdentifier: "Cell")
        $0.isHidden = true
    }
    
    let petListEmptyView = UILabel().then {
        $0.text = "펫이 등록되어 있지 않습니다."
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 20)
        $0.backgroundColor = .systemGray2
        $0.addCornerRadius(20)
        $0.isHidden = true
    }
    
    let dismiaView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        $0.alpha = 0.5
        $0.isHidden = true
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    private func configureLayout() {
        
        [mainFrameTable, filterOptionTableView, dismiaView].forEach {
            addSubview($0)
        }
        
        mainFrameTable.snp.makeConstraints {
            $0.top.leading.equalTo(safeAreaLayoutGuide).offset(padding)
            $0.trailing.bottom.equalTo(safeAreaLayoutGuide).offset(-padding)
        }
        
        filterOptionTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(140)
        }
        
        dismiaView.snp.makeConstraints {
            $0.top.equalTo(filterOptionTableView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        filterOptionTableView.addSubview(petListEmptyView)
        petListEmptyView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(padding)
            $0.height.equalTo(140-padding*2)                // top, bottom Padding
            $0.width.equalTo(Constants.viewWidth-padding*2) // leading, trailing
        }
    }
    
    func filterOptionShowAnimation() {
        UIView.animate(withDuration: 0.4) {
            self.filterOptionTableView.isHidden.toggle()
            self.dismiaView.isHidden.toggle()
        }
    }
}
