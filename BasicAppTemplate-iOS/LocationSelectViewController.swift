//
//  LocationSelectViewController.swift
//  Shakawekom
//
//  Created by AhmeDroid on 4/11/17.
//  Copyright © 2017 Imagine Technologies. All rights reserved.
//

import UIKit
import GoogleMaps
import MaterialComponents
import CoreLocation

protocol LocationSelectViewControllerDelegate {
    func locationSelectDidReceiveAddress(_ address:String, atCoordinates coordinates:CLLocationCoordinate2D ) -> Void
}

class LocationSelectViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    static func launch( delegate:LocationSelectViewControllerDelegate? ) -> Void {
        
        if let viewC = UIApplication.topViewController(),
            let locationVC = viewC.storyboard?.instantiateViewController(withIdentifier: "locationSelectVC") as? LocationSelectViewController {
            
            locationVC.delegate = delegate
            viewC.present(locationVC, animated: true, completion: {_ in})
        } else {
            
            print("Can't launch date picker on non-UIViewController objects")
        }
    }
    
    let geocoder = GMSGeocoder()
    var delegate:LocationSelectViewControllerDelegate?
    
    @IBOutlet weak var selectionButton: UIButton!
    @IBAction func selectAddress(_ sender: Any) {
        
        let alert = UIAlertController(title: "location-select-title".local,
                                      message: String(format: "location-select-confirm".local, self.selectedAddress),
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "no".local, style: .cancel, handler: {_ in})
        let okayAction = UIAlertAction(title: "yes".local, style: .default) { (action) in
            
            self.dismiss(animated: true) {
                self.delegate?.locationSelectDidReceiveAddress(self.selectedAddress, atCoordinates: self.selectedLocation)
            }
        }
        
        alert.addAction(okayAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: {_ in})
    }
    
    @IBAction func showUserLocation(_ sender: Any) {
        
        self.lookForUserLocation()
    }
    
    private var indicator:MDCActivityIndicator!
    private var indicatorContainer:UIView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let w = self.view.frame.width
        let view = UIView(frame: CGRect(x: (w - 36) * 0.5, y: 25, width: 40, height: 40))
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor.white
        
        indicator = MDCActivityIndicator(frame: CGRect(x: 4, y: 4, width: 32, height: 32))
        view.addSubview(indicator)
        
        indicatorContainer = view
        selectionButton.isHidden = true
    }
    
    func showLoadingIndicator() -> Void {
        self.view.addSubview(indicatorContainer)
        indicator.startAnimating()
    }
    
    func hideLoadingIndicator() -> Void {
        indicatorContainer.removeFromSuperview()
        indicator.stopAnimating()
    }
    
    private var selectedAddress:String!
    private var selectedLocation:CLLocationCoordinate2D!
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.mapView.selectedMarker = nil
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        self.mainMarker.position = position.target
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        self.mainMarker.map = nil
        self.mainMarker.position = position.target
        self.mainMarker.map = mapView
        self.lookupForAddress(atCoordinate: position.target)
    }
    
    func lookupForAddress(atCoordinate coordinate:CLLocationCoordinate2D) -> Void {
        
        self.showLoadingIndicator()
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            
            self.hideLoadingIndicator()
            if error != nil {
                print("Error while reverse geocoding: \(error!.localizedDescription)")
                self.mainMarker.title = "Unknown"
                return
            }
            
            if let result = response?.firstResult() {
                
                self.selectedLocation = coordinate
                
                var fullAddress = "Unknown"
                if let lines = result.lines {
                    fullAddress = lines.joined(separator: ", ");
                }
                
                self.selectedAddress = fullAddress
                self.selectionButton.isHidden = false
                
                print("location reverse geocoded ...")
                
                self.mainMarker.title = result.lines?[0]
                self.mainMarker.snippet = result.lines?[1]
                self.mapView.selectedMarker = self.mainMarker
            }
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {_ in})
    }
    
    private var locationManager = CLLocationManager()
    private var mapView:GMSMapView!
    override func loadView() {
        super.loadView()
        
        let location  = CLLocationCoordinate2D(latitude: 31.9499895, longitude: 35.9394769)
        let camera = GMSCameraPosition.camera(
            withLatitude: location.latitude,
            longitude: location.longitude,
            zoom: 16.0)
        
        self.mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.mapView.isMyLocationEnabled = true
        self.mapView.isIndoorEnabled = true
        self.mapView.delegate = self
        self.mapView.setMinZoom(4, maxZoom: 18)
        
        self.view.insertSubview(self.mapView, at: 0)
        
        let marker = GMSMarker()
        marker.position = location
        marker.title = "Loading ..."
        marker.map = self.mapView
        marker.isDraggable = false
        marker.isTappable = false
        
        self.mainMarker = marker
        self.lookForUserLocation()
    }
    
    var mainMarker:GMSMarker!
    func lookForUserLocation() -> Void {
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
        
            let camera = GMSCameraPosition.camera(
                withLatitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                zoom: 16)
            
            self.mapView.animate(to: camera)
            self.lookupForAddress(atCoordinate: location.coordinate)
        }
        
        self.locationManager.stopUpdatingLocation()
    }
    
    @IBAction func zoomInMap(_ sender: Any) {
        
        let pzoom = self.mapView.camera.zoom
        let zoom = min(18, pzoom + 2)
        self.mapView.animate(toZoom: zoom)
    }
    
    @IBAction func zoomOutMap(_ sender: Any) {
        
        let pzoom = self.mapView.camera.zoom
        let zoom = max(4, pzoom - 2)
        self.mapView.animate(toZoom: zoom)
    }
}

