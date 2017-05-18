//
//  SortedResultsViewController.swift
//  Hotelzzz
//
//  Created by Chris Kong on 5/17/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import UIKit

public enum Sort: Int {
    case name
    case priceAscend
    case priceDescend
    
    var description : String {
        switch self {
            case .name: return "Name"
            case .priceAscend: return "Price - Lowest"
            case .priceDescend: return "Price - Highest"
        }
    }
}

protocol SortOptionsDelegate: class {
    func sortOptionsSelected(viewController: SortedResultsViewController, _ sort: Sort)
}

class SortedResultsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    
    var sortedOptions = ["\(Sort.name.description)", "\(Sort.priceAscend.description)", "\(Sort.priceDescend.description)"]
    
    var delegate: SortOptionsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.delegate = self
        tableView?.dataSource = self
    }
}

extension SortedResultsViewController: UITableViewDelegate { }

extension SortedResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = sortedOptions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let selectedSort = Sort.init(rawValue: row)
//        print(selectedSort)
        self.delegate?.sortOptionsSelected(viewController: self, selectedSort!)
        
        self.dismiss(animated: true, completion: nil)
    }
}
