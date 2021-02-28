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
    
    lazy var barChartView = StatisticChartView(
        frame: chartViewFrame,
        segmentHeight: segmentHeight
    )
    
    lazy var mainFrameTable = UITableView().then {
        $0.estimatedRowHeight = 300
        $0.tableHeaderView = barChartView
    }
    
    let filterOptionTableView = UITableView().then {
        $0.alpha = 0
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        $0.estimatedRowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
        $0.register(UITableViewCell.self,
                    forCellReuseIdentifier: "Cell")
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
        
        [mainFrameTable, filterOptionTableView].forEach {
            addSubview($0)
        }
        
        mainFrameTable.snp.makeConstraints {
            $0.top.leading.equalTo(safeAreaLayoutGuide).offset(padding)
            $0.trailing.bottom.equalTo(safeAreaLayoutGuide).offset(-padding)
        }
        
        filterOptionTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
}
