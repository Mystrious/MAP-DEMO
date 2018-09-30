//
//  CustomWindwViewController.swift
//  GMS-MAPVIEW
//
//  Created by MAC-4 on 6/12/18.
//  Copyright © 2018 Prismetric-MD2. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class CustomWindwViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView!
    
    lazy var marker: GMSMarker = {
        let marker = GMSMarker()
        return marker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        marker.map = mapView
    
        if LocationManager.shared.currentLocation != nil {
            let coordinate = LocationManager.shared.currentLocation?.coordinate
            marker.position = coordinate!
            marker.infoWindowAnchor = CGPoint(x: 0, y: -0.5)
            mapView.animate(to: GMSCameraPosition(target: coordinate!, zoom: 12.0, bearing: 0, viewingAngle: 0))
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //MARK:- IBAction
    @IBAction func back_clicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CustomWindwViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let nib = Bundle.main.loadNibNamed("MarkerWindow", owner: self, options: nil)![0]
        if let view = nib as? MarkerWindow {
            view.lblTitle.text = "This is custom info window"
            view.lblDesc.text = "You can create custom info window as per your requirement"
            view.subView.layoutIfNeeded()
            
            var rect = view.frame
            rect.size = CGSize(width: 300, height: view.subView.bounds.height)
            view.frame = rect
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("infowindow tap")
    }
}

