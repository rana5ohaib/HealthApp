//
//  InterfaceController.swift
//  HealthApp Extension
//
//  Created by Sohaib on 26/06/2018.
//  Copyright © 2018 Sohaib. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity
import SwiftyJSON


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    var session: WCSession!
    
    @IBOutlet var todayLabel: WKInterfaceLabel!
  
    @IBOutlet var activityRing: WKInterfaceActivityRing!
    
    override func awake(withContext context: Any?) {
        
        super.awake(withContext: context)
        
        // Configure interface objects here.
        let activitySummary: HKActivitySummary = HKActivitySummary()
        
        
        activitySummary.activeEnergyBurned = HKQuantity(unit: HKUnit.jouleUnit(with: .kilo), doubleValue: 2.0)
        activitySummary.activeEnergyBurnedGoal = HKQuantity(unit: HKUnit.jouleUnit(with: .kilo), doubleValue: 4.0)
        activitySummary.appleExerciseTime = HKQuantity(unit: HKUnit.second(), doubleValue: 8.0)
        activitySummary.appleExerciseTimeGoal = HKQuantity(unit: HKUnit.second(), doubleValue: 10.0)
        activitySummary.appleStandHours = HKQuantity(unit: HKUnit.count(), doubleValue: 900.0)
        activitySummary.appleStandHoursGoal = HKQuantity(unit: HKUnit.count(), doubleValue: 1000.0)
        
        self.activityRing?.setActivitySummary(activitySummary, animated: true)

    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //recieve message here
        print("message from iphone: \(message["a"]!)")
        /*if message["a"] as! String == "updateMe" {
            print("message from iphone: \(message["a"] as! String)")
        }*/
        self.todayLabel.setText(message["a"]! as? String)
    }
    
    @IBAction func sendMessageToIphone() {
        
        //sendMessage
        //session.sendMessage(["b": "GoodBye"], replyHandler: nil, errorHandler: nil)
        
        
            if let path = Bundle.main.path(forResource: "workouts", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    
                    guard  let json = jsonResult as? [String: AnyObject] else {
                        return
                    }
                    
                    //send immediate message
                    session.sendMessage(json, replyHandler: nil, errorHandler: nil)
                    
                } catch {
                    // handle error
                }
            }
        
    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if WCSession.isSupported() {
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

}
