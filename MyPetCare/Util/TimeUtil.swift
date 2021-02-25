//
//  TimeUtil.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/25.
//

import Foundation

class TimeUtil {
    
    let format = DateFormatter()
    let min = 60
    let sec = 60
    
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
