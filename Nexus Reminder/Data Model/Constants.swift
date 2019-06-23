//
//  Constants.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/31/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import Foundation

class GlobalVariables {
    var sesionIniciada: sesion = .none
    var actividadNexus: actividad = .none
    var jsonResponse: [[String:Any]] = []
    
    public enum sesion {
        case none, iniciada
    }
    public enum actividad {
        case none, guardada, nueva
    }
    class var shared: GlobalVariables {
        struct Static {
            static let instance = GlobalVariables()
        }
        return Static.instance
    }
    
}
