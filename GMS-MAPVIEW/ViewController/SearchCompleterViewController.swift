//
//  SearchCompleterViewController.swift
//  GMS-MAPVIEW
//
//  Created by MAC-4 on 6/13/18.
//  Copyright © 2018 Prismetric-MD2. All rights reserved.
//

import UIKit
import MapKit

class SearchCompleterViewController: UIViewController {

    @IBOutlet var txtSearchbar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
    var searchResults = [MKLocalSearchCompletion]()
    
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        return searchCompleter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension SearchCompleterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = searchResults[indexPath.row].title
        return cell!
    }
}

extension SearchCompleterViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension SearchCompleterViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            searchCompleter.queryFragment = searchText
        }
    }
}
