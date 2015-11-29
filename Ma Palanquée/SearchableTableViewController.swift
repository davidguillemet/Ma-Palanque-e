//
//  SearchableTableViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 14/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class SearchableTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    var resultSearchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .SingleLine
        
        self.resultSearchController = (
            {
                let controller = UISearchController(searchResultsController: nil)
                controller.searchResultsUpdater = self
                controller.dimsBackgroundDuringPresentation = false
                controller.searchBar.sizeToFit()
                
                controller.searchBar.delegate = self
                
                self.tableView.tableHeaderView = controller.searchBar
                
                return controller
        })()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func DisplaySearchResult() -> Bool
    {
        return  self.resultSearchController != nil && self.resultSearchController.active &&
            self.resultSearchController.searchBar.text != nil && self.resultSearchController.searchBar.text != ""
    }

    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        if (DisplaySearchResult())
        {
            InternalProcessFilter(searchController)
        }
        
        self.tableView.reloadData()
    }
    
    func InternalProcessFilter(searchController: UISearchController)
    {
        // TO Override
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        self.resultSearchController.searchBar.text = ""
    }

}
