//
//  EditLocationViewController.swift
//  SleepE
//
//  Created by William Youngs on 10/23/16.
//  Copyright © 2016 William Youngs. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class EditLocationViewController: UIViewController {
    //The Alarm to be returned to the root ViewController
    var alarm: LocationAlarm!
    
    //Delegate for the Root VC
    public var delegate: EditLocationAlarmDelegate!
    
    // Setter method
    func giveAlarmToEdit(alarm:LocationAlarm) {
        self.alarm = alarm
    }
    
    //ScreenSizeStuff
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    // Global Vars for CLLocationManager and stuff
    var cl:CLLocationManager?
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    //UI Variables
    var mapView: MKMapView!
    var currDistToDestination:UILabel!
    var editDistButton:UIButton!
    var deactivateAlarm:UIButton!
    var s:UISlider!
    var l :UILabel!
    var b : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        // Setting up Map Frame
        mapView = MKMapView(frame:CGRect(x: 0, y: screenHeight/10, width:screenWidth,height: screenHeight))
        self.view.addSubview(mapView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteAlarm))
        
        // Finding location
        cl = CLLocationManager()
        cl?.requestWhenInUseAuthorization()
        cl?.allowsBackgroundLocationUpdates = true
        mapView.showsUserLocation = true
        //Zooms in to users location by default at first
        mapView.userTrackingMode  = MKUserTrackingMode.follow
        //
        
        self.view.addSubview(mapView)
        
        currDistToDestination = UILabel()
        currDistToDestination.frame = CGRect(x:screenWidth/10, y:screenHeight/10, width: screenWidth*(4.0/5.0), height:screenHeight/5)
        currDistToDestination.numberOfLines = 2
        currDistToDestination.text = "\(alarm.alarmTitle!)\nAlarm Distance:\(alarm.thresholdDist!)"
        currDistToDestination.backgroundColor = UIColor.gray
        currDistToDestination.textColor = UIColor.white
        currDistToDestination.adjustsFontSizeToFitWidth = true
        currDistToDestination.adjustsFontForContentSizeCategory = true
        currDistToDestination.textAlignment = NSTextAlignment.center
        currDistToDestination.center = CGPoint(x:screenWidth/2.0, y:screenHeight/5.0)
        
        self.view.addSubview(currDistToDestination)
        
        editDistButton = UIButton()
        editDistButton.setTitle("Set New Distance", for: .normal)
        editDistButton.backgroundColor = UIColor.red
        editDistButton.frame = CGRect(x:screenWidth/10.0, y:screenHeight*(8.0/9.0), width:screenWidth*(4.0/5.0), height: screenHeight/10.0)
        editDistButton.addTarget(self, action: "setNewAlarmDist", for: UIControlEvents.touchUpInside)
        self.view.addSubview(editDistButton)
        
    }
    func setNewAlarmDist () {
        self.editDistButton.removeFromSuperview()
        self.currDistToDestination.removeFromSuperview()
        
        //Slider placed
        self.s = UISlider()
        self.s.isContinuous  = true
        self.s.minimumValue = 0.5
        self.s.maximumValue = 100
        self.s.frame = CGRect(x:self.screenWidth/10,y:self.screenHeight - self.screenHeight/10,width:self.screenWidth*(0.8),height:self.screenHeight/10)
        self.s.addTarget(self, action: "updateSliderValue", for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.s)
        
        // Distance Label placed
        self.l = UILabel()
        self.l.frame = CGRect(x:self.screenWidth/4,y:self.screenHeight/10,width:self.screenWidth/2,height:self.screenHeight/10)
        self.l.text = String(self.s.value)
        self.l.backgroundColor = UIColor.gray
        self.l.font = self.l.font.withSize(40.0)
        self.view.addSubview(self.l)
        
        //Select Distance button placed
        self.b = UIButton()
        self.b.setTitle("Set Alarm Distance", for: .normal)
        self.b.setTitleColor(UIColor.white, for: .normal)
        self.b.backgroundColor = UIColor.lightGray
        self.b.addTarget(self, action: "selectDistance", for: UIControlEvents.touchUpInside)
        self.b.frame = CGRect(x:self.screenWidth/10,y:self.screenHeight/1.4,width: self.screenWidth*4.0/5.0, height:self.screenHeight/10)
        self.view.addSubview(self.b)
        
        
    }
    // Selects new distance
    func selectDistance() {
        alarm.thresholdDist = s.value
        navigationController?.popViewController(animated: true)
    }
    
    // Called by slider, TODO::inclde animation, shitty UI Right now
    func updateSliderValue() {
        l.text = String(s.value)
    }
    
    func deleteAlarm() {
        delegate.replaceOriginalLocationAlarm(Alarm: alarm)
        navigationController?.popViewController(animated: true)
    }
}

