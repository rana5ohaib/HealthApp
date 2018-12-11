//
//  ViewController.swift
//  MyHealthApp
//
//  Created by Sohaib on 11/06/2018.
//  Copyright © 2018 Sohaib. All rights reserved.
//


//1- Enable HealthKit - from capabillities
//2- Ensure HealthKit is available
//3- initiate HealthKitStore
//4- Define ReadAble and Shareable Types
//5- Request Pelinkedrmission to Read and Share Data
//6- Fetch Three types of data types that iphone supports (For more data Watch device is needed)
//7- Make Activity Ring
//8- Activate the session

import UIKit
import HealthKit
import HealthKitUI
//import WatchConnectivity
//import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var todayLabel: UILabel!
    
    //var session: WCSession!

    var distanceWalkRun: Double = 0
    var flightsClimbed: Double = 0
    var steps: Double = 0
    var count = 0
    
    @IBOutlet weak var activityRing: HKActivityRing!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //2
        guard HKHealthStore.isHealthDataAvailable() else { return } //Exit If Health Data not available on the device
        
        //3
        let healthStore = HKHealthStore() //create Store
        
        //4
        let readAbleTypes = Set<NSObject>(  arrayLiteral: HKObjectType.workoutType(), //Define the types
                                            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
                                            HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                            HKObjectType.activitySummaryType())
        
        let shareAbleTypes = Set<NSObject>( arrayLiteral: HKObjectType.workoutType(), //Define the types
                                            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                                            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!)
        
    
        //5
        self.requestAuthorizationn(healthStore, readAbleTypes: readAbleTypes, shareAbleTypes: shareAbleTypes)
        
        //6
        /*if WCSession.isSupported() {
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
            print("Session is activated on iOS")
            /*if session.isWatchAppInstalled {
                print("WatchApp is installed")
            }
            if session.isReachable {
                print("WatchApp is running and is on the foreground")
            }
            if session.isPaired {
                print("iPhone is paired with the Apple Watch")
            }*/
        }*/
        
        
    }
    
    /*func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //recieve message from watch
        //print("message from watch: \(message["b"]!)")
        DispatchQueue.main.async {
            //self.todayLabel.text = message["b"]! as? String
            let swiftyJsonVar = JSON(message["workouts"] as Any)
            let wO = workouts(withJson: swiftyJsonVar)
            print(wO.getAll())
        }
    }*/
    
    func makeActivityRing(_ healthStore: HKHealthStore) {
        
        //check if user has determined to give or deny access for data reuired for activity Ring
        if healthStore.authorizationStatus(for: HKObjectType.activitySummaryType()) == .notDetermined {
            print("User has not determined to give data access yet")
            
        } else {
            // Get the data and Animate Activity Ring
            self.animateActivityRing(healthStore)
        }
        
    }
    
    func animateActivityRing(_ healthStore: HKHealthStore) {
        
        // Create the predicate for the query
        let predicate = createPredicateForActivity()
        
        
        let query = HKActivitySummaryQuery(predicate: predicate) { query, summaries, error in
            
            guard summaries != nil else { return } //exit if no data returned
            
            let energyUnit   = HKUnit.jouleUnit(with: .kilo)
            let exerciseUnit = HKUnit.second()
            let standUnit    = HKUnit.count()
            
            //print("Inside Last Query Results Distance: \(self.distanceWalkRun), Floors Climbed: \(self.flightsClimbed) and Steps: \(self.steps)")
            
            let activitySummary: HKActivitySummary = HKActivitySummary()
            
            activitySummary.activeEnergyBurned = HKQuantity(unit: energyUnit, doubleValue: self.distanceWalkRun)
            activitySummary.activeEnergyBurnedGoal = HKQuantity(unit: energyUnit, doubleValue: 4.0)
            activitySummary.appleExerciseTime = HKQuantity(unit: exerciseUnit, doubleValue: self.flightsClimbed)
            activitySummary.appleExerciseTimeGoal = HKQuantity(unit: exerciseUnit, doubleValue: 10.0)
            activitySummary.appleStandHours = HKQuantity(unit: standUnit, doubleValue: self.steps)
            activitySummary.appleStandHoursGoal = HKQuantity(unit: standUnit, doubleValue: 1000.0)
            
            //Display Activity Ring
            DispatchQueue.main.async {
                self.activityRing.setActivitySummary(activitySummary, animated: true)
            }
            
        }
        healthStore.execute(query)
    }
    
    func createPredicateForActivity () -> NSPredicate {
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        
        let endDate = NSDate()
        
        let startDate = calendar?.date(byAdding: .day, value: -1, to: endDate as Date, options: [])
        
        let units: NSCalendar.Unit = [.day, .month, .year, .era]
        
        var startDateComponents = calendar?.components(units, from: startDate!)
        startDateComponents?.calendar = calendar! as Calendar
        
        var endDateComponents = calendar?.components(units, from: endDate as Date)
        endDateComponents?.calendar = calendar! as Calendar
        
        // Create the predicate for the query
        return HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents!, end: endDateComponents!)
        
    }
    
    func createPredicate() -> NSPredicate {
        
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([ .year, .month, .day ], from: Date())
        
        let startDate = calendar.date(from: dateComponents)
        
        let endDate = calendar.date(byAdding: .day, value: +1, to: startDate!)
        
        // Create the predicate for the query
        return HKQuery.predicateForSamples(withStart: startDate , end: endDate, options: .strictEndDate)
    }
    
    func fetchWalkRunDistance (_ healthStore: HKHealthStore) {
        
        // Create the predicate for the query
        let predicate = createPredicate()
        
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
        
        //create query
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in
            
            guard let samples = results as? [HKQuantitySample] else {
                fatalError("An error occured fetching the user's tracked food. Error: \(String(describing: error?.localizedDescription))");
            }
            
            for sample in samples {
                if sample.quantity.is(compatibleWith: HKUnit.mile()) {
                    self.distanceWalkRun += sample.quantity.doubleValue(for: HKUnit.mile()) * 1.60934
                }
                if sample.quantity.is(compatibleWith: HKUnit.foot()) {
                    self.distanceWalkRun += sample.quantity.doubleValue(for: HKUnit.foot()) / 3280.84
                }
            }
            
            //make double restricted to 2 floating point numbers
            let multiplier = pow(10.0, 2.0)
            self.distanceWalkRun = round(self.distanceWalkRun * multiplier) / multiplier
            //print("Inside query Distance: \(self.distanceWalkRun)")
            
            self.count = self.count + 1
            if self.count == 3 {
                //Make Activity Ring
                self.makeActivityRing(healthStore)
            }
        }
        
        //run query
        healthStore.execute(query)
    }
    
    func fetchFlightsClimbed (_ healthStore: HKHealthStore) {
        
        // create predicate
        let predicate = createPredicate()
        
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        
        //create Query
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in
            
            guard let samples = results as? [HKQuantitySample] else {
                fatalError("An error occured fetching the user's tracked floors Climbed. In your app, try to handle this error gracefully. The error was: \(String(describing: error?.localizedDescription))");
            }
            //print("Inside query Floors Climbed: \(samples.count)")
            self.flightsClimbed = Double(samples.count)
            
            self.count = self.count + 1
            if self.count == 3 {
                //Make Activity Ring
                self.makeActivityRing(healthStore)
            }
            
        }
        
        //run query
        healthStore.execute(query)
    }
    
    func fetchSteps(_ healthStore: HKHealthStore) {

        // Create the predicate for the query
        let predicate = createPredicate()
        
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        //create query
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in
            
            guard let samples = results as? [HKQuantitySample] else {
                fatalError("An error occured fetching the user's tracked steps. Error: \(String(describing: error?.localizedDescription))");
            }
            for sample in samples {
                self.steps +=  sample.quantity.doubleValue(for: HKUnit.count())
            }
            //print("Inside query Steps: \(self.steps)")
            
            self.count = self.count + 1
            if self.count == 3 {
                //Make Activity Ring
                self.makeActivityRing(healthStore)
            }
        }
        
        //run query
        healthStore.execute(query)
        
    }
    
    
    
    @IBAction func startWorkoutPressed(_ sender: Any) {
        performSegue(withIdentifier: "toWorkData", sender: nil)
        //send message to watch
        //session.sendMessage(["a":"hello"], replyHandler: nil, errorHandler: nil)
    }
    
    func requestAuthorizationn(_ healthStore: HKHealthStore, readAbleTypes: Set<NSObject>, shareAbleTypes: Set<NSObject>) {
        healthStore.requestAuthorization(toShare: shareAbleTypes as? Set<HKSampleType> , read: readAbleTypes as? Set<HKObjectType>, completion: { (success, error) in
            
            if !success {
                //handle the error here
            }
            
            //6 fetch No. of Steps, floors Climbed and distance (Walking + Running) covered on current day and animate ActivityRing
            self.fetchSteps(healthStore)
            self.fetchFlightsClimbed(healthStore)
            self.fetchWalkRunDistance(healthStore)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //if retreiving data from the Apple Watch Use this method to animate the rings
    /*func updateActivitySummary (_ healthStore: HKHealthStore) {
     
     if healthStore.authorizationStatus(for: HKObjectType.activitySummaryType()) == .notDetermined {
     print("User has not determined to give data access yet")
     
     } else {
     
     // Create the date components for the predicate
     guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
     fatalError("*** This should never fail. ***")
     }
     
     let endDate = NSDate()
     
     guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate as Date, options: []) else {
     fatalError("*** unable to calculate the start date ***")
     }
     
     let units: NSCalendar.Unit = [.day, .month, .year, .era]
     
     var startDateComponents = calendar.components(units, from: startDate)
     startDateComponents.calendar = calendar as Calendar
     
     var endDateComponents = calendar.components(units, from: endDate as Date)
     endDateComponents.calendar = calendar as Calendar
     
     // Create the predicate for the query
     let summariesWithinRange = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
     
     
     let query = HKActivitySummaryQuery(predicate: summariesWithinRange) { query, summaries, error in
     
     guard let todayActivitySummary = summaries?.first else { return }
     
     //for hard coded vales -------------------------------------
     let activitySummary: HKActivitySummary = HKActivitySummary()
     
     let energyUnit   = HKUnit.jouleUnit(with: .kilo)
     let exerciseUnit = HKUnit.second()
     let standUnit    = HKUnit.count()
     
     activitySummary.activeEnergyBurned = HKQuantity(unit: energyUnit, doubleValue: 9.0)
     activitySummary.activeEnergyBurnedGoal = HKQuantity(unit: energyUnit, doubleValue: 13.0)
     activitySummary.appleExerciseTime = HKQuantity(unit: exerciseUnit, doubleValue: 21.0)
     activitySummary.appleExerciseTimeGoal = HKQuantity(unit: exerciseUnit, doubleValue: 15.0)
     activitySummary.appleStandHours = HKQuantity(unit: standUnit, doubleValue: 8.0)
     activitySummary.appleStandHoursGoal = HKQuantity(unit: standUnit, doubleValue: 10.0)
     ------------------------------------------------------------
     
     DispatchQueue.main.async {
     //print("Inside dispatch")
     self.activityRing.setActivitySummary(todayActivitySummary, animated: true)
     }
     
     }
     healthStore.execute(query)
     }
     }*/

}

/*struct workouts {
    
    private var totalWorkouts: Int
    private var caloriesBurned = [String]()
    private var exerciseTime = [String]()
    private var standTime = [String]()
    
    init(withJson: JSON) {
        
        self.totalWorkouts = withJson.count
        let cB = withJson.arrayValue.map({$0["Calories Burned"].stringValue})
        let eT = withJson.arrayValue.map({$0["Exercise Time"].stringValue})
        let sT = withJson.arrayValue.map({$0["Stand Time"].stringValue})
        
        for str in cB{
            self.caloriesBurned.append(str)
        }
        for str in eT {
            self.exerciseTime.append(str)
        }
        for str in sT {
            self.standTime.append(str)
        }
    }

    public func getAll () -> (cB: [String], eT: [String], sT: [String]) {
        return (self.caloriesBurned, self.exerciseTime, self.standTime)
    }
    
}*/


