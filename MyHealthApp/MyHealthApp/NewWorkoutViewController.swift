//
//  NewWorkoutViewController.swift
//  MyHealthApp
//
//  Created by Sohaib on 22/06/2018.
//  Copyright © 2018 Sohaib. All rights reserved.
//

import UIKit
import HealthKit

class NewWorkoutViewController: UIViewController {

    var isPressed: Bool = false
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBAction func startWorkout(_ sender: Any) {
        if !isPressed {
            let calender = Calendar.current
            var components = calender.dateComponents([.era, .year, .month, .day], from: Date())
            components.calendar = calender
            
            guard let startDateIs = calender.date(from: components) else {
                fatalError("*** Unable to create the start date ***")
            }
            self.startDate = startDateIs
            startStopButton.titleLabel?.text = "Stop"
            isPressed = true
        } else {
            let calender = Calendar.current
            var components = calender.dateComponents([.era, .year, .month, .day], from: Date())
            components.calendar = calender
            
            guard let endDateIs = calender.date(from: components) else {
                fatalError("*** Unable to create the start date ***")
            }
            self.endDate = endDateIs
            
            guard let sampleType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
                fatalError("*** This method should never fail ***")
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: self.endDate, options: HKQueryOptions())
            
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: nil) { (query, result, error) in
                
                guard let sample = result as? [HKQuantitySample] else {
                    fatalError("An error occured fetching the user's tracked food. In your app, try to handle this error gracefully. The error was: \(error?.localizedDescription)");
                }
                
            }
            
            startStopButton.titleLabel?.text = "Start"
            isPressed = false
        }

    }
    @IBAction func prevWorkouts(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
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
