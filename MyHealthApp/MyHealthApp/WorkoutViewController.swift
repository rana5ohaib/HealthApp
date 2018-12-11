//
//  WorkoutViewController.swift
//  MyHealthApp
//
//  Created by Sohaib on 20/06/2018.
//  Copyright © 2018 Sohaib. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

class WorkoutViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var workouts = [Workouts]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //fetching data from coreData
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest() //specifies what entity we are fetching
        do {
            let workouts = try PersistenceService.context.fetch(fetchRequest)
            self.workouts = workouts
            self.tableView.reloadData()
        } catch {
            print("Error in fetching the data")
        }
        
        let healthStore = HKHealthStore()
        
        if (healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!) == .notDetermined) || (healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!) == .notDetermined) || (healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .flightsClimbed)!) == .notDetermined) {
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
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension WorkoutViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let date: NSDate = workouts[indexPath.row].time! // Get Todays Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss"
        let stringDate: String = dateFormatter.string(from: date as Date)
        cell.textLabel?.text = stringDate
        cell.detailTextLabel?.text = "Calories Burned: " + String(workouts[indexPath.row].energyBurned) + ", Distance: " + String(workouts[indexPath.row].distance) + " meters, Floors: " + String(workouts[indexPath.row].flightsCombined)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.black
        return cell

    }
}
