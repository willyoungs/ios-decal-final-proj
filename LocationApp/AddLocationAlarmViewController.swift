//
//  AddLocationAlarmViewController.swift
//  mapLocationProgramatic
//
//  Created by William Youngs on 10/6/16.
//  Copyright © 2016 William Youngs. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddLocationAlarmViewController: UIViewController, UISearchBarDelegate {
    // Delegate set to AddAlarmViewController
    var delegate : AddLocationAlarmDelegate!
    
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
    
    // Basic UI
    var mapView: MKMapView!
    var l :UILabel!
    var s :UISlider!
    var b : UIButton!
    var alarmDist : Float!
    //hmm is this used vvvvvvvvvvvv
    @IBOutlet var text :UITextField!
    
    //ScreenSizeStuff
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    // New Loc Alarm
    var newAlarm : LocationAlarm!
    var alarmTitle: String!
    
    // Setter Method for Alarm Title
    func addLocationAlarmTitle(title:String) {
        alarmTitle = title
    }
    
    // Action called by Add Destination
    @IBAction func showSearchBar(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    // Called by slider, TODO::inclde animation, shitty UI Right now
    func updateSliderValue() {
        l.text = String(s.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        // Setting up Map Frame
        mapView = MKMapView(frame:CGRect(x: 0, y: screenHeight/10, width:screenWidth,height: screenHeight))
        self.view.addSubview(mapView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Destination", style: .plain, target: self, action: #selector(showSearchBar))
        
        // Finding location
        cl = CLLocationManager()
        cl?.requestWhenInUseAuthorization()
        cl?.allowsBackgroundLocationUpdates = true
        mapView.showsUserLocation = true
        //Zooms in to users location by default at first
        mapView.userTrackingMode  = MKUserTrackingMode.follow
        //
        
    }
    
    // This Function is still a little magic to me, but it makes sense: The comments on the tutorial I ripped a lot of this from is below:
    ////1: Once you click the keyboard search button, the app will dismiss the presented search controller you were presenting over the navigation bar. Then, the map view will look for any previously drawn annotation on the map and remove it since it will no longer be needed.
    
    //2: After that, the search process will be initiated asynchronously by transforming the search bar text into a natural language query, the ‘naturalLanguageQuery’ is very important in order to look up for -even an incomplete- addresses and POI (point of interests) like restaurants, Coffeehouse, etc.
    
    //3 Mainly, If the search API returns a valid coordinates for the place, then the app will instantiate a 2D point and draw it on the map within a pin annotation view. That’s what this part performs
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            
            // Places pin at searched location and centers view around it.
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            
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
            
            // Declaring Alarm and setting fields...
            self.newAlarm = LocationAlarm()
            self.newAlarm.setAlarmDestinationString(destString: searchBar.text!)
            
        }
    }
    
    //Function called when select distance button pushed
    func selectDistance(){
        // Global Alarm values set, is chill for multiple loc alarms?
        self.alarmDist = s.value
        self.newAlarm.alarmTitle = alarmTitle
        self.newAlarm.setDestinationLocation(destLoc: self.pointAnnotation.coordinate)
        self.newAlarm.setThresholdDistance(thresholdDistance: s.value)
        delegate.addLocationAlarmToAlarmList(Alarm: self.newAlarm)
        self.newAlarm = nil
        
        // removing everything to clean view
        self.b.removeFromSuperview()
        self.s.removeFromSuperview()
        self.l.removeFromSuperview()
        
        // Pops off navcontrollerback to root VC
        startAlarmTracking()
    }
    
    func startAlarmTracking() {
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    //Not used here but basic logic behind alarm... good to think about
    func isWithinAlarmDistance(dist : Float) -> Bool {
        let me = MKMapPointForCoordinate((cl?.location?.coordinate)!)
        let coor = self.pointAnnotation.coordinate
        let dest = MKMapPointForCoordinate(coor)
        let distance: CLLocationDistance = MKMetersBetweenMapPoints(me, dest)
        let distInMiles = Float(distance)*0.000621371
        if distInMiles < dist{
            print("BEEP BEEP BEEP BUZZ BUZZ BUZZ, you are \(distInMiles) miles away!!")
        } else{
            print("Rest easy, you are still \(distInMiles) miles away")
        }
        return distInMiles < dist
    }
}

