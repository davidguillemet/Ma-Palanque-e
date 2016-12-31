//
//  ConnectionTableViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 07/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import UIKit

class ConnectionTableViewController: UITableViewController, UITextFieldDelegate, WebServiceDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var connectionButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            cancelButton.target = self.revealViewController()
            cancelButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        IconHelper.SetIcon(forBarButtonItem: cancelButton, icon: Icon.CancelCircled, fontSize: 24)
        
        TableViewHelper.ConfigureTable(tableView: self.tableView)
        self.tableView.allowsSelection = false
        
        
        userNameTextField.delegate = self
        passwordTextfield.delegate = self

        // Connection button disabled by default (user name and password must be populated)
        connectionButton.isEnabled = false
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
        return 3
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 120
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 2
        {
            return 60
        }
        else
        {
            return 44
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        connectionButton.isEnabled = false
        return true
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField)
    {
        if let user = userNameTextField.text, let pwd = passwordTextfield.text, !user.isEmpty, !pwd.isEmpty
        {
            connectionButton.isEnabled = true
        }
        else
        {
            connectionButton.isEnabled = false
        }
    }
    
    @IBAction func onConnection(_ sender: Any)
    {
        let connectionService: ConnectionService = ConnectionService(userName: userNameTextField.text!, userPwd: passwordTextfield.text!)
            connectionService.serviceDelegate = self
        ServiceManager.InvokeService(withService: connectionService, controller: self)
    }
    
    func OnResponse<T: WebServiceProtocol>(fromService: T)
    {
        let service: ConnectionService = fromService as! ConnectionService
        let response: (userName: String, active: Bool)? = service.responseData
        if response != nil
        {
            if !response!.active
            {
                MessageHelper.displayError("Votre compte n'est pas encore actif. Veuillez cliquer sur le lien contenu dans le mail d'activation qui a été envoyé à l'adresse que vous avez indiquée lors de votre inscription. Vous pouvez également cliquer sur \"Envoyer le lien\" pour recevoir à nouveau cet eMail.", controller: self)
            }
            else
            {
                // Remove currznt controller from navigation
                self.navigationController
                self.performSegue(withIdentifier: "AccountView", sender: self)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func cancelAction(_ sender: Any)
    {
        self.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }

}
