//
//  TimeUtil.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/25.
//

import Foundation

class TimeUtil {
    
    let format = DateFormatter().then {
        $0.locale = Locale(identifier: "ko") // 로케일 변경
    }
    
    let min = 60
    let sec = 60
    let hour = 24
    let sevenDay = 7
    let month = 30
    
    enum PresentDateString: String{
        case hhmm = "HH:mm"
        case callHistoryCellStyle = "yyyy/MM/dd\nHH:mm:dd"
        case yymmdd = "yy.MM.dd"
    }
    
    func getTimeString(_ type: PresentDateString, gmt: Int) -> String {
        
        let date = Date().timeIntervalSince1970 + TimeInterval(gmt/100*min*sec)
        format.timeZone = TimeZone(secondsFromGMT:0)
        format.dateFormat = type.rawValue
        return format.string(from: Date(timeIntervalSince1970: date))
    }
    
    func getString(_ dateValue: Date, _ type: PresentDateString) -> String {
        
//        let date = Date().timeIntervalSince1970 + TimeInterval(gmt/100*min*sec)
//        format.timeZone = TimeZone(secondsFromGMT:0)
        format.dateFormat = type.rawValue
        return format.string(from: dateValue)
        
    }
    
    /// 요일 구하기
    func getSevenDayStringByCurrentDay(type: Constants.duration) -> [String] {
     
        var tempTimeInterval: [Double] = []
        
        let currnetDate = Date().timeIntervalSince1970
        format.dateFormat = "E"
        
        switch type {
        case .weak:
            for i in 0..<sevenDay {
                let temp = currnetDate - TimeInterval(i*hour*min*sec)
                tempTimeInterval.append(temp)
            }
            
        case .month:
            for i in 0..<month {
                let temp = currnetDate - TimeInterval(i*hour*min*sec)
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
