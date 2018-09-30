//
//  MappinAnimationViewController.swift
//  GMS-MAPVIEW
//
//  Created by MAC-4 on 11/2/17.
//  Copyright © 2017 Prismetric-MD2. All rights reserved.
//

import UIKit
import GoogleMaps

class MappinAnimationViewController: UIViewController {

    var lastUserBearing:Double!
    
    var lastMapBearing:Double!
    
    @IBOutlet var mapView: GMSMapView!
    
    lazy var marker: GMSMarker = {
        let marker = GMSMarker()
        marker.icon = #imageLiteral(resourceName: "ic_car")
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        return marker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- loadUI
    func loadUI() {
        LocationManager.shared.delegate = self
        
        marker.map = mapView
        
        if LocationManager.shared.currentLocation != nil {
            let coordinate = LocationManager.shared.currentLocation?.coordinate
            marker.position = coordinate!
            mapView.animate(to: GMSCameraPosition(target: coordinate!, zoom: 12.0, bearing: 0, viewingAngle: 0))
        }
    }
    
    //MARK:- IBAction
    @IBAction func back_clicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension MappinAnimationViewController: LocationManagerDelegate {
    func didUpdateLocation(location: CLLocation?, error: Error?) {
        if error == nil && location != nil {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)
            marker.position = location!.coordinate
            CATransaction.commit()
        }
    }
    
    func locationAccessDenied(alert: UIAlertController) {
        
    }
    
    func didUpdateHeading(newHeading: CLHeading) {
        lastUserBearing = newHeading.trueHeading
        marker.rotation = lastUserBearing! - (lastMapBearing ?? 0)
    }
}

extension MappinAnimationViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        lastMapBearing = position.bearing
        marker.rotation = (lastUserBearing ?? 0) - lastMapBearing!
    }
}
