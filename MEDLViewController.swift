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


class MEDLViewController: RKViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let shouldDoSpot = self.delegate.store.get(key: "shouldDoSpot") as! Bool
        
        if (shouldDoSpot) {
            
           // self.launchSpotAssessment() //launching full now
            self.launchMEDLAssessment()
        }
    
    }

    func launchSpotAssessment() {
        guard let steps = try! MEDLFullAssessmentCategoryStep.create(identifier: "MEDL Full Assessment Identifier", propertiesFileName: "MEDL") else {
            return
        }
        
        let task = ORKOrderedTask(identifier: "MEDL Full Assessment Identifier", steps: steps)
        
        self.launchAssessmentForTask(task)
    }
    
    func launchMEDLAssessment() {
        guard let steps = try! MEDLFullAssessmentCategoryStep.create(identifier: "MEDL Full Assessment Identifier", propertiesFileName: "MEDL") else {
            return
        }
        
        let task = ORKOrderedTask(identifier: "MEDL Full Assessment Identifier", steps: steps)

        
        let tvc = RSAFTaskViewController(activityUUID: UUID(), task: task, taskFinishedHandler: { [weak self] (taskViewController, reason, error) in
            
            guard reason == ORKTaskViewControllerFinishReason.completed else {
                self?.dismiss(animated: true, completion: nil)
                return
            }
            
//            let taskResult = taskViewController.result
//            let result = taskResult.stepResult
          
//            if (result.identifier.hasPrefix("MEDL Full Assessment Identifier."))! {
//                let answer = result.firstResult as? ORKChoiceQuestionResult
//                NSLog("answer",answer ?? "nill")
//            }
//   
            
            //AppDelegate.appDelegate.resultsProcessor.processResult(taskResult: taskResult, resultTransforms: activity.resultTransforms)
            
            self?.dismiss(animated: true, completion: {
               // self?.delegate.store.set(value: false as NSSecureCoding, key: "shouldDoDaily")
                
            })
            
        })
        
        self.present(tvc, animated: true, completion: nil)
        

    }

}

