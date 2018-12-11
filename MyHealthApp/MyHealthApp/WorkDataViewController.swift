//
//  WorkDataViewController.swift
//  MyHealthApp
//
//  Created by Sohaib on 22/06/2018.
//  Copyright © 2018 Sohaib. All rights reserved.
//

import UIKit
import HealthKit
import CoreData
import WatchConnectivity
import SwiftyJSON

class WorkDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WCSessionDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var wO = [Worcouts]()
    var workouts = [Workouts]()
    var session: WCSession!
    
    override func viewDidLoad() {
        
            tableView.delegate = self
            tableView.dataSource = self
            tableView.prefetchDataSource = self
        
        
            super.viewDidLoad()
            // Do any additional setup after loading the view.
        
            /*let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest() //specifies what entity we are fetching
            do {
                let workouts = try PersistenceService.context.fetch(fetchRequest)
                self.workouts = workouts
                self.tableView.reloadData()
            } catch {
                print("Error in fetching the data")
            }*/
        
            let healthStore = HKHealthStore()
        
            /*if (healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!) == .notDetermined) || (healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!) == .notDetermined) || (healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .flightsClimbed)!) == .notDetermined) {
                print("User has not determined to give data access yet")
            } else {
                
                let finish = NSDate() // Now
                let start = finish.addingTimeInterval(-3600) // 1 hour ago
                
                let totalEnergyBurned = HKQuantity(unit: HKUnit.jouleUnit(with: .kilo), doubleValue: 100)
                
                let totalDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: 300)
                
                let totalFlightsCombined = HKQuantity(unit: HKUnit.count(), doubleValue: 4)
                
                let workout = HKWorkout(activityType: .running, start: start as Date, end: finish as Date, workoutEvents: nil, totalEnergyBurned: totalEnergyBurned, totalDistance: totalDistance, totalFlightsClimbed: totalFlightsCombined, device: nil, metadata: nil)
                
                
                healthStore.save(workout) { (success, error) in
                    guard success else {
                        fatalError("*** An error occurred while saving the " +
                            "workout: \(error?.localizedDescription ?? "Error while saving workout")")
                    }
                }
                
                let workouts = Workouts(context: PersistenceService.context)
                workouts.time = start
                workouts.energyBurned = totalEnergyBurned.doubleValue(for: HKUnit.jouleUnit(with: .kilo))
                workouts.distance = totalDistance.doubleValue(for: HKUnit.meter())
                workouts.flightsCombined = totalFlightsCombined.doubleValue(for: HKUnit.count())
                PersistenceService.saveContext()
                self.workouts.append(workouts)
                self.tableView.reloadData()

        }*/
        //self.tableView.reloadData()
        if WCSession.isSupported() {
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
            
        }
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        //deal with recieved message from watch
        DispatchQueue.main.async {
            
            let swiftyJsonVar = JSON(message["workouts"] as Any)
            
            var cB = swiftyJsonVar.arrayValue.map({$0["Calories Burned"].stringValue})
            var eT = swiftyJsonVar.arrayValue.map({$0["Exercise Time"].stringValue})
            var sT = swiftyJsonVar.arrayValue.map({$0["Stand Time"].stringValue})
            
            for i in 0...swiftyJsonVar.count - 1 {
                self.wO.append(Worcouts(cB: cB[i], eT: eT[i], sT: sT[i]))
            }
            self.tableView.reloadData()
            //self.wO = worcouts(withJson: swiftyJsonVar)
            //print(self.wO.getAll())
        }
    }
    

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return workouts.count
        return self.wO.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 8
        
        /*let date: NSDate = workouts[indexPath.row].time! // Get Todays Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss"
        let stringDate: String = dateFormatter.string(from: date as Date)*/
        
        //let stringDate = self.wO[indexPath.row].getAll()
        
        let string = self.wO[indexPath.row].caloriesBurned + self.wO[indexPath.row].exerciseTime + self.wO[indexPath.row].standTime
        
        cell.cellTitle.text = string
        //cell.cellDetailTitle.text = "Calories Burned: " + String(workouts[indexPath.row].energyBurned) + ", Distance: " + String(workouts[indexPath.row].distance) + " meters, Floors: " + String(workouts[indexPath.row].flightsCombined)
        cell.cellDetailTitle.text = "lel"
        
        return cell
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

struct Worcouts {
    
    var totalWorkouts: Int!
    var caloriesBurned: String!
    var exerciseTime: String!
    var standTime: String!
    
    init (cB: String, eT: String, sT: String) {
        self.caloriesBurned = cB
        self.exerciseTime = eT
        self.standTime = sT
    }
    
    mutating func setAll(cB: String, eT: String, sT: String){
        self.caloriesBurned = cB
        self.exerciseTime = eT
        self.standTime = sT
    }
    
    public func getAll () -> (cB: String, eT: String, sT: String) {
        return (self.caloriesBurned, self.exerciseTime, self.standTime)
    }
    
}

extension WorkDataViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("prefetchRowsAt \(indexPaths)")
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        print("cancelPrefetchingForRowsAt \(indexPaths)")
    }
}








