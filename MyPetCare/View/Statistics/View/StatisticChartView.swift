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
    
    let groupBarChartView = BarChartView()
    
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
        
        [durationSegmentController, groupBarChartView].forEach {
            addSubview($0)
        }
        
        durationSegmentController.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(segmentHeight)
        }
        
        groupBarChartView.snp.makeConstraints {
            $0.top.equalTo(durationSegmentController.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-10)
        }
    }
    
    // MARK: - Configure Bar Chart
    private func configureBarchart() {

        //legend
        _ = groupBarChartView.legend.then {
            $0.enabled = true
            $0.horizontalAlignment = .center
            $0.verticalAlignment = .top
            $0.orientation = .horizontal
            $0.drawInside = false
            $0.yOffset = 10.0;
            $0.xOffset = 10.0;
            $0.yEntrySpace = 0.0;
        }
        
        _ = groupBarChartView.xAxis.then {
            $0.labelFont = .systemFont(ofSize: 10, weight: .bold)
//            $0.forceLabelsEnabled = true
            $0.granularity = 1
            $0.granularityEnabled = true
            $0.drawGridLinesEnabled = true
            $0.labelPosition = .bottom
        }
        
        _ = groupBarChartView.then {
            $0.noDataText = "데이터가 없습니다."
            $0.noDataFont = .dynamicFont(name: "Cafe24Syongsyong", size: 20)
            $0.noDataTextColor = .black
            $0.doubleTapToZoomEnabled = false       // 줌 허용
            
            // 왼쪽 Y축
            _ = $0.leftAxis.then {
                $0.labelFont = .systemFont(ofSize: 10)
                $0.labelTextColor = brColor
                $0.labelCount = 5
                $0.drawGridLinesEnabled = false
                
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
                $0.drawGridLinesEnabled = false
                
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
    
    // MARK: - Set Chart
    func setChart(filterOption: FilterOptions,
                  resultNormalBrList:[Int],
                  resultSleepBrList:[Int],
                  resultPhyList:[Double]) {
        
        guard !filterOption.measureData.isEmpty else {
            groupBarChartView.clear()
            return
        }
        
        // 최대값 설정
        let finalValue = getBiggestValueInArray(resultNormalBrList, resultSleepBrList, resultPhyList.map{Int($0)}) + 5
        groupBarChartView.leftAxis.axisMaximum = finalValue     // top padding
        groupBarChartView.rightAxis.axisMaximum = finalValue    // top padding
        
        // 요일 데이터 생성
        let dayValue: [String] = TimeUtil().getDayStringByCurrentDay(type: filterOption.duration)
        
        // 데이터 생성
        var data: [BarChartDataSet] = []
        filterOption.measureData.forEach {
            let labelString = $0.getTitle()
            
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
        
        // MARK: - Common Thing For Chart
        // y축 보여줄지 여부 체크
        checkAxisShowedByData(filterOption)
        
        groupBarChartView.xAxis.centerAxisLabelsEnabled = true
        
        if filterOption.duration == .weak { // x 축 전체 라벨 표시
            groupBarChartView.xAxis.setLabelCount(dayValue.count, force: false)
        }
        
        let dataCount = Double(data.count)
        let groupSpace = 0.5
        let barSpace = 0.05 // x2 dataset
        let barWidth: Double = ((1.0-groupSpace)-barSpace*(dataCount))/dataCount   //0.29 // x3 dataset
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        // (barWidth+barSpace)*2 + groupSpace = 1.00
        
        // MARK: - Chart for one measure data
        guard filterOption.measureData.count != 1 else {
            
            let finalData = BarChartData(dataSet: data.first)
            finalData.barWidth = barWidth
            groupBarChartView.data = finalData
            
            groupBarChartView.xAxis.axisMinimum = -1
            groupBarChartView.xAxis.axisMaximum = filterOption.duration.getDayForStatistics()+1
            groupBarChartView.xAxis.centerAxisLabelsEnabled = false
            
            groupBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayValue)
            
            groupBarChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
            return
        }
        
        // MARK: - Chart setting for more two measure data
        let finalData = BarChartData(dataSets: data)
        finalData.barWidth = barWidth

        groupBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayValue)
        
        let gg = finalData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        print("Groupspace: \(gg)")
        let startIndex: Double = 0.0
        let groupCount = filterOption.duration.getDayForStatistics()
        
        groupBarChartView.xAxis.axisMinimum = 0
        groupBarChartView.xAxis.axisMaximum = startIndex + gg * groupCount
        
        finalData.groupBars(fromX: startIndex, groupSpace: groupSpace, barSpace: barSpace)
        
        groupBarChartView.data = finalData
        
        groupBarChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    // MARK: - Chart helper
    private func getBiggestValueInArray(_ array1:[Int], _ array2: [Int], _ array3: [Int]) -> Double {
        
        let nomalBrValue = Double(array1.sorted().last ?? 50)
        let sleepBrValue = Double(array2.sorted().last ?? 50)
        let heighestRightValue = Double(array3.sorted().last ?? 30)
        
        let heighestLeftValue = nomalBrValue >= sleepBrValue ? nomalBrValue : sleepBrValue
        let finalValue = heighestLeftValue > heighestRightValue ? heighestLeftValue : heighestRightValue
        
        return Double(finalValue)
    }
    
    /// 데이터에 따라서 차트의 왼쪽 오른쪽 Y축 감추고 보여주고 용도
    fileprivate func checkAxisShowedByData(_ filterOption: FilterOptions) {
        groupBarChartView.rightAxis.enabled = true
        groupBarChartView.leftAxis.enabled = true
        
        if filterOption.measureData.filter({ $0 == .weight }).isEmpty {
            groupBarChartView.rightAxis.enabled = false
        }
        
        if filterOption.measureData.filter({$0 == .breathRate || $0 == .breathRateInput}).isEmpty {
            groupBarChartView.leftAxis.enabled = false
        }
    }
}
