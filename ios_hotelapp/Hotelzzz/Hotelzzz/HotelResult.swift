//
//  HotelResult.swift
//  Hotelzzz
//
//  Created by Chris Kong on 5/16/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation

struct HotelResult {
    let name: String
    let address: String
    let urlString: String
    let price: Int
    
    init?(json: [String: Any]) {
        guard
            let hotelInfo = json["hotel"] as? [String: Any],
            let price = json["price"] as? Int
        else {
            return nil
        }
        
        guard
            let name = hotelInfo["name"] as? String,
            let address = hotelInfo["address"] as? String,
            let urlString = hotelInfo["imageURL"] as? String
        else {
                return nil
        }
        
        self.name = name
        self.address = address
        self.urlString = urlString
        self.price = price
        
    }
}
