//
//  AddAlarmViewController.swift
//  SleepE
//
//  Created by William Youngs on 10/10/16.
//  Copyright © 2016 William Youngs. All rights reserved.
//

import UIKit

class AddAlarmViewController: UIViewController,AddLocationAlarmDelegate {
    var delegate: AddAlarmListDelegate?
    
    var titleText:UITextField!
    
    override func viewDidLoad(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        // Setting Location Alarm Button
        let locationAlarmLabel = UIButton()
        locationAlarmLabel.backgroundColor = UIColor.lightGray
        locationAlarmLabel.frame = CGRect(x:0,y:screenHeight*(1.0/4.0),width: screenWidth/2,height:screenHeight/6)
        locationAlarmLabel.setTitle("Add Location Alarm", for: .normal)
        locationAlarmLabel.center = CGPoint(x: screenWidth/2,y:screenHeight*4.0/12)
        locationAlarmLabel.addTarget(self, action: "selectLocationAlarm", for: UIControlEvents.touchUpInside)
        self.view.addSubview(locationAlarmLabel)
        
        
        //Setting up Title Bar
        self.titleText = UITextField()
        let str = NSAttributedString(string: "Alarm Title...", attributes: [NSForegroundColorAttributeName:UIColor.white])
        titleText.attributedPlaceholder = str
        self.titleText.frame = CGRect(x:0,y:screenHeight/10,width:screenWidth,height:screenHeight/10)
        self.titleText.backgroundColor = UIColor.purple
        self.titleText.textColor = UIColor.white
        self.view.addSubview(self.titleText)
        
    }
    
    //Delegate method
    func addLocationAlarmToAlarmList(Alarm: LocationAlarm) -> LocationAlarm {
        delegate?.addToAlarmList(Alarm: Alarm)
        return Alarm
    }
    

    
    
    // Called wheen Add Location Alarm Clicked
    func selectLocationAlarm(){
        let l = AddLocationAlarmViewController()
        l.addLocationAlarmTitle(title: self.titleText.text!)
        l.delegate = self
        navigationController?.pushViewController(l, animated: true)
    }
}
