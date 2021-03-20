//
//  TimeUtil.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/25.
//

import Foundation

class TimeUtil {
    
    lazy var format = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_kr")
        $0.timeZone = TimeZone(abbreviation: "KST")
    }
    
    let min = 60
    let sec = 60
    let hour = 24
    let sevenDayCount = 7
    let monthCount = 30
    lazy var oneDayBySec = hour*min*sec
    
    enum PresentDateString: String{
        case hhmm = "HH:mm"
        case callHistoryCellStyle = "yyyy/MM/dd\nHH:mm:dd"
        case yymmdd = "yy.MM.dd"
        case mmdd = "MMdd"
        case statisticyyMMdd = "yyyyMMdd"
        case foriCloudSave = "yyyyMMddHHmmddsss"
        case yyyy = "yyyy"
        case MM = "MM"
        case dd = "dd"
    }
    
    func getMonthAndDayString(date: Date,
                              presentType: PresentDateString = .mmdd ) -> String {
        format.dateFormat = presentType.rawValue
        return format.string(from: date)
    }
    
    func getString(_ dateValue: Date, _ type: PresentDateString) -> String {
        format.dateFormat = type.rawValue
        return format.string(from: dateValue)
    }
    
    /// 해당일로부터 weak, month 월+일 구하기 ( 형식 0203, 1012)
    func getMonthAndDayString(_ durationType: Constants.duration, _ presentType: PresentDateString) -> [String] {
        
        var tempTimeInterval: [String] = []
        let currentDate = Date().timeIntervalSince1970
        
        switch durationType {
        case .weak:
            for i in 0..<sevenDayCount {
                let temp = currentDate - TimeInterval(i*oneDayBySec)
                let newDate = Date(timeIntervalSince1970: temp)
                format.dateFormat = presentType.rawValue
                tempTimeInterval.append(format.string(from: newDate))
            }
        case .month:
            for i in 0..<monthCount {
                let temp = currentDate - TimeInterval(i*oneDayBySec)
                let newDate = Date(timeIntervalSince1970: temp)
                format.dateFormat = presentType.rawValue
                tempTimeInterval.append(format.string(from: newDate))
            }
        }
        return tempTimeInterval.reversed()
    }
    
    /// 요일 구하기
    func getDayStringByCurrentDay(type: Constants.duration) -> [String] {
     
        var tempTimeInterval: [Double] = []
        
        let currentDate = Date().timeIntervalSince1970
        format.dateFormat = "E"
        
        switch type {
        case .weak:
            for i in 0..<sevenDayCount {
                let temp = currentDate - TimeInterval(i*oneDayBySec)
                tempTimeInterval.append(temp)
            }
            
        case .month:
            for i in 0..<monthCount {
                let temp = currentDate - TimeInterval(i*oneDayBySec)
                tempTimeInterval.append(temp)
            }
        }
        
        return tempTimeInterval.map{
            format.string(from: Date(timeIntervalSince1970: $0))
        }.reversed()
    }
    
    class func now() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    class func timeDiff( time1:TimeInterval , time2:TimeInterval ) -> TimeInterval {
        return .maximum(time1, time2) - .minimum(time1, time2)
    }
    
    class func timeDiffFromNow( time1:TimeInterval ) -> TimeInterval {
        let now = Date().timeIntervalSince1970
        return .maximum(time1, now) - .minimum(time1, now)
    }
    
    class func timeformat(_ time:TimeInterval , formatString:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        return dateFormatter.string(from: Date(timeIntervalSince1970: time))
    }
    
    class func timeformat(hourFromGMT:Int , minFromGMT:Int , formatString:String )->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        
        let timezone = TimeZone(secondsFromGMT: (hourFromGMT * 3600) + (minFromGMT * 60) )
        dateFormatter.timeZone = timezone
        return dateFormatter.string(from: Date())
    }
    
}
