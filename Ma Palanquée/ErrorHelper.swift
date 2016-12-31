//
//  ErrorHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 29/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

enum ErrorHelper : Error
{
    case invalidGuide(guide: String)
    case invalidDiverIndex(index: Int)
    
    case invalidCredentials
    case noInternetConnection
    case invalidResponse
    case serverError
    
    static func ErrorDesc(error: ErrorHelper) -> String
    {
        switch (error)
        {
            case ErrorHelper.invalidCredentials:
                return "Il semblerait que les informations d'authentification ne soient pas correctes...";
            case ErrorHelper.noInternetConnection:
                return "Il semblerait que votre connexion internet ne fonctionne pas correctement...";
            case ErrorHelper.serverError:
                return "Une erreur s'est produite sur le serveur...";
            case ErrorHelper.invalidResponse:
                return "La réponse du serveur est incorrecte...";
            default:
                return "Une erreur inconnue s'est produite...";
        }
    }
}
