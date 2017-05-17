//
//  Formatters.swift
//  Hotelzzz
//
//  Created by Chris Kong on 5/16/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation

public class Formatters {
    public static let sharedInstance = Formatters()
    
    private let currencyFormatter = NumberFormatter()
    
    init() {
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.minimumFractionDigits = 0
        currencyFormatter.minimumIntegerDigits = 1
    }
    
    public func stringFromPrice(price: Int?, currencyCode: String) -> String? {
        guard let price = price else { return nil }
        currencyFormatter.currencyCode = currencyCode
        return currencyFormatter.string(from: NSNumber(value: price))
    }

}
