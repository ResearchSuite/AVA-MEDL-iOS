//
//  MEDLOnboardingViewController.swift
//  MEDL-Reference-App
//
//  Created by Christina Tsangouri on 11/7/17.
//  Copyright © 2017 Christina Tsangouri. All rights reserved.
//


import UIKit
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss
import ResearchSuiteAppFramework
import UserNotifications
import sdlrkx


class MEDLOnboardingViewController: RKViewController {
    
    @IBOutlet weak var startButton: UIButton!
    let kActivityIdentifiers = "activity_identifiers"
    var notifItem: RSAFScheduleItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let color = UIColor.init(colorLiteralRed: 0.44, green: 0.66, blue: 0.86, alpha: 1.0)
//        startButton.layer.borderWidth = 1.0
//        startButton.layer.borderColor = color.cgColor
//        startButton.layer.cornerRadius = 5
//        startButton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startAction(_ sender: Any) {
        
        self.notifItem = AppDelegate.loadScheduleItem(filename: "notification")
        self.launchActivity(forItem: (self.notifItem)!)
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
                
                if(item.identifier == "notification_date"){
                    
                    let result = taskResult.stepResult(forStepIdentifier: "notification_time_picker")
                    let timeAnswer = result?.firstResult as? ORKTimeOfDayQuestionResult
                    
                    let resultAnswer = timeAnswer?.dateComponentsAnswer
                    self?.setNotification(resultAnswer: resultAnswer!)
                    
                }
                
                
            }
            
            self?.dismiss(animated: true, completion: {
                
                // launch full
                
                if(item.identifier == "notification_date"){
                    guard let steps = try! MEDLFullAssessmentCategoryStep.create(identifier: "MEDL Full Assessment Identifier", propertiesFileName: "MEDL") else {
                        return
                    }
                    
                    let task = ORKOrderedTask(identifier: "MEDL Full Assessment Identifier", steps: steps)
                    
                    self?.launchAssessmentForTask(task)
                    
                    // launch spot
                    
//                    guard let step = try! MEDLSpotAssessmentStep.create(identifier: "MEDL Spot Assessment Identifier", propertiesFileName: "MEDL", itemIdentifiers: self?.loadMedicationsForSpotAssessment()) else {
//                        return
//                    }
//                    
//                    let task_spot = ORKOrderedTask(identifier: "MEDL Spot Assessment", steps: [step])
//                    
//                    self?.launchAssessmentForTask(task_spot)
                }
                
                
            })
        
            
        }
        
        let tvc = RSAFTaskViewController(
            activityUUID: UUID(),
            task: task,
            taskFinishedHandler: taskFinishedHandler
        )
        
        self.present(tvc, animated: true, completion: nil)
        
    }
    
//    func loadMedicationsForSpotAssessment() -> [String]? {
//        return UserDefaults().array(forKey: kMedicationIdentifiers) as? [String]
//    }
    
    func setNotification(resultAnswer: DateComponents) {
        
        var userCalendar = Calendar.current
        userCalendar.timeZone = TimeZone(abbreviation: "EDT")!
        
        var fireDate = NSDateComponents()
        
        let hour = resultAnswer.hour
        let minutes = resultAnswer.minute
        
        fireDate.hour = hour!
        fireDate.minute = minutes!
        
        self.delegate.store.setValueInState(value: String(describing:hour!) as NSSecureCoding, forKey: "notificationHour")
        self.delegate.store.setValueInState(value: String(describing:minutes!) as NSSecureCoding, forKey: "notificationMinutes")
        
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "MEDL"
            content.body = "It'm time to complete your MEDL Assessment"
            content.sound = UNNotificationSound.default()
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: fireDate as DateComponents,
                                                        repeats: true)
            
            let identifier = "UYLLocalNotification"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.center.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    // Something went wrong
                }
            })
            
        } else {
            // Fallback on earlier versions
            
            let dateToday = Date()
            let day = userCalendar.component(.day, from: dateToday)
            let month = userCalendar.component(.month, from: dateToday)
            let year = userCalendar.component(.year, from: dateToday)
            
            fireDate.day = day
            fireDate.month = month
            fireDate.year = year
            
            let fireDateLocal = userCalendar.date(from:fireDate as DateComponents)
            
            let localNotification = UILocalNotification()
            localNotification.fireDate = fireDateLocal
            localNotification.alertTitle = "MEDL"
            localNotification.alertBody = "It's time to complete your MEDL Assessment"
            localNotification.timeZone = TimeZone(abbreviation: "EDT")!
            //set the notification
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
        
        
    }

    
    



}
