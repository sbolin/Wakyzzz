//
//  Alarm.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation 

class Alarm: Codable { 
    
    static let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var alarmID = UUID()
    var time = 8 * 3600 // 360
    var repeatDays = [false, false, false, false, false, false, false]
    var enabled = true
    var snoozed = false // new
    var timesSnoozed = 0 // new
    
    
    var alarmTimeAndDate: Date? {
        let date = Date()
        let calendar = Calendar.current
        let hour = time/3600 // h
        let minute = time/60 - hour * 60 // m

        var alarmTimeComponents = calendar.dateComponents([.second, .minute, .hour, .day, .month, .year, .weekday], from: date as Date)

        alarmTimeComponents.hour = hour
        alarmTimeComponents.minute = minute

        return calendar.date(from: alarmTimeComponents)
    }
    
    // computed property
    var localAlarmTimeString: String { // switched name to localAlarmTimeString from repeatingDayString
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self.alarmTimeAndDate!)
    }
    
    // computed property
    var repeatingDayString: String { // switched name to repeatingDayString from repeating
        var captions = [String]()
        
// TODO: if repeatDays same as LocalNotification:
//        repeatDays.forEach { repeatDay in
//            captions.append(Alarm.daysOfWeek[repeatDay])
//        }
// based on current repeatDays
        for i in 0 ..< repeatDays.count {
            if repeatDays[i] {
                captions.append(Alarm.daysOfWeek[i])
            }
        }
        
        return captions.count > 0 ? captions.joined(separator: ", ") : "One time alarm"
    }
    
    //MARK: - SetAlarmViewController delegate method
    func setAlarmTime(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        
        time = components.hour! * 3600 + components.minute! * 60        
    }

}
