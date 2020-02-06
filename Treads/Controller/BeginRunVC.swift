//
//  BeginRunVC.swift
//  Treads
//
//  Created by developer on 09.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class BeginRunVC: LocationVC {

    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lastRunClosedBtn: UIButton!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var lastRunBGView: UIView!
    @IBOutlet weak var lastRunStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        mapView.delegate = self
        manager?.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        manager?.stopUpdatingLocation()
    }

    func setupMapView() {
        if let overlay = addLastRunToMap() {
            if mapView.overlays.count > 0 {
                mapView.removeOverlays(mapView.overlays)
            }
            mapView.addOverlay(overlay)
            lastRunStack.isHidden = false
            lastRunBGView.isHidden = false
            lastRunClosedBtn.isHidden = false
        } else {
            lastRunStack.isHidden = true
            lastRunBGView.isHidden = true
            lastRunClosedBtn.isHidden = true
            centerMapOnUserLocation()
        }
    }
    
    func addLastRunToMap() -> MKPolyline? {
        guard let lastRun = Run.getAllRuns()?.first else {
            return nil
        }
        paceLbl.text = lastRun.pace.formatTimeDurationToString()
        distanceLbl.text = "\(lastRun.distance.meters(places: 2)) km"
        durationLbl.text = lastRun.duration.formatTimeDurationToString()
        
        var coordinate = [CLLocationCoordinate2D]()
        for location in lastRun.locations {
            coordinate.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        
        mapView.userTrackingMode = .none
        mapView.setRegion(centerMapOnPrevRoute(locations: lastRun.locations), animated: true)
        
        return MKPolyline(coordinates: coordinate, count: lastRun.locations.count)
    }
    
    func centerMapOnUserLocation() {
        mapView.userTrackingMode = .follow
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnPrevRoute(locations: List<Location>) -> MKCoordinateRegion {
        guard let initialLoc = locations.first else {
            return MKCoordinateRegion()
        }
        var minLatitude = initialLoc.latitude
        var minLongitude = initialLoc.longitude
        var maxLatitude = minLatitude
        var maxLongitude = minLongitude

        for location in locations {
            minLatitude = min(minLatitude, location.latitude)
            minLongitude = min(minLongitude, location.longitude)
            maxLatitude = max(maxLatitude, location.latitude)
            maxLongitude = max(maxLongitude, location.longitude)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude)/2, longitude: (minLongitude + maxLongitude)/2), span: MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude)*1.4, longitudeDelta: (maxLongitude - minLongitude)*1.4))
    }
    
    @IBAction func locationCenterBtnPressed(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
    @IBAction func lastRunCloseBtnPressed(_ sender: Any) {
        lastRunStack.isHidden = true
        lastRunBGView.isHidden = true
        lastRunClosedBtn.isHidden = true
        centerMapOnUserLocation()
    }
}

extension BeginRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
            mapView.showsUserLocation = true
        }
    }
    // set Polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.strokeColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        renderer.lineWidth = 4
        return renderer
    }
}
