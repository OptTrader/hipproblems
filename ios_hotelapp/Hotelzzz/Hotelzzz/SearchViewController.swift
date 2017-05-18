//
//  SearchViewController.swift
//  Hotelzzz
//
//  Created by Steve Johnson on 3/22/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation
import WebKit
import UIKit

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-mm-dd"
    return formatter
}()

private func jsonStringify(_ obj: [AnyHashable: Any]) -> String {
    let data = try! JSONSerialization.data(withJSONObject: obj, options: [])
    return String(data: data, encoding: .utf8)!
}

class SearchViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    struct Search {
        let location: String
        let dateStart: Date
        let dateEnd: Date
        
        var asJSONString: String {
            return jsonStringify([
                "location": location,
                "dateStart": dateFormatter.string(from: dateStart),
                "dateEnd": dateFormatter.string(from: dateEnd)
            ])
        }
    }
    
    private var _searchToRun: Search?
    var hotelDetails: HotelResult?
    var sortID: Sort = .name
    
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect.zero, configuration: {
            let config = WKWebViewConfiguration()
            config.userContentController = {
                let userContentController = WKUserContentController()
                
                // DECLARE YOUR MESSAGE HANDLERS HERE
                userContentController.add(self, name: Constants.ApiReady)
                userContentController.add(self, name: Constants.HotelApiResultsReady)
                userContentController.add(self, name: Constants.HotelApiHotelSelected)
                
                return userContentController
            }()
            return config
        }())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        
        self.view.addSubview(webView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: ["webView": webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: ["webView": webView]))
        return webView
    }()
    
    func search(location: String, dateStart: Date, dateEnd: Date) {
        _searchToRun = Search(location: location, dateStart: dateStart, dateEnd: dateEnd)
        self.webView.load(URLRequest(url: URL(string: "http://hipmunk.github.io/hipproblems/ios_hotelapp/")!))
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alertController = UIAlertController(title: NSLocalizedString("Could not load page", comment: ""), message: NSLocalizedString("Looks like the server isn't running.", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Bummer", comment: ""), style: .default, handler: nil))
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
            case Constants.ApiReady:
                guard let searchToRun = _searchToRun else { fatalError("Tried to load the page without having a search to run") }
                self.webView.evaluateJavaScript(
                    "window.JSAPI.runHotelSearch(\(searchToRun.asJSONString))",
                    completionHandler: nil)
            
            case Constants.HotelApiResultsReady:
                if let body = message.body as? [String: Any] {
//                    print(body)
                    if let results = body["results"] as? [[String: Any]] {
//                        print(results.count)
                        self.title = "\(results.count) Hotels"
                    }
                } else {
                    fatalError("Search Results Error")
            }
            
            case Constants.HotelApiHotelSelected:
                if let body = message.body as? [String: Any] {
    //                print(body)
                    if let result = body["result"] as? [String: Any] {
//                        print(result)
                        if let hotel = HotelResult(json: result) {
    //                        print(hotel)
                            self.hotelDetails = hotel
    //                        print(self.hotelDetails)
                            self.performSegue(withIdentifier: Constants.HotelDetailsSegue, sender: nil)
                        }
                    }
                   
                } else {
                    fatalError("Hotel Select Error")
            }
//            self.performSegue(withIdentifier: "hotel_details", sender: nil)
        default: break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.HotelDetailsSegue {
            let hotelDetails = self.hotelDetails
            if let hotelVC = segue.destination as? HotelViewController {
                hotelVC.hotel = hotelDetails
            }
        } else if segue.identifier == Constants.HotelSortSegue {
            if let sortedNav = segue.destination as? UINavigationController {
                let sortedResultsVC = sortedNav.visibleViewController as? SortedResultsViewController
                sortedResultsVC?.delegate = self
            }
        }
    }
    
    // MARK: Constants
    
    fileprivate struct Constants {
        static let ApiReady = "API_READY"
        static let HotelApiResultsReady = "HOTEL_API_RESULTS_READY"
        static let HotelApiHotelSelected = "HOTEL_API_HOTEL_SELECTED"
        static let HotelDetailsSegue = "hotel_details"
        static let HotelSortSegue = "select_sort"
    }
}

extension SearchViewController: SortOptionsDelegate {
    func sortOptionsSelected(viewController: SortedResultsViewController, _ sort: Sort) {
        sortID = sort
        self.webView.evaluateJavaScript("window.JSAPI.setHotelSort\(sortID)", completionHandler: nil)
    }
}
