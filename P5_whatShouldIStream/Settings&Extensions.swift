//
//  Settings.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/17/16.
//  Copyright © 2016 MJH. All rights reserved.
//https://drive.google.com/file/d/0B73-lYm3LuviUlRPeHpXc3FrY1E/view?usp=sharing
//https://drive.google.com/file/d/0B73-lYm3LuviUlRPeHpXc3FrY1E/view?
//https://docs.google.com/document/d/1uQ89GhyOHt49-3Zxgg3FpqvWlQko1SlgZpqs/export?format=txt


import UIKit

struct MasterLists {
    static let filename = "wsis.txt"
    static let googleDriveLocation = "https://docs.google.com/document/d/1uQ89GhyOHt49-3Zxgg3FpqvWlQko1SlgZpqs-hseeds/export?format=txt"
}

struct Service {
    static let Netflix = "Netflix"
    static let Amazon = "Amazon Prime"
    
}

//MARK: Extentions

//extension NSDate {
//    func numberOfDaysUntilDateTime(toDateTime: NSDate, inTimeZone timeZone: NSTimeZone? = nil) -> Int {
//        let calendar = NSCalendar.currentCalendar()
//        if let timeZone = timeZone {
//            calendar.timeZone = timeZone
//        }
//        
//        var fromDate: NSDate?, toDate: NSDate?
//        
//        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: self)
//        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: toDateTime)
//        
//        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
//        return difference.day
//    }
//}

extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
}