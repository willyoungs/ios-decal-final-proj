//
//  ViewController.swift
//  SleepE
//
//  Created by William Youngs on 9/8/16.
//  Copyright © 2016 William Youngs. All rights reserved.
//
import MapKit
import UIKit
import CoreBluetooth
import AudioToolbox


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddAlarmListDelegate,CLLocationManagerDelegate,EditLocationAlarmDelegate {
    
    // Screen Size Variables
    var screenSize: CGRect!
    var screenWidth : CGFloat!
    var screenHeight : CGFloat!
    
    //Core Bluetooth Variables
    var myBTManager: CBCentralManager!
    var mySleepe: CBPeripheral!
    var vibrateService: CBService!
    var vibrateCharacteristic: CBCharacteristic!
    
    var vibrateOn: Bool = false
    
    //General SubView Items
    var button = UIButton(type: .custom)
    var titleBox :UILabel?
    var formatter = DateFormatter()
    var alarmList = UITableView()
    var vibrateButton:UIButton!
    
    
    //Alarms Lists
    var Alarms: [Alarm] = []
    var locAlarms: [LocationAlarm] = []
    var i: Int!//Row Index
    
    
    //Location Manager Which Controls literally ALL background behavior... not sure if this is the way to go on this...
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()
    
    //Variables for testing if alarms working
    var success:UILabel!
    var backgroundSuccess:UILabel!
    
    
    //Function called by background fetch to power functionality of time based alarm
    var time: NSDate?
    func fetch(completion: () -> Void) {
        time = NSDate()
        completion()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Tells Location Manater to start updating location
        self.locationManager.startUpdatingLocation()
        
        // Define Screen Size params
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        // Set up for Clock
        formatter.timeStyle = .short
        let titleBoxHeight = screenHeight/3.5
        titleBox = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: titleBoxHeight))
        titleBox!.backgroundColor = UIColor.cyan
        titleBox!.center = CGPoint(x: screenWidth/2, y: screenHeight/5)
        titleBox!.text = formatter.string(from: Date())
        titleBox!.font = titleBox!.font.withSize(80)
        titleBox!.textAlignment = NSTextAlignment.center
        titleBox!.textColor = UIColor.black
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateTime), userInfo: nil, repeats: true)
        self.view.addSubview(titleBox!)
        
        // Set up for "set alarm" button
        let buttonSize = screenHeight/5
        button.frame = CGRect(x: 0, y: titleBoxHeight, width: screenWidth, height: buttonSize/2)
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(ViewController.createAlarm), for: .touchUpInside)
        button.setTitle("Create New Alarm", for: UIControlState())
        
        // SET "VIBRATE" BUTTON
        vibrateButton = UIButton(type: .custom)
        vibrateButton.frame = CGRect(x: 0, y: titleBoxHeight + buttonSize/2 , width: screenWidth, height: buttonSize/2)
        vibrateButton.backgroundColor = UIColor.blue
        vibrateButton.addTarget(self, action: #selector(ViewController.sendBTSignal(_:)), for: .touchUpInside)
        vibrateButton.setTitle("Vibrate", for: UIControlState())
        
        
        // Border between button and list set up
        let border = CALayer()
        let width = CGFloat(3.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: 0 , width:  vibrateButton.frame.size.width, height: vibrateButton.frame.size.height)
        border.borderWidth = width
        vibrateButton.layer.addSublayer(border)
        button.layer.masksToBounds = true
        
        // List View set up
        alarmList.frame = CGRect(x: 0, y: titleBoxHeight + buttonSize/2, width: screenWidth, height: screenHeight - (titleBoxHeight))
        alarmList.delegate = self
        alarmList.dataSource = self
        alarmList.rowHeight = screenHeight/7
        alarmList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(alarmList)
        self.view.addSubview(button)
        
        
    }
    
    // Called to update Clock on root ViewController
    func updateTime(){
        let now = Date()
        titleBox!.text = formatter.string(from: now)
    }
    
    // Adds Alarm to appropriate alarm list, eiter locAlarms or timeAlarms
    func addToAlarmList(Alarm : Alarm){
        if (Alarm.getName() == "LocationAlarm") {
            locAlarms.append(Alarm as! LocationAlarm)
            Alarms.append(Alarm)
        }
        alarmList.reloadData()
        
    }
    
    // Function tells TableView how many rows to fill
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locAlarms.count
    }
    
    // Function called when create alarm clicked
    public func createAlarm(){
        let x = AddAlarmViewController()
        x.delegate = self
        self.navigationController?.pushViewController(x, animated: true)
    }
    
    // Function called to edit a location alarm in the Alarms array
    public func editLocationAlarm(alarm:LocationAlarm){
        let editLoc = EditLocationViewController()
        editLoc.giveAlarmToEdit(alarm: alarm)
        editLoc.delegate = self
        self.navigationController?.pushViewController(editLoc, animated: true)
        
    }
    
    // This function is held together with ductape, TODO: switch destination string to hashcode
    public func replaceOriginalLocationAlarm(Alarm:LocationAlarm){
        Alarms.remove(at: i)
        for (i,a) in locAlarms.enumerated(){
            if a.destinationString == Alarm.destinationString {
                locAlarms.remove(at: i)
            }
        }
        alarmList.reloadData()
    }
    
    
    // TableViews way of assigning Alarms to rows in the TableView
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = self.Alarms[indexPath.row].getTitle()
        cell.textLabel?.textAlignment = NSTextAlignment.center
        return cell
    }
    
    // What happens when a row is selected, Probably add code here to implement Alarm editing
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        i = indexPath.row
        let alarmToEdit = self.Alarms[indexPath.row]
        if alarmToEdit.getName() == "LocationAlarm" {
            editLocationAlarm(alarm: alarmToEdit as! LocationAlarm)
        }
        
        print("You selected cell #\(indexPath.row)!")
    }
    
    // From initialized project, maybe delete
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Core Bluetooth Manager, will have to modify and expand from here to allow one app to synch with one device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered ", peripheral)
        mySleepe = peripheral
        let string = "F6AB0F41-65B6-477B-939E-9F37F9EACD74"
        if peripheral.identifier == UUID.init(uuidString: string){
            myBTManager.connect(peripheral, options: nil)
            myBTManager.stopScan()
        }
    }
    
    
    // Blew Toof
    @IBAction func sendBTSignal(_ sender: UIButton) {
        // Write value for BT receiver
        if (mySleepe != nil && vibrateCharacteristic != nil && vibrateService != nil) {
            if vibrateOn {
                vibrateOn = false
                let bytes : [UInt8] = [0x00]
                let data = Data(bytes:bytes)
                print("data: ", data)
                mySleepe.writeValue(data, for: vibrateCharacteristic, type: CBCharacteristicWriteType.withResponse)
            } else if !vibrateOn {
                vibrateOn = true
                let bytes : [UInt8] = [0x01]
                let data = Data(bytes:bytes)
                print("dataOut: ", data)
                mySleepe.writeValue(data, for: vibrateCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        } else {
            let alert = UIAlertController(title: "SleepE Disconnected", message: "Connect your device to your SleepE", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            //alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            //     switch action.style{
            //    case .default:
            //        print("default")
            //
            //    case .cancel:
            //         print("cancel")
            //
            //    case .destructive:
            //         print("destructive")
            //     }
            // }))
        }
    }
    
    func sendBTSignalNoSender() {
        if (mySleepe != nil && vibrateCharacteristic != nil && vibrateService != nil) {
            if vibrateOn {
                vibrateOn = false
                let bytes : [UInt8] = [0x00]
                let data = Data(bytes:bytes)
                print("data: ", data)
                mySleepe.writeValue(data, for: vibrateCharacteristic, type: CBCharacteristicWriteType.withResponse)
            } else if !vibrateOn {
                vibrateOn = true
                let bytes : [UInt8] = [0x01]
                let data = Data(bytes:bytes)
                print("dataOut: ", data)
                mySleepe.writeValue(data, for: vibrateCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        } else {
            let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    // CBCentralManagerDelegate Methods
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        print("CentralManager is initialized")
        switch central.state{
        case .unknown:
            print("The app is not authorized to use Bluetooth low energy.")
        case .poweredOff:
            print("Bluetooth is currently powered off.")
        case .poweredOn:
            print("Bluetooth is currently powered on and available to use.", myBTManager)
            myBTManager.scanForPeripherals(withServices: nil, options: nil)
        default:break
        }
    }
    
    // CB Scanning for perphs... Alex??
    func scanPeripherals() {
        print("my manager in scan ", myBTManager)
        myBTManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
    //----------------------------------DELETE THIS COMMENT WHEN WE  SUBMIT TO APP STORE---------------------------------------------
    // So this function is explicitly processing all of our background activity,
    //completely legal for our location alarms, not sure about our TimeAlarms but we'll cross that bridge if need be
    //
    //Basically when the locationmanager updates location it uses this function to do so. Since we have enabled background location updates in
    //the location manager and in the plist this gets called even in the background. The only issue here is that some functions dont appear to be
    //fully processed when in the background. Print statements are fine, but we really need to check that we can send CoreBluetooth a signal from
    //the background. If not then we have some stuff to figure out (ex. implementing some shitty audio functionality to exploit that background
    //activity use case or maybe background fetch)
    
    func locationManager(_ manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if UIApplication.shared.applicationState == .active {
            // FOREGROUND MODE
            for alarm:Alarm in Alarms {
                print("In Foreground")
                if(alarm.getName()=="LocationAlarm") { // Location alarm in foreground
                    var alarm = alarm as? LocationAlarm
                    let currLocPoint = MKMapPointForCoordinate((locationManager.location?.coordinate)!)
                    print(currLocPoint)
                    let destLocPoint = MKMapPointForCoordinate((alarm?.destinationLocation)!)
                    print(destLocPoint)
                    let distance: CLLocationDistance = MKMetersBetweenMapPoints(currLocPoint, destLocPoint)
                    let distInMiles = Float(distance)*0.000621371
                    if (distInMiles < (alarm?.thresholdDist)!){
                        print("Bluetooth Alarm Active! Current Distance From target is \(distInMiles)")
                        self.sendBTSignalNoSender()
                        // TODO: UPDATE ALARM VALS
                    } else {
                        print ("Still \(distInMiles) away....")
                    }
                }
            }
        } else {
            // BACKGROUND MODES
            for alarm:Alarm in Alarms {
                print("In Background")
                if (alarm.getName() == "LocationAlarm"){
                    var alarm = alarm as? LocationAlarm
                    let currLocPoint = MKMapPointForCoordinate((locationManager.location?.coordinate)!)
                    print(currLocPoint)
                    let destLocPoint = MKMapPointForCoordinate((alarm?.destinationLocation)!)
                    print(destLocPoint)
                    let distance: CLLocationDistance = MKMetersBetweenMapPoints(currLocPoint, destLocPoint)
                    let distInMiles = Float(distance) * 0.000621371
                    if (distInMiles < (alarm?.thresholdDist)!){
                        print("Bluetooth Alarm Active! Current Distance From target is \(distInMiles)")
                        self.sendBTSignalNoSender()
                        backgroundSuccess.isHidden = false
                        self.sendBTSignalNoSender()
                    } else {
                        print("Still \(distInMiles) away....")
                        
                    }
                }
            }
        }
    }
    
}

