//
//  PrefTableViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 07/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class PrefTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var nameDisplayTextField: UITextField!
    
    var pickerHelper: PickerViewHelper!
    
    @IBOutlet var prefTreeView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        IconHelper.SetIcon(forBarButtonItem: menuButton, icon: Icon.Back, fontSize: 24)
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        TableViewHelper.ConfigureTable(tableView: prefTreeView)
        prefTreeView.allowsSelection = false
        
        nameDisplayTextField.delegate = self

        nameDisplayTextField.text = PreferencesHelper.NameDisplayOption.description

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }


    // MARK: Actions
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField === self.nameDisplayTextField)
        {
            // Get possible dive directors from level >= E3 or training level is E3
            let possibleOptions: [NameDisplay] = [NameDisplay.FirstNameLastName, NameDisplay.LastNameFirstName, NameDisplay.LastNameOnly]
            
            pickerHelper = PickerViewHelper(textField: nameDisplayTextField, elements: possibleOptions as [AnyObject], onSelection: { (selection: AnyObject) -> Void in
                PreferencesHelper.NameDisplayOption = selection as! NameDisplay
            })
        }
        
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.nameDisplayTextField.resignFirstResponder()
        self.view.endEditing(true)
        return false
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
