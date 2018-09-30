//
//  PlaceAutoCompleteViewController.swift
//  GMS-MAPVIEW
//
//  Created by MAC-4 on 10/26/17.
//  Copyright © 2017 Prismetric-MD2. All rights reserved.
//

import UIKit
import GooglePlaces

class PlaceAutoCompleteViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var txtSearch: UITextField!
    
    lazy var filter:GMSAutocompleteFilter = {
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        return filter
    }()
    
    var googlePlace = [GMSAutocompletePrediction]()
    
    var delegate:SelectedLocationDelegate!
    
    var comeFrom:viewIdentifier = viewIdentifier.menu
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back_clicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension PlaceAutoCompleteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googlePlace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.attributedText = googlePlace[indexPath.row].attributedPrimaryText
        cell?.textLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
        
        cell?.detailTextLabel?.attributedText = googlePlace[indexPath.row].attributedSecondaryText
        cell?.detailTextLabel?.font = UIFont(name: "Avenir-Medium", size: 12)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if comeFrom != .menu {
            GMSPlacesClient.shared().lookUpPlaceID(googlePlace[indexPath.row].placeID ?? "") { (place, error) in
                if error == nil && place != nil {
                    let selectedPlace = Place()
                    selectedPlace.address = place?.formattedAddress ?? ""
                    selectedPlace.name = place?.name ?? ""
                    selectedPlace.id = place?.placeID ?? ""
                    selectedPlace.lat = place?.coordinate.latitude ?? 0.0
                    selectedPlace.lng = place?.coordinate.longitude ?? 0.0
                    self.delegate?.didSelectedLocation(identifier: self.comeFrom, selectedPlace: selectedPlace)
                    self.navigationController?.popViewController (animated: true)
                }
                else {
                    debugPrint("Someting went wrong please try again.")
                }
            }            
        }
        
    }
}

extension PlaceAutoCompleteViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
        let searchString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    
        GMSPlacesClient.shared().autocompleteQuery(searchString, bounds: nil, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            
            if let results = results {
                self.googlePlace = results
                self.tableView.reloadData()
            }
        })
        return true
    }
}
