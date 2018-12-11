//
//  Workouts+CoreDataProperties.swift
//  MyHealthApp
//
//  Created by Sohaib on 21/06/2018.
//  Copyright © 2018 Sohaib. All rights reserved.
//
//

import Foundation
import CoreData


extension Workouts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workouts> {
        return NSFetchRequest<Workouts>(entityName: "Workouts")
    }

    @NSManaged public var time: NSDate?
    @NSManaged public var energyBurned: Double
    @NSManaged public var distance: Double
    @NSManaged public var flightsCombined: Double

}
