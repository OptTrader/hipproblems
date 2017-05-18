//
//  HotelViewController.swift
//  Hotelzzz
//
//  Created by Steve Johnson on 3/22/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation
import UIKit

class HotelViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hotelNameLabel: UILabel!
    @IBOutlet weak var hotelAddressLabel: UILabel!
    @IBOutlet weak var hotelPriceLabel: UILabel!
    
    var hotel: HotelResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let hotelDetails = hotel {
            imageView.image = nil
            imageView.downloadedFrom(link: hotelDetails.urlString)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            hotelNameLabel.text = hotelDetails.name
            hotelAddressLabel.text = hotelDetails.address
            hotelAddressLabel.adjustsFontSizeToFitWidth = true
            hotelPriceLabel.text = Formatters.sharedInstance.stringFromPrice(price: hotelDetails.price, currencyCode: "USD")
        }
    }
}
