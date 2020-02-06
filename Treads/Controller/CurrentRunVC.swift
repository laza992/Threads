//
//  CurrentRunVC.swift
//  Treads
//
//  Created by developer on 09.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class CurrentRunVC: LocationVC {

    // Outlets
    @IBOutlet weak var swipeBGImageView: UIImageView!
    @IBOutlet weak var sliderImageView: UIImageView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var pauseBtn: UIButton!
    
    fileprivate var startLocation: CLLocation!
    fileprivate var lastLocation: CLLocation!
    fileprivate var timer = Timer()
    fileprivate var coordinatelocations = List<Location>()
    
    fileprivate var runDistance = 0.0
    fileprivate var pace = 0
    fileprivate var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(endRunSwiped(sender:)))
        sliderImageView.addGestureRecognizer(swipeGesture)
        sliderImageView.isUserInteractionEnabled = true
        swipeGesture.delegate = self as? UIGestureRecognizerDelegate
    }

    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        manager?.distanceFilter = 10
        startRun()
    }
    
    func startRun() {
        manager?.startUpdatingLocation()
        startTimer()
        let pauseButton = UIImage(named: "pauseButton")
        pauseBtn.setImage(pauseButton, for: .normal)
    }
    
    func endRun() {
        manager?.stopUpdatingLocation()
        // Add our object to Realm
        Run.addRunToRealm(pace: pace, distance: runDistance, duration: counter, locations: coordinatelocations)
    }
    
    func pauseRun() {
        startLocation = nil
        lastLocation = nil
        timer.invalidate()
        manager?.stopUpdatingLocation()
        let resumeButton = UIImage(named: "resumeButton.png")
        pauseBtn.setImage(resumeButton, for: .normal)
    }
    
    func startTimer() {
        durationLbl.text = counter.formatTimeDurationToString()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounter() {
        counter += 1
        durationLbl.text = counter.formatTimeDurationToString()
    }
    
    func calculatePace(time seconds: Int, km: Double) -> String {
        pace = Int(Double(seconds) / km)
        return pace.formatTimeDurationToString()
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        if timer.isValid{
            pauseRun()
        } else {
            startRun()
        }
    }
    
    @objc func endRunSwiped(sender: UIPanGestureRecognizer){
        let minAdjust: CGFloat = 80
        let maxAdjust: CGFloat = 127
        if let sliderView = sender.view {
            if sender.state == UIGestureRecognizer.State.began || sender.state == UIGestureRecognizer.State.changed {
                let translation = sender.translation(in: self.view)
                if sliderView.center.x >= (swipeBGImageView.center.x - minAdjust) && sliderView.center.x <= (swipeBGImageView.center.x + maxAdjust) {
                    sliderView.center.x = sliderView.center.x + translation.x
                } else if sliderView.center.x >= (swipeBGImageView.center.x + maxAdjust) {
                    sliderView.center.x = swipeBGImageView.center.x + maxAdjust
                    // End Run code goes here
                    endRun()
                    dismiss(animated: true, completion: nil)
                } else {
                    sliderView.center.x = swipeBGImageView.center.x - minAdjust
                }
                
                sender.setTranslation(CGPoint.zero, in: self.view)
            } else if sender.state == UIGestureRecognizer.State.ended {
                UIView.animate(withDuration: 0.1) {
                    sliderView.center.x = self.swipeBGImageView.center.x - minAdjust
                }
            }
        }
    }
}

extension CurrentRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            runDistance += lastLocation.distance(from: location)
            let newLocation = Location(latitude: Double(lastLocation.coordinate.latitude), longitude: Double(lastLocation.coordinate.longitude))
            coordinatelocations.insert(newLocation, at: 0)
            distanceLbl.text = "\(runDistance.meters(places: 2))"
            if counter > 0 && runDistance > 0 {
                paceLbl.text = calculatePace(time: counter, km: runDistance.meters(places: 2))
            }
        }
        lastLocation = locations.last
    }
}
