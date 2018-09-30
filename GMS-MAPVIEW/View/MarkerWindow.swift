//
//  MarkerWindow.swift
//  GMS-MAPVIEW
//
//  Created by MAC-4 on 6/12/18.
//  Copyright © 2018 Prismetric-MD2. All rights reserved.
//

import UIKit

class MarkerWindow: UIView {

    @IBOutlet var subView: UIView!
    
    @IBOutlet var lblTitle: UILabel!
    
    @IBOutlet var lblDesc: UILabel!
    
    @IBOutlet var btnViewOnMap: UIButton!

    
    @IBAction func clicked(_ sender: UIButton) {
        print("view on google map")
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.masksToBounds = true
    }
}

