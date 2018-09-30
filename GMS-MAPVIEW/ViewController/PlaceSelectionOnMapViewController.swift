//
//  PlaceSelectionOnMapViewController.swift
//  GMS-MAPVIEW
//
//  Created by MAC-4 on 10/25/17.
//  Copyright © 2017 Prismetric-MD2. All rights reserved.
//

import UIKit
import GoogleMaps

enum viewIdentifier {
    case menu
    case souceLocation
    case destinationLocation
}

protocol SelectedLocationDelegate {
    func didSelectedLocation(identifier:viewIdentifier, selectedPlace:Place)
}

class PlaceSelectionOnMapViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var lblGooglePlace: UILabel!
    
    @IBOutlet var lblApplePlace: UILabel!
    
    @IBOutlet var btnDone: UIButton!
    
    var delegate:SelectedLocationDelegate!
    
    var comeFrom:viewIdentifier = viewIdentifier.menu
    
    var applePlace:Place!
    
    var googlePlace: Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadUI()

    }

    //MARK:- loadUI()
    func loadUI() {
        if comeFrom == .menu {
            btnDone.isHidden = true
        }
        
        if LocationManager.shared.currentLocation != nil {
            let coordinate = LocationManager.shared.currentLocation?.coordinate
            
            mapView.animate(to: GMSCameraPosition(target: coordinate!, zoom: 12.0, bearing: 0, viewingAngle: 0))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back_clicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done_clicked(_ sender: UIButton) {
        if googlePlace == nil {
            debugPrint("Something went wrong place try again")
        }
        else {
            delegate?.didSelectedLocation(identifier: comeFrom, selectedPlace: googlePlace)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension PlaceSelectionOnMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        print(position.bearing)
        let coordinate = mapView.projection.coordinate(for: mapView.center)
        
        LocationManager.shared.getPlaceFromApple(lat: coordinate.latitude, lng: coordinate.longitude) { (place) in
            self.applePlace = place
            self.lblApplePlace.text = place.address
        }
        
        LocationManager.shared.getPlaceFromGoogle(lat: coordinate.latitude, lng: coordinate.longitude) { (place) in
            self.googlePlace = place
            self.lblGooglePlace.text = place.address
        }
        
    
    }
}
