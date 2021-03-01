//
//  StatisticGraphView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/21.
//

import Foundation
import UIKit
import Charts

class StatisticChartView: UIView {
    
    let brColor: UIColor = .cViolet
    let wtColor: UIColor = .deepGreen
    
    // MARK: - Properties
    let durationString = ["주간","월간"]
    
    lazy var durationSegmentController = UISegmentedControl(items: durationString).then {
        $0.selectedSegmentIndex = 0
    }
    
    let combinedChartView = CombinedChartView()
    
    // MARK: - Life Cycle
    init(frame: CGRect, segmentHeight: CGFloat) {
        super.init(frame: frame)
        
        configureLayout(frame, segmentHeight)
        
        configureBarchart()
        
//        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
//
//        setChart(dataPoints: months, values: unitsSold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Layout
    private func configureLayout(_ frame: CGRect, _ segmentHeight: CGFloat) {
        
        [durationSegmentController, combinedChartView].forEach {
            addSubview($0)
        }
        
        durationSegmentController.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(segmentHeight)
        }
        
        combinedChartView.snp.makeConstraints {
            $0.top.equalTo(durationSegmentController.snp.bottom).offset(5)
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Configure Bar Chart
    private func configureBarchart() {
        _ = combinedChartView.then {
            $0.noDataText = "데이터가 없습니다."
            $0.noDataFont = .dynamicFont(name: "Cafe24Syongsyong", size: 20)
            $0.noDataTextColor = .black
            $0.doubleTapToZoomEnabled = false       // 줌 허용
            
            // 왼쪽 Y축
            _ = $0.leftAxis.then {
                $0.labelFont = .systemFont(ofSize: 10)
                $0.labelTextColor = brColor
                $0.labelCount = 5
                
                let format = NumberFormatter()
                format.minimumFractionDigits = 0
                format.positiveSuffix = " 회"
                $0.valueFormatter = DefaultAxisValueFormatter(formatter: format)
                
                $0.labelPosition = .outsideChart   //.insideChart
                $0.spaceTop = 0.15
                $0.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
                $0.axisMaximum = 50
            }
            // 오른쪽 X축
            _ = $0.rightAxis.then {
                $0.labelFont = .systemFont(ofSize: 10)
                $0.labelTextColor = wtColor
                $0.labelCount = 5
                $0.granularity = 1
                
                let format = NumberFormatter()
                format.minimumFractionDigits = 0
                format.positiveSuffix = " kg"
                $0.valueFormatter = DefaultAxisValueFormatter(formatter: format)
                
                $0.labelPosition = .outsideChart   //.insideChart
                $0.spaceTop = 0.15
                $0.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
                $0.axisMaximum = 30
            }
        }
    }
    
    func setChart(filterOption: FilterOptions) {
        
        // 요일 데이터 생성
        let dayValue: [String] = TimeUtil().getSevenDayStringByCurrentDay(type: filterOption.duration)
        print(dayValue)
        
        let values = [10.0, 23.0, 18.0, 32.0, 38.0, 22.0, 17.0]
                
        // 데이터 생성
        let data: CombinedChartData = CombinedChartData()
        filterOption.measureData.forEach {
            guard let labelString = $0.rawValue.components(separatedBy: .newlines).first else { return }
            
            switch $0 {
            case .breathRate:
                var tempDataEntries: [BarChartDataEntry] = []
                for i in 0..<dayValue.count {
                    let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
                    tempDataEntries.append(dataEntry)
                }
                
                let newDataSet = BarChartDataSet(entries: tempDataEntries,
                                                 label: labelString)
                    .then {
                        $0.setColor(brColor, alpha: 1)
                        $0.highlightEnabled = false
                    }
                
                data.barData = BarChartData(dataSet: newDataSet).then {
                    $0.barWidth = 0.5
                }
                
            case .weight:
                var tempDataEntries: [ChartDataEntry] = []
                for i in 0..<dayValue.count {
                    let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
                    tempDataEntries.append(dataEntry)
                }
                
                let newDataSet = LineChartDataSet(entries: tempDataEntries,
                                                 label: labelString)
                    .then {
                        $0.setColor(wtColor, alpha: 1)
                        $0.highlightEnabled = false
                        $0.circleRadius = 2.0
                        $0.circleHoleRadius = 2.0
                        $0.mode = .cubicBezier
                    }
                data.lineData = LineChartData(dataSet: newDataSet)
            }
        }
        
        // 데이터 셋팅 ( 바, 라인 )
        combinedChartView.data = data
        
        // X축
        combinedChartView.xAxis.labelPosition = .bottom                         // X축 레이블 위치 조정
        combinedChartView.xAxis.setLabelCount(dayValue.count, force: true)      // x축 전체 라벨 보이기
        combinedChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayValue) // X축 레이블 포맷 지정
        
        // 리미트라인
//        let ll = ChartLimitLine(limit: 10.0, label: "타겟")
//        combineChartView.leftAxis.addLimitLine(ll)
        combinedChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
}
