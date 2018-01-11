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

extension MEDLSpotRaw: CSVEncodable {
    
    open var getDate: String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy-HH:mm"
        let result = formatter.string(from: date)
        
        return result
    }
    
    
    open var medlHeader : [String] {
        
       let medlHeader = ["timestamp","Motrin","Advil","Aleve","Flexeril","Robaxin","Soma","Ultram","Codeine","Zohydro ER","Yoga","Swimming","Meditation"]
        
        return medlHeader
    }
    
    open var creationDateTime: Date {
        return self.startDate ?? Date()
    }
    
    open static var typeString: String {
        
        let medlIdentifier = "MEDLSpot"
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
        
        for each in self.medlHeader {
           
            if self.selected.contains(each){
                record = record + "selected,"
            }
            
            if self.notSelected.contains(each){
                record = record + "not selected,"
            }
            
            if self.excluded.contains(each){
                record = record + "excluded,"
            }
            
        }
        
        
        let completeRecord = timestamp + "," + record
        
        return [completeRecord]
        
    }
    
}
