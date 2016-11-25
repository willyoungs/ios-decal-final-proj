//
//  LocationAlarm.swift
//  SleepE
//
//  Created by William Youngs on 10/11/16.
//  Copyright © 2016 William Youngs. All rights reserved.
//

import UIKit
import MapKit
class LocationAlarm: Alarm {
    var thresholdDist : Float!
    var alarmTitle : String!
    var destinationString : String!
    var lastKnownLocation : CLLocationCoordinate2D!
    var destinationLocation : CLLocationCoordinate2D!
    
    override init(){
        
    }
    override func getName() -> String{
        return "LocationAlarm"
    }
    override func getTitle() -> String {
        return alarmTitle
    }
    
    init(thresholdDistance:Float){
        self.thresholdDist = thresholdDistance
    }
    
    // Right now handling this logic externally... consider removing method
    override func shouldSignalAlarm() {
        
    }
    // Give title to alarm... Implement this in Alarm
    func setAlarmTitle(title:String) {
        alarmTitle = title
    }
    // String representation of Alarm destination
    func setAlarmDestinationString(destString:String){
        destinationString = destString
    }
    
    // Called during alarm creation to set Destination
    func setDestinationLocation(destLoc:CLLocationCoordinate2D) {
        destinationLocation = destLoc
    }
    
    // Sets Last known location of user, useful for tracking distance
    func setLastKnownLocation(lastKnownLoc:CLLocationCoordinate2D)  {
        lastKnownLocation = lastKnownLoc
    }
    
    // Returns the user chosen distance at which he or she should be woken
    func setThresholdDistance(thresholdDistance:Float) {
        thresholdDist = thresholdDistance
    }
}
