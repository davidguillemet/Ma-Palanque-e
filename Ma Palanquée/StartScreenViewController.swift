//
//  StartScreenViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 12/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import UIKit

class StartScreenViewController: UIViewController, WebServiceDelegate {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingIndicator.startAnimating()
        
        // Do any additional setup after loading the view.
        // Load application preferences
        PreferencesHelper.loadPreferences()
        
        // Load user session
        let persistedSession: Bool =  ServiceManager.loadPersistedSession(controller: self, delegate: self)
        
        // And other data...
        
        if (!persistedSession)
        {
            // No persisted session...
            // we can go directly to the first screen
            GoToFirstScreen()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func OnResponse<T: WebServiceProtocol>(fromService: T)
    {
        let service: GetUserService = fromService as! GetUserService
        if service.error != nil
        {
            // Seems like a communication error
            ServiceManager.IsOffline = true
            MessageHelper.displayError("Vous pouvez continuer à travailler en mode hors connexion. Une synchronisation sera effectuée lors d'une prochaine ouverture de l'application", controller: self) {
                self.GoToFirstScreen()
            }
        }
        else if service.responseData == nil
        {
            // No communication error and response is nil...
            // -> seems like the user is not valid anymore
            ServiceManager.CloseSession()
            MessageHelper.displayError("Il semblerait que votre utilisateur ne soit plus valide...", controller: self) {
                self.GoToFirstScreen()
            }
        }
        else
        {
            GoToFirstScreen()
        }
        
    }
    
    func GoToFirstScreen()
    {
        loadingIndicator.stopAnimating()
        
        // once the remote data have been loaded, just present the first screen
        DispatchQueue.main.async { [unowned self] in
            self.performSegue(withIdentifier: "ShowFirstScreen", sender: self)
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

}
