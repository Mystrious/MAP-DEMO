//
//  HomeViewController.swift
//  GMS-MAPVIEW
//
//  Created by MAC-4 on 10/25/17.
//  Copyright © 2017 Prismetric-MD2. All rights reserved.
//

import UIKit
import GooglePlaces

class HomeViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var arrayListing = ["Select location on map", "Place Autocomplete","Route with animation","Annotation Animation", "Custom Info Window", "MKLocalSearchCompleter"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUI() {
        tableView.tableFooterView = UIView()
        _ = LocationManager.shared
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayListing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = arrayListing[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
        cell?.textLabel?.textAlignment = .center
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaceSelectionOnMapViewController") as! PlaceSelectionOnMapViewController
            self.navigationController?.pushViewController (vc, animated: true)
        }
        else if indexPath.row == 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaceAutoCompleteViewController") as! PlaceAutoCompleteViewController
            self.navigationController?.pushViewController (vc, animated: true)
        }
        else if indexPath.row == 2 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RouteViewController") as! RouteViewController
            self.navigationController?.pushViewController (vc, animated: true)
        }
        else if indexPath.row == 3 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MappinAnimationViewController") as! MappinAnimationViewController
            self.navigationController?.pushViewController (vc, animated: true)
        }
        else if indexPath.row == 4 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomWindwViewController") as! CustomWindwViewController
            self.navigationController?.pushViewController (vc, animated: true)
        }
        else if indexPath.row == 5 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchCompleterViewController") as! SearchCompleterViewController
            self.navigationController?.pushViewController (vc, animated: true)
        }
    }
}
