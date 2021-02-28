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
    // MARK: - Properties
    let durationString = ["주간","월간"]
    
    lazy var durationSegmentController = UISegmentedControl(items: durationString).then {
        $0.selectedSegmentIndex = 0
    }
    
    let barChartView = BarChartView()
    
    // MARK: - Life Cycle
    init(frame: CGRect, segmentHeight: CGFloat) {
        super.init(frame: frame)
        
        configureLayout(frame, segmentHeight)
        
        configureBarchart()
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
                
        setChart(dataPoints: months, values: unitsSold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Layout
    private func configureLayout(_ frame: CGRect, _ segmentHeight: CGFloat) {
        
        [durationSegmentController, barChartView].forEach {
            addSubview($0)
        }
        
        durationSegmentController.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(segmentHeight)
        }
        
        barChartView.snp.makeConstraints {
            $0.top.equalTo(durationSegmentController.snp.bottom).offset(5)
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Configure Bar Chart
    private func configureBarchart() {
        
        _ = barChartView.then {
            $0.noDataText = "데이터가 없습니다."
            $0.noDataFont = .dynamicFont(name: "Cafe24Syongsyong", size: 20)
            $0.noDataTextColor = .black
            
            $0.doubleTapToZoomEnabled = false       // 줌 허용
            $0.leftAxis.axisMaximum = 50            // 맥시멈
            $0.leftAxis.axisMinimum = 10            // 미니멈
        }
        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {

        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        var newDataEntries: [BarChartDataEntry] = []
        let newDataArray = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0].map{$0*1.5}
        for i in 0..<dataPoints.count {
            let newDataEntrie = BarChartDataEntry(x: Double(i), y: newDataArray[i])
            newDataEntries.append(newDataEntrie)
        }

        // 데이터 입력
        let exportDataSet = BarChartDataSet(entries: newDataEntries, label: "수출량").then {
            $0.colors = [.yellow]
            $0.highlightEnabled = false
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "판매량").then {
            $0.colors = [.systemBlue]         // 차트 컬러
            $0.highlightEnabled = false       // 터치 가능 유무
        }
        
        // X축
        barChartView.xAxis.labelPosition = .bottom  // X축 레이블 위치 조정
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints) // X축 레이블 포맷 지정
        barChartView.xAxis.setLabelCount(dataPoints.count, force: false)

        
        // 데이터 삽입
//        let chartData = BarChartData(dataSet: chartDataSet)
//        barChartView.data = chartData
//
        //        let chartData = BarChartData(dataSet: chartDataSet)
        let newCharData = BarChartData(dataSets: [chartDataSet, exportDataSet])
        barChartView.data = newCharData
        
        barChartView.fitBars = true
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1.0
        barChartView.groupBars(fromX: 0, groupSpace: 0, barSpace: 0)
        
        // 리미트라인
        let ll = ChartLimitLine(limit: 10.0, label: "타겟")
        barChartView.leftAxis.addLimitLine(ll)
        
    }
}
