//
//  MEDLSpotRaw+CSVEncodable.swift
//  MEDL-Reference-App
//
//  Created by Christina Tsangouri on 1/10/18.
//  Copyright © 2018 Christina Tsangouri. All rights reserved.
//


import Foundation
import Gloss
import sdlrkx
import ResearchSuiteResultsProcessor

extension MEDLFullRaw: CSVEncodable {
    
    open var getDate: String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy-HH:mm"
        let result = formatter.string(from: date)
        
        return result
    }
    
    open var medlItems : [String] {
        
        let medlItems = ["Motrin","Advil","Aleve","Flexeril","Robaxin","Soma","Ultram","Codeine","Zohydro ER","Yoga","Swimming","Meditation"]
        
        return medlItems
    }
    
    open var creationDateTime: Date {
        return self.startDate ?? Date()
    }
    
    open static var typeString: String {
        
        let medlIdentifier = "MEDLFull"
        return medlIdentifier
    
    }
    
    open static var header: String {
        
        let medlHeader = ["timestamp","Motrin","Advil","Aleve","Flexeril","Robaxin","Soma","Ultram","Codeine","Zohydro ER","Yoga","Swimming","Meditation"]
        
        let header = medlHeader.joined(separator:",")
        
        return header
    }
    
    open func toRecords() -> [CSVRecord] {
        
        let timestamp = self.getDate
        var record = ""
        
        let medlResultMap = self.resultMap
        let medlValues = medlResultMap.map { $0.1 }.flatMap{$0}
        
        for item in self.medlItems {
            if medlValues.contains(item) {
                record = record + "selected,"
            }
            else {
                record = record + "not selected,"
            }
        }
        
        let completeRecord = timestamp + "," + record
        
        return [completeRecord]
        
    }
    
}
