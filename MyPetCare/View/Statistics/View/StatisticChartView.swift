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
    
    let brColor: UIColor = MeasureServiceType.breathRate.getColor()
    let sleepBrColor: UIColor = MeasureServiceType.breathRateInput.getColor()
    let wtColor: UIColor = MeasureServiceType.weight.getColor()
    
    // MARK: - Properties
    let durationString = ["주간","월간"]
    
    lazy var durationSegmentController = UISegmentedControl(items: durationString).then {
        $0.selectedSegmentIndex = 0
        $0.removeBorder(nomal: .white, selected: UIColor(rgb: 0xdddddd), centerBoarderWidth: 0.2)
        $0.addBorder(.black, 0.2)
    }
    
    let combinedChartView = BarChartView()
    
    // MARK: - Life Cycle
    init(frame: CGRect, segmentHeight: CGFloat) {
        super.init(frame: frame)
        
        configureLayout(frame, segmentHeight)
        
        configureBarchart()
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
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-10)
        }
    }
    
    // MARK: - Configure Bar Chart
    private func configureBarchart() {
        
        let l = combinedChartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = true
        l.font = .systemFont(ofSize: 8, weight: .light)
        l.yOffset = 10
        l.xOffset = 10
        l.yEntrySpace = 0
        
        
        let xAxis = combinedChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.granularity = 1
        xAxis.centerAxisLabelsEnabled = true

        
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
            // 오른쪽 Y축
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
    
    func setChart(filterOption: FilterOptions,
                  resultNormalBrList:[Int],
                  resultSleepBrList:[Int],
                  resultPhyList:[Double]) {
        
        // 최대값 설정
        let finalValue = getBiggestValueInArray(resultNormalBrList, resultSleepBrList, resultPhyList.map{Int($0)}) + 5
        combinedChartView.leftAxis.axisMaximum = finalValue     // top padding
        combinedChartView.rightAxis.axisMaximum = finalValue    // top padding
        
        // 요일 데이터 생성
        let dayValue: [String] = TimeUtil().getDayStringByCurrentDay(type: filterOption.duration)
        let groupCount = Double(filterOption.duration.rawValue)
                
        // 데이터 생성
        var data: [BarChartDataSet] = []
        filterOption.measureData.forEach {
            guard let labelString = $0.rawValue.components(separatedBy: .newlines).first else { return }
            
            switch $0 {
            case .breathRate:
                var tempDataEntries: [BarChartDataEntry] = []
                for i in 0..<dayValue.count {
                    let dataEntry = BarChartDataEntry(x: Double(i), y: Double(resultNormalBrList[i]))
                    tempDataEntries.append(dataEntry)
                }
                
                let newDataSet = BarChartDataSet(entries: tempDataEntries,
                                                 label: labelString)
                    .then {
                        $0.setColor(brColor, alpha: 1)
                        $0.highlightEnabled = false
                        $0.valueTextColor = brColor
                    }
                data.append(newDataSet)
                
            case .breathRateInput:
                var tempDataEntries: [BarChartDataEntry] = []
                for i in 0..<dayValue.count {
                    let dataEntry = BarChartDataEntry(x: Double(i), y: Double(resultSleepBrList[i]))
                    tempDataEntries.append(dataEntry)
                }
                
                let newDataSet = BarChartDataSet(entries: tempDataEntries,
                                                 label: labelString)
                    .then {
                        $0.setColor(sleepBrColor, alpha: 1)
                        $0.highlightEnabled = false
                        $0.valueTextColor = sleepBrColor
                    }
                data.append(newDataSet)
                
            case .weight:
                var tempDataEntries: [BarChartDataEntry] = []
                for i in 0..<dayValue.count {
                    let dataEntry = BarChartDataEntry(x: Double(i), y: resultPhyList[i])
                    tempDataEntries.append(dataEntry)
                }
                
                let newDataSet = BarChartDataSet(entries: tempDataEntries,
                                                 label: labelString)
                    .then {
                        $0.setColor(wtColor, alpha: 1)
                        $0.highlightEnabled = false
                        $0.valueTextColor = wtColor
                    }
                data.append(newDataSet)
            }
        }
        
        let groupSpace = 0.5
        let barSpace = 0.01 // x2 dataset
        let barWidth = 1.0 // x2 dataset
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        
        let finalData = BarChartData(dataSets: data)
        
        // make this BarData object grouped
        finalData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
        combinedChartView.xAxis.axisMinimum = 0.0
        combinedChartView.xAxis.axisMaximum = finalData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)*Double(filterOption.duration == .weak ? 7 : 30)
        finalData.barWidth = barWidth
        
        // 데이터 셋팅 ( 바, 라인 )
        combinedChartView.data = finalData
        
        // X축
        combinedChartView.xAxis.labelPosition = .bottom                         // X축 레이블 위치 조정
        combinedChartView.xAxis.setLabelCount(dayValue.count, force: true)      // x축 전체 라벨 보이기
        combinedChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayValue) // X축 레이블 포맷 지정
        
        // 리미트라인`
//        let ll = ChartLimitLine(limit: 10.0, label: "타겟")
//        combineChartView.leftAxis.addLimitLine(ll)
        combinedChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    private func getBiggestValueInArray(_ array1:[Int], _ array2: [Int], _ array3: [Int]) -> Double {
        
        let nomalBrValue = Double(array1.sorted().last ?? 50)
        let sleepBrValue = Double(array2.sorted().last ?? 50)
        let heighestRightValue = Double(array3.sorted().last ?? 30)
        
        let heighestLeftValue = nomalBrValue >= sleepBrValue ? nomalBrValue : sleepBrValue
        let finalValue = heighestLeftValue > heighestRightValue ? heighestLeftValue : heighestRightValue
        
        return Double(finalValue)
    }
}
