//
//  SignOutViewController.swift
//  MEDL-Reference-App
//
//  Created by Christina Tsangouri on 1/25/18.
//  Copyright © 2018 Christina Tsangouri. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteTaskBuilder
import ResearchSuiteAppFramework

class SignOutViewController: UIViewController, ORKPasscodeDelegate {
    
    var store: RSStore!
    @IBOutlet weak var signinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.store = RSStore()
        // Do any additional setup after loading the view.
        let color = UIColor(red:1.00, green:0.67, blue:0.00, alpha:1.0)
        signinButton.layer.borderWidth = 1.0
        signinButton.layer.borderColor = color.cgColor
        signinButton.layer.cornerRadius = 5
        signinButton.clipsToBounds = true
    }
    
    @IBAction func signinAction(_ sender: Any) {
        let authPassStep = ORKPasscodeStep(identifier:"passcode-auth")
        authPassStep.passcodeFlow = ORKPasscodeFlow(rawValue:1)!
        authPassStep.text="Please enter your 4 digit pin"
        
        let passcodeTask = ORKOrderedTask(identifier:authPassStep.identifier,steps:[authPassStep])
        // let taskViewController = ORKTaskViewController(task: passcodeTask, taskRun: nil)
        let taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ()) = { [weak self] (taskViewController, reason, error) in
            //when finised, if task was successful (e.g., wasn't canceled)
            //process results
            
            
            if reason == ORKTaskViewControllerFinishReason.completed {
                //   let taskResult = taskViewController.result
               // UserDefaults.standard.set(true, forKey: "PassCreated")
                
            }
            
            
            self?.dismiss(animated: true, completion: {
                self?.store.set(value: true as NSSecureCoding, key: "shouldDoSpot")
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc = storyboard.instantiateInitialViewController()
                let delegate = UIApplication.shared.delegate as! AppDelegate!
                delegate?.transition(toRootViewController: vc!, animated: true)
            })
        }
        
        let tvc = RSAFTaskViewController(
            activityUUID: UUID(),
            task: passcodeTask,
            taskFinishedHandler: taskFinishedHandler
        )
        
        self.present(tvc, animated: true, completion: nil)
        
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        // stuff
    }
    
    func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        // stuff
    }

    



}
