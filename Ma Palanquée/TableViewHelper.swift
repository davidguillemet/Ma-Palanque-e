//
//  TableViewHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 07/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

class TableViewHelper
{
    class func ConfigureTable(tableView: UITableView)
    {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = ColorHelper.TableViewBackground
    }
}
