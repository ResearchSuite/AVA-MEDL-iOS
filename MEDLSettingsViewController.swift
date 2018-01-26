//
//  SettingsViewController.swift
//  PAM-Reference-App
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
import MessageUI
import ResearchSuiteResultsProcessor
import sdlrkx

class MEDLSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet
    var tableView: UITableView!
    
    var store: RSStore!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var items: [String] = ["Take Full Assessment", "Take Spot Assessment","Set Notification Time","Email Full Assessment Data", "Email Spot Assessment Data","Sign Out"]
    var fullAssessmentItem: RSAFScheduleItem!
    var spotAssessmentItem: RSAFScheduleItem!
    var notificationItem: RSAFScheduleItem!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        self.store = RSStore()
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedCell = tableView.cellForRow(at: indexPath)!
        deselectedCell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let notificationHour = self.store.valueInState(forKey: "notificationHour") as! String
        let notificationMinutes = self.store.valueInState(forKey: "notificationMinutes") as! String
        
        var convertedTime:[String]! = []
        
        convertedTime = self.hourConversion(hour: notificationHour,minute: notificationMinutes)
        
        let notificationString = self.items[2] + ":      " + convertedTime[0] + ":" + convertedTime[2] + " " + convertedTime[1]
        
        
        if(indexPath.row == 2) {
            cell.textLabel?.text = notificationString
        }
        else {
            
            cell.textLabel?.text = self.items[indexPath.row]
        }
        
        cell.textLabel?.textColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
        
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60.0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            self.launchFullAssessment()
        }
        
        if indexPath.row == 1 {
            self.launchSpotAssessment()
        }
        
        if indexPath.row == 2 {
            self.setNotification()
        }
        
        if indexPath.row == 3 {
            let shouldSendFullEmail = self.store.valueInState(forKey: "fullFileExists") as! Bool
            if(shouldSendFullEmail){
                self.getSendFullConsent()
            }
            else {
                let sendMailErrorAlert = UIAlertView(title: "No Full Assessment Saved", message: "Please retake a Full Assessment", delegate: self, cancelButtonTitle: "OK")
                sendMailErrorAlert.show()
            }

        }
        
        if indexPath.row == 4 {
            let shouldSendSpotEmail = self.store.valueInState(forKey: "spotFileExists") as! Bool
            if(shouldSendSpotEmail){
                self.getSendSpotConsent()
            }
            else {
                let sendMailErrorAlert = UIAlertView(title: "No Spot Assessment Saved", message: "Please retake a Spot Assessment", delegate: self, cancelButtonTitle: "OK")
                sendMailErrorAlert.show()
            }
        }
        
        if indexPath.row == 5 {
            self.signOut()
        }

        
    }
    
    func launchFullAssessment() {
        self.fullAssessmentItem = AppDelegate.loadScheduleItem(filename: "medl_full")
        self.launchActivity(forItem: fullAssessmentItem)
    }
    
    func launchSpotAssessment() {
        self.spotAssessmentItem = AppDelegate.loadScheduleItem(filename: "medl_spot")
        self.launchActivity(forItem: spotAssessmentItem)
    }
    
    func setNotification() {
        self.notificationItem = AppDelegate.loadScheduleItem(filename: "notification")
        self.launchActivity(forItem: notificationItem)
    }
    
    func getSendFullConsent() {
        let alertController = UIAlertController(title: "You can email all of your responses to AVA MEDL Full Assessment to anyone you like in one easy to read file.", message: "Please be mindful of your privacy: this email will use your email provider, will contain all of your responses in this app since you installed it, and once the email is sent it cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.sendFullEmail()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendFullEmail() {
        
        self.store.setValueInState(value: true as NSSecureCoding, forKey: "sendingFull")
        self.store.setValueInState(value: false as NSSecureCoding, forKey: "sendingSpot")
        
        let mailComposeViewController = configuredFullMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
       
    }
    
    func getSendSpotConsent() {
        let alertController = UIAlertController(title: "You can email all of your responses to AVA MEDL Spot Assessment to anyone you like in one easy to read file.", message: "Please be mindful of your privacy: this email will use your email provider, will contain all of your responses in this app since you installed it, and once the email is sent it cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.sendSpotEmail()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendSpotEmail () {
        
        self.store.setValueInState(value: true as NSSecureCoding, forKey: "sendingSpot")
        self.store.setValueInState(value: false as NSSecureCoding, forKey: "sendingFull")
        
        let mailComposeViewController = configuredSpotMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
       
    }
    
    func deleteSpotFile() {
        delegate.CSVBackend.removeFileForType(type: MEDLSpotRaw.self)
       // delegate.CSVBackend.removeFileForType(type: MEDLFullRaw.kType)
    }
    
    func deleteFullFile() {
        delegate.CSVBackend.removeFileForType(type: MEDLFullRaw.self)
       // delegate.CSVBackend.removeFileForType(type: "MEDLFull")
    }
    
    func configuredSpotMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("MEDL Spot Data")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        
        let attach = delegate.CSVBackend.getFileURLForType(typeIdentifier: "MEDLSpot")
        
        do {
            
            if FileManager.default.fileExists(atPath: (attach?.path)!){
                let cert = try NSData(contentsOfFile: (attach?.path)!)  as Data
                
                mailComposerVC.addAttachmentData(cert as Data, mimeType: "text/csv", fileName: "MedlSpot.csv")
                
                return mailComposerVC
                
            }
        } catch {
            print(error)
        }
        
        
        return mailComposerVC
    }
    
    func configuredFullMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("MEDL Full Data")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        
        let attach = delegate.CSVBackend.getFileURLForType(typeIdentifier: "MEDLFull")
        
        do {
           
            if FileManager.default.fileExists(atPath: (attach?.path)!){
                let cert = try NSData(contentsOfFile: (attach?.path)!)  as Data
                
                mailComposerVC.addAttachmentData(cert as Data, mimeType: "text/csv", fileName: "MEDLFull.csv")
                
                return mailComposerVC
                
            }
        } catch {
            print(error)
        }
        
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        let sendingSpot = self.store.valueInState(forKey: "sendingSpot") as! Bool
        let sendingFull = self.store.valueInState(forKey: "sendingFull") as! Bool
        
        if(result == MFMailComposeResult.sent){
            
            if (sendingSpot){
                self.deleteSpotFile()
                self.store.setValueInState(value: false as NSSecureCoding, forKey: "spotFileExists")
                self.store.setValueInState(value: false as NSSecureCoding, forKey: "sendingSpot")
                
            }
            if (sendingFull){
                self.deleteFullFile()
                self.store.setValueInState(value: false as NSSecureCoding, forKey: "fullFileExists")
                self.store.setValueInState(value: false as NSSecureCoding, forKey: "sendingFull")
            }
        }
            
        else {
            if (sendingSpot){
                self.store.setValueInState(value: false as NSSecureCoding, forKey: "sendingSpot")
            }
            if (sendingFull){
                self.store.setValueInState(value: false as NSSecureCoding, forKey: "sendingFull")
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func signOut() {
       // UserDefaults.standard.set(false, forKey: "PassCreated")
        let storyboard = UIStoryboard(name: "SignOut", bundle: Bundle.main)
        let vc = storyboard.instantiateInitialViewController()
        self.delegate.transition(toRootViewController: vc!, animated: true)
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
                    DispatchQueue.main.async{
                        self?.tableView.reloadData()
                    }
                    
                }
                
                if(item.identifier == "medl_spot"){
                    self?.store.setValueInState(value: true as NSSecureCoding, forKey: "spotFileExists")
                }
                
                if(item.identifier == "medl_full"){
                    
                    let date = Date()
                    
                    self?.store.setValueInState(value: date as NSSecureCoding, forKey: "fullDate")
                    
                    // save that a full file exists
                    
                    self?.store.setValueInState(value: true as NSSecureCoding, forKey: "fullFileExists")
                    
                    var chosen : [String] = []
                    
                    if let chosenMedications: [String]? = taskResult.results?.flatMap({ (stepResult) in
                        if let stepResult = stepResult as? ORKStepResult,
                            stepResult.identifier.hasPrefix("medl_full."),
                            let choiceResult = stepResult.firstResult as? ORKChoiceQuestionResult,
                            let answers = choiceResult.choiceAnswers
                        {
                            
                            for each in answers {
                                chosen.append(each as! String)
                            }
                            
                            
                        }
                        return nil
                    }) {

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
    
    func hourConversion (hour: String, minute: String) -> [String] {
        
        var newHour: String!
        var newMinute: String!
        var am_pm: String!
        
        var minuteInt: Int = Int(minute)!
        if minuteInt < 10 {
            newMinute = "0" + minute
        }
        else {
            newMinute = minute
        }
        
        switch hour{
        case "00":
            newHour = "12"
            am_pm = "am"
        case "12":
            newHour = "12"
            am_pm = "pm"
        case "13":
            newHour = "1"
            am_pm = "pm"
        case "14":
            newHour = "2"
            am_pm = "pm"
        case "15":
            newHour = "3"
            am_pm = "pm"
        case "16":
            newHour = "4"
            am_pm = "pm"
        case "17":
            newHour = "5"
            am_pm = "pm"
        case "18":
            newHour = "6"
            am_pm = "pm"
        case "19":
            newHour = "7"
            am_pm = "pm"
        case "20":
            newHour = "8"
            am_pm = "pm"
        case "21":
            newHour = "9"
            am_pm = "pm"
        case "22":
            newHour = "10"
            am_pm = "pm"
        case "23":
            newHour = "11"
            am_pm = "pm"
        default:
            newHour = hour
            am_pm = "am"
        }
        
        
        return [newHour,am_pm,newMinute]
        
    }
    
    func setNotification(resultAnswer: DateComponents) {
        
        var userCalendar = Calendar.current
        userCalendar.timeZone = TimeZone(abbreviation: "EDT")!
        
        var fireDate = NSDateComponents()
        
        let hour = resultAnswer.hour
        let minutes = resultAnswer.minute
        
        fireDate.hour = hour!
        fireDate.minute = minutes!
        
        delegate.store.setValueInState(value: String(describing:hour!) as NSSecureCoding, forKey: "notificationHour")
        delegate.store.setValueInState(value: String(describing:minutes!) as NSSecureCoding, forKey: "notificationMinutes")
        
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "MEDL"
            content.body = "It'm time to complete your MEDL Spot Assessment"
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
            localNotification.alertBody = "It's time to complete your MEDL Spot Assessment"
            localNotification.timeZone = TimeZone(abbreviation: "EDT")!
            //set the notification
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
        
        
    }


    
    
}
