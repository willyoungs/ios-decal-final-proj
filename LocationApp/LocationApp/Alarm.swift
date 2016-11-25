//
//  Alarm.swift
//  SleepE
//
//  Created by William Youngs on 10/11/16.
//  Copyright © 2016 William Youngs. All rights reserved.
//

import UIKit
// SuperClass of TimeAlarm and LocationAlarm
class Alarm {
    //TODO: Declare Varianbles
    
    
    init() {
        print("Initializers")
    }
    func shouldSignalAlarm() {
        
    }
    // Overridden in respective subclasses. Use this to differentiate them.
    func getName() -> String {
        return "Alarm Name"
    }
    func getTitle() -> String{
        return "Generic Title..."
    }
}
