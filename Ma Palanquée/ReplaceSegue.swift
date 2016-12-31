//
//  ReplaceSegue.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 17/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import UIKit

class ReplaceSegue: UIStoryboardSegue {
    
    override func perform()
    {
        let sourceViewController = self.source
        let destinationController = self.destination
        let navigationController = sourceViewController.navigationController
        // Pop to root view controller (not animated) before pushing
        navigationController?.popViewController(animated: false)
        sourceViewController.present(destinationController, animated: true, completion: nil)
    }

}
