//
//  RouteViewController.swift
//  GMS-MAPVIEW
//
//  Created by MAC-4 on 11/2/17.
//  Copyright © 2017 Prismetric-MD2. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class RouteViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var txtSourceLocation: UITextField!
    
    @IBOutlet var txtDestinationLocation: UITextField!
    
    @IBOutlet var activity: UIActivityIndicatorView!
    
    var sourcePlace:Place!
    
    var destinationPlace:Place!
    
    var animatedPath = GMSMutablePath()
    
    var animationPolyline = GMSPolyline()
    
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func loadUI() {
        if LocationManager.shared.currentLocation != nil {
            let coordinate = LocationManager.shared.currentLocation?.coordinate
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
    
    @IBAction func done_clicked(_ sender: UIButton) {
        if sourcePlace == nil {
            
        }
        else if destinationPlace == nil {
            
        }
        else {
            
            let urlStr = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourcePlace.lat),\(sourcePlace.lng)&destination=\(destinationPlace.lat),\(destinationPlace.lng)&sensor=false&mode=driving&key=YOUR_API_KEY"
            
            activity.startAnimating()
            if let url = URL(string: urlStr) {
                let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                    DispatchQueue.main.async {
                        self.activity.stopAnimating()

                        if error == nil && data != nil {
                            do {
                                if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                                    
                                    guard let routes = json["routes"] as? NSArray else {
                                        DispatchQueue.main.async {
                                        }
                                        return
                                    }
                                    
                                    if (routes.count > 0) {
                                        
                                        let overview_polyline = routes[0] as? NSDictionary
                                        let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                                        
                                        let points = dictPolyline?.object(forKey: "points") as? String
                                        
                                        self.mapView.animate(to: GMSCameraPosition(target: CLLocationCoordinate2D(latitude: self.sourcePlace.lat, longitude: self.sourcePlace.lng), zoom: 17, bearing: 0, viewingAngle: 0))
                                        
                                        self.showPath(polyStr: points!)
                                        
                                    }
                                    else {
                                        print("Route not found")
                                    }
                                }
                            }
                            catch {
                                print("error in JSONSerialization")
                            }
                        }
                        else {
                            debugPrint("something went wrong please try again.")
                        }
                    }
                    
                })
                task.resume()
            }
            
        }
    }
    
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.strokeColor = UIColor.blue
        polyline.map = mapView // Your map
        
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (Timer) in
                self.animatePath(path: path!)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func animatePath(path :GMSPath) {
        DispatchQueue.main.async {
            if (self.i < path.count()) {
                self.animatedPath.add(path.coordinate(at: UInt(self.i)))
                self.animationPolyline.path = self.animatedPath
                self.animationPolyline.strokeColor = UIColor.darkGray
                self.animationPolyline.strokeWidth = 5.0
                self.animationPolyline.map = self.mapView
                self.i += 1
            }
            else {
                self.i = 0
                self.animatedPath = GMSMutablePath()
                self.animationPolyline.map = nil
            }
        }
    }
}

extension RouteViewController: SelectedLocationDelegate {
    func didSelectedLocation(identifier: viewIdentifier, selectedPlace: Place) {
        if identifier == .souceLocation {
            sourcePlace = selectedPlace
            txtSourceLocation.text = sourcePlace.address
        }
        else if identifier == .destinationLocation {
            destinationPlace = selectedPlace
            txtDestinationLocation.text = destinationPlace.address
        }
    }
}

extension RouteViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let fromMap = UIAlertAction(title: "Map", style: .default) { (action) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaceSelectionOnMapViewController") as! PlaceSelectionOnMapViewController
            vc.comeFrom = textField == self.txtSourceLocation ? .souceLocation : .destinationLocation
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let fromSearch = UIAlertAction(title: "Search", style: .default) { (action) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaceAutoCompleteViewController") as! PlaceAutoCompleteViewController
            vc.comeFrom = textField == self.txtSourceLocation ? .souceLocation : .destinationLocation
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let cancle = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        actionSheet.addAction(fromMap)
        actionSheet.addAction(fromSearch)
        actionSheet.addAction(cancle)
        self.present(actionSheet, animated: true, completion: nil)
        return false
    }
}
