//
//  AddLocationAlarmDelegate.swift
//  SleepE
//
//  Created by William Youngs on 10/10/16.
//  Copyright © 2016 William Youngs. All rights reserved.
//

import Foundation

protocol AddLocationAlarmDelegate{
    func addLocationAlarmToAlarmList(Alarm:LocationAlarm) -> LocationAlarm
}
