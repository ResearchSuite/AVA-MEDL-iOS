//
//  ViewController.swift
//  MEDL-Reference-App
//
//  Created by Christina Tsangouri on 11/6/17.
//  Copyright © 2017 Christina Tsangouri. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss
import ResearchSuiteAppFramework
import UserNotifications
import sdlrkx


class MEDLViewController: UIViewController {
    
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    var store: RSStore!
    let kActivityIdentifiers = "activity_identifiers"
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var medlFullAssessmentItem: RSAFScheduleItem!
    var medlSpotAssessmentItem: RSAFScheduleItem!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.store = RSStore()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let shouldDoSpot = self.store.get(key: "shouldDoSpot") as! Bool
        
        if (shouldDoSpot) {
            
            self.launchSpotAssessment()
        }
        
        self.shouldDoFullAssessment()
    }
    
    func shouldDoFullAssessment () {
        
        let currentDate = Date()
        
        // Implement should do full assessment
        let fullDate = self.store.valueInState(forKey: "dateFull")
        
        let calendar = NSCalendar.current
        let components = NSDateComponents()
        components.day = 28
        
        
        if(fullDate != nil){
            let futureDate = calendar.date(byAdding: components as DateComponents, to: fullDate as! Date)
            
            if futureDate! <= currentDate {
                
                self.launchFullAssessment()
                
            }
        }
    }
    
    func launchSpotAssessment() {
        self.medlSpotAssessmentItem = AppDelegate.loadScheduleItem(filename: "medl_spot")
        self.launchActivity(forItem: medlSpotAssessmentItem)
    }
    
    func launchFullAssessment () {
        self.medlFullAssessmentItem = AppDelegate.loadScheduleItem(filename: "medl_full")
        self.launchActivity(forItem: medlFullAssessmentItem)
        
    }
    
    func launchActivity(forItem item: RSAFScheduleItem) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let steps = appDelegate.taskBuilder.steps(forElement: item.activity as JsonElement) else {
                return
        }
        
        let task = ORKOrderedTask(identifier: item.identifier, steps: steps)
        
        let taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ()) = { [weak self] (taskViewController, reason, error) in
            //when finised, if task was successful (e.g., wasn't canceled)
            //process results
            if reason == ORKTaskViewControllerFinishReason.completed {
                let taskResult = taskViewController.result
                appDelegate.resultsProcessor.processResult(taskResult: taskResult, resultTransforms: item.resultTransforms)
                
                if(item.identifier == "medl_spot") {
                    self?.store.set(value: false as NSSecureCoding, key: "shouldDoSpot")
                    
                }
                
                
                if(item.identifier == "medl_full"){
                    
                    let date = Date()
                    
                    self?.store.setValueInState(value: date as NSSecureCoding, forKey: "fullDate")

                    
                    var chosen : [String] = []
                    
                    if let chosenMedications: [String]? = taskResult.results?.flatMap({ (stepResult) in
                        if let stepResult = stepResult as? ORKStepResult,
                            stepResult.identifier.hasPrefix("medl_full."),
                            let choiceResult = stepResult.firstResult as? ORKChoiceQuestionResult,
                            let answers = choiceResult.choiceAnswers
                        {
                            NSLog("answer")
                            NSLog(String(describing:answers))
                            
                            for each in answers {
                                chosen.append(each as! String)
                            }
                            
                            
                        }
                        return nil
                    }) {
                        
                        NSLog("chosen")
                        NSLog(String(describing: chosen))
                        
                        self?.store.setValueInState(value: chosen as NSSecureCoding, forKey: "activity_identifiers")
                        
                    }
                    
                }
            }
            
            self?.dismiss(animated: true, completion: nil)
        }
        
        let tvc = RSAFTaskViewController(
            activityUUID: UUID(),
            task: task,
            taskFinishedHandler: taskFinishedHandler
        )
        
        self.present(tvc, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    


}

