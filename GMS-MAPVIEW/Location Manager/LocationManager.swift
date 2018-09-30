//
//  LocationManager.swift
//  LocationManagerDemo
//
//  Created by MAC-4 on 8/21/17.
//  Copyright © 2017 Prismetric-MD2. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

let GOOGLE_API_KEY = "AIzaSyA7QhG0OK8mR2uNrKDASILeaHPres7JtPQ"

protocol LocationManagerDelegate: class  {
    
    func didUpdateLocation(location : CLLocation?, error:Error?)
    
    func locationAccessDenied(alert:UIAlertController)

    func didUpdateHeading(newHeading: CLHeading)
}

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    private var userLocationManager = CLLocationManager()

    var currentLocation : CLLocation?

    var delegate : LocationManagerDelegate?

    var geoCoder = GMSGeocoder()
    
    private override init () {
        super.init()
        if checkLocationAccess() {
            self.userLocationManager.delegate = self
            self.userLocationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.userLocationManager.distanceFilter = kCLLocationAccuracyHundredMeters
            userLocationManager.requestAlwaysAuthorization()
            self.userLocationManager.startUpdatingLocation()
        }
        else {
            self.userLocationManager.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.callLocationAlertDelegate()
            })
        }
        
    }

    func checkLocationAccess() ->  Bool      {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .denied,.restricted:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            case .notDetermined:
                return true
            }
        }
        return false
    }
    
    func callLocationAlertDelegate() {
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "location access requires to start driving please open this app's settings and set location access to 'Always'.",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: { (finish) in
                        
                    })
                }
                else {
                    UIApplication.shared.openURL(url as  URL)
                }
            }
        }
        alertController.addAction(openAction)
        
        delegate?.locationAccessDenied(alert: alertController)
    }
    
}


//MARK:- Location Manager Delegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.currentLocation = locations.last
            self.delegate?.didUpdateLocation(location: locations.last, error: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        delegate?.didUpdateHeading(newHeading: newHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.delegate?.didUpdateLocation(location: nil, error: error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            callLocationAlertDelegate()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        }
    }
}


extension LocationManager {
    
    //MARK:- GET PLACE FROM GOOGLE
    func getPlaceFromGoogle(lat:Double, lng:Double, callback:@escaping (_:Place) -> Void) {
    
        geoCoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: lng)) { (response, error) in
            if error == nil {
                let place = Place()
                place.name = response?.firstResult()?.thoroughfare ?? ""
                place.streetName = ""
                place.city = response?.firstResult()?.locality ?? ""
                place.state = response?.firstResult()?.administrativeArea ?? ""
                place.country = response?.firstResult()?.country ?? ""
                place.zipCode = response?.firstResult()?.postalCode ?? ""
                place.lat = lat
                place.lng = lng
                place.address = Place.getAddressStringFromPlace(place: place)
                callback(place)
            }
            else {
                let place = Place()
                place.lat = lat
                place.lng = lng
                callback(place)
            }
        }
        
    }
    
    //MARK:- GET PLACE FROM APPLE
    func getPlaceFromApple(lat:Double, lng:Double, callback:@escaping (_:Place) -> Void) {
        
        let location = CLLocation(latitude: lat, longitude: lng)
        print(location)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            var place:Place!
            if error == nil {
                if (placemarks?.count ?? 0) > 0 {
                    if (placemarks?[0]) != nil {
                        place = Place()
                        place.name = placemarks?[0].name ?? ""
                        place.streetName = ""
                        place.city = placemarks?[0].locality ?? ""
                        place.state = placemarks?[0].administrativeArea ?? ""
                        place.country = placemarks?[0].country ?? ""
                        place.zipCode = placemarks?[0].postalCode ?? ""
                        place.lat = lat
                        place.lng = lng
                        place.address = Place.getAddressStringFromPlace(place: place)
                        callback(place)
                    }
                }
            }
            
            if place == nil {
                place = Place()
                place.lat = lat
                place.lng = lng
                callback(place)
            }
        })
    }
}

class Place {
    var id: String = ""
    var name:String = ""
    var streetName:String = ""
    var city:String = ""
    var state:String = ""
    var country:String = ""
    var zipCode:String = ""
    var lat:Double = 0.0
    var lng:Double = 0.0
    var address:String = ""
    
    class func getAddressStringFromPlace(place:Place) -> String {
        
        var address = ""
        
        if place.name != "" {
            address += place.name + ","
        }
        
        if place.streetName != "" {
            address += " " + place.streetName + ","
        }
        
        if place.city != "" {
            address += " " + place.city + ","
        }
        
        if place.state != "" {
            address += " " + place.state + ","
        }
        
        if place.country != "" {
            address += " " + place.country + ","
        }
        
        if place.zipCode != "" {
            address += " " + place.zipCode
        }
        
        if address.last == "," {
            address = address.substring(to: address.index(before: address.endIndex))
        }
        
        return address
    }
}

